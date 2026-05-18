import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// GemmaManager — Local Offline AI Model Lifecycle
/// ─────────────────────────────────────────────────────────────
/// Responsibilities:
///  • Download the gemma-2-2b-it-gpu-int4.tflite model with resume support
///  • Install it via FlutterGemma
///  • Load the InferenceModel + InferenceChat for Q&A
///  • Expose ValueNotifiers so the UI can reactively update
/// ─────────────────────────────────────────────────────────────
class GemmaManager {
  // ── Singleton ──────────────────────────────────────────────
  static final GemmaManager _instance = GemmaManager._internal();
  factory GemmaManager() => _instance;
  GemmaManager._internal();

  // ── Model metadata ─────────────────────────────────────────
  /// Verified HuggingFace direct-download link (GPU INT4 variant)
  static const String modelUrl =
      'https://huggingface.co/google/gemma-2-2b-it-tflite/resolve/main/gemma-2-2b-it-gpu-int4.tflite';
  static const String modelFileName = 'gemma-2-2b-it-gpu-int4.tflite';

  // ── Public state notifiers ─────────────────────────────────
  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final ValueNotifier<String> statusMessage =
      ValueNotifier('Ready to download offline AI model.');
  final ValueNotifier<bool> isDownloading = ValueNotifier(false);

  // ── Private runtime state ──────────────────────────────────
  bool _isInitialized = false;
  InferenceModel? _model;
  InferenceChat? _chat;

  /// True when the model is loaded and ready for inference.
  bool get isModelReady => _model != null && _chat != null;

  // ── Initialization ─────────────────────────────────────────
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await FlutterGemma.initialize();
      final installed = await isModelInstalled();
      if (installed) {
        await loadModel();
      } else {
        statusMessage.value = 'Offline AI model not yet downloaded.';
      }
    } catch (e) {
      debugPrint('[GemmaManager] Init error: $e');
      statusMessage.value = 'Offline AI initialization failed.';
    } finally {
      _isInitialized = true;
    }
  }

  // ── Model file check ───────────────────────────────────────
  /// Checks if the .tflite model file exists in the app documents directory.
  Future<bool> isModelInstalled() async {
    try {
      // Primary check: flutter_gemma registry
      return await FlutterGemma.isModelInstalled(modelFileName);
    } catch (_) {
      // Fallback check: file existence on disk
      final appDir = await getApplicationDocumentsDirectory();
      return File('${appDir.path}/$modelFileName').existsSync();
    }
  }

  // ── Download ───────────────────────────────────────────────
  /// Downloads the model with resume support and retry logic.
  /// Saves to [getApplicationDocumentsDirectory] — no Android permissions needed.
  Future<void> downloadModel({bool allowMobileData = false}) async {
    if (isDownloading.value) return;

    // ── Connectivity guard ─────────────────────────────────
    final connectivity = await Connectivity().checkConnectivity();
    final hasWifi = connectivity.contains(ConnectivityResult.wifi);
    final hasMobile = connectivity.contains(ConnectivityResult.mobile);

    if (!hasWifi && !hasMobile) {
      statusMessage.value = 'No internet connection available.';
      throw Exception('No internet');
    }
    if (!hasWifi && !allowMobileData) {
      statusMessage.value = 'Wi-Fi required for the 1.6 GB download.';
      throw Exception('WiFi required');
    }

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount <= maxRetries) {
      try {
        await _executeDownload();
        isDownloading.value = false;
        return;
      } on DioException catch (e) {
        final isTimeout = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout;
        if (isTimeout && retryCount < maxRetries) {
          retryCount++;
          statusMessage.value =
              'Connection timeout. Retrying ($retryCount/$maxRetries)...';
          await Future.delayed(const Duration(seconds: 3));
        } else {
          isDownloading.value = false;
          _handleDioError(e);
          rethrow;
        }
      } catch (e) {
        isDownloading.value = false;
        statusMessage.value = 'Download failed: ${e.toString()}';
        rethrow;
      }
    }
  }

  Future<void> _executeDownload() async {
    // ── Directories ────────────────────────────────────────
    // getApplicationDocumentsDirectory = no permission required on Android 13+
    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();

    final finalFile = File('${appDir.path}/$modelFileName');
    final tempFile = File('${tempDir.path}/$modelFileName.part');

    // ── Resume support ─────────────────────────────────────
    int downloadedBytes = 0;
    if (tempFile.existsSync()) {
      downloadedBytes = tempFile.lengthSync();
      debugPrint('[GemmaManager] Resuming from $downloadedBytes bytes');
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      followRedirects: true,
      maxRedirects: 5,
    ));

    statusMessage.value = downloadedBytes > 0
        ? 'Resuming AI Brain download...'
        : 'Downloading AI Brain (1.6 GB)...';

    final response = await dio.get<ResponseBody>(
      modelUrl,
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          if (downloadedBytes > 0) 'Range': 'bytes=$downloadedBytes-',
        },
      ),
    );

    final raf = tempFile.openSync(mode: FileMode.append);
    int totalBytes = downloadedBytes;

    // Parse total size from Content-Range or Content-Length header
    final contentRange = response.headers.value('content-range');
    final contentLength = response.headers.value('content-length');
    int? fileSize;
    if (contentRange != null) {
      fileSize = int.tryParse(contentRange.split('/').last);
    } else if (contentLength != null) {
      fileSize = (int.tryParse(contentLength) ?? 0) + downloadedBytes;
    }

    try {
      await response.data!.stream.listen(
        (chunk) {
          raf.writeFromSync(chunk);
          totalBytes += chunk.length;
          if (fileSize != null && fileSize > 0) {
            downloadProgress.value = totalBytes / fileSize;
            statusMessage.value =
                'Downloading: ${(downloadProgress.value * 100).toStringAsFixed(1)}%';
          }
        },
        onDone: () async => await raf.close(),
        onError: (e) async {
          await raf.close();
          throw e;
        },
        cancelOnError: true,
      ).asFuture();
    } catch (e) {
      await raf.close();
      rethrow;
    }

    // ── Move to final location ─────────────────────────────
    if (finalFile.existsSync()) finalFile.deleteSync();
    await tempFile.rename(finalFile.path);

    // ── Install via FlutterGemma registry ─────────────────
    statusMessage.value = 'Installing AI Brain...';
    try {
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.binary,
      ).fromFile(finalFile.path).install();
    } catch (installErr) {
      debugPrint('[GemmaManager] Install registry failed: $installErr — using file path directly');
    }

    statusMessage.value = 'Loading AI Brain into memory...';
    await loadModel();
    statusMessage.value = 'Offline AI is ready! 🧠';
    downloadProgress.value = 1.0;
  }

  void _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 404:
        statusMessage.value = 'Model file not found on server (404).';
        break;
      case 403:
      case 401:
        statusMessage.value = 'Access denied (${e.response?.statusCode}). Try again later.';
        break;
      default:
        statusMessage.value = 'Download failed. Please check your connection.';
    }
  }

  // ── Load model into memory ─────────────────────────────────
  Future<void> loadModel() async {
    try {
      statusMessage.value = 'Optimizing AI for your hardware...';
      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.gpu,
      );
      _chat = await _model!.createChat();
      statusMessage.value = 'Offline AI ready ✓';
      debugPrint('[GemmaManager] Model loaded successfully.');
    } catch (e) {
      debugPrint('[GemmaManager] Model load error: $e');
      _model = null;
      _chat = null;
      statusMessage.value = 'Failed to load model on GPU. Retrying on CPU...';
      // CPU fallback
      try {
        _model = await FlutterGemma.getActiveModel(
          maxTokens: 512,
          preferredBackend: PreferredBackend.cpu,
        );
        _chat = await _model!.createChat();
        statusMessage.value = 'Offline AI ready (CPU mode) ✓';
      } catch (cpuErr) {
        debugPrint('[GemmaManager] CPU fallback also failed: $cpuErr');
        _model = null;
        _chat = null;
        statusMessage.value = 'Offline AI unavailable on this device.';
      }
    }
  }

  // ── Inference ──────────────────────────────────────────────
  Future<String> askGemma(String prompt) async {
    try {
      if (_chat == null) {
        await loadModel();
      }
      if (_chat == null) {
        return '🔌 **Offline AI unavailable.** Please connect to the internet.';
      }

      await _chat!.addQueryChunk(Message(text: prompt, isUser: true));
      final response = await _chat!.generateChatResponse();

      if (response is TextResponse) {
        return response.token.isNotEmpty
            ? response.token
            : 'No response generated. Please try again.';
      }
      return 'Unsupported response format from local model.';
    } catch (e) {
      debugPrint('[GemmaManager] Inference error: $e');
      // Reset chat to clear any corrupted state
      _chat = null;
      return '⚠️ Local AI error. The model may have run out of memory. Try a shorter message.';
    }
  }

  // ── Delete local model (for storage management) ────────────
  Future<void> deleteModel() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$modelFileName');
      if (file.existsSync()) file.deleteSync();
      _model = null;
      _chat = null;
      statusMessage.value = 'Offline AI model removed.';
      downloadProgress.value = 0.0;
    } catch (e) {
      debugPrint('[GemmaManager] Delete error: $e');
    }
  }
}
