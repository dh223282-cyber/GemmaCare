import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class GemmaOfflineManager {
  static final GemmaOfflineManager _instance = GemmaOfflineManager._internal();
  factory GemmaOfflineManager() => _instance;
  GemmaOfflineManager._internal();

  final ValueNotifier<double> downloadProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<String> statusMessage = ValueNotifier<String>("Ready to download offline AI model.");
  
  final String modelUrl = "https://huggingface.co/Pragadeesh/gemma-2-2b-it-gpu-int4.task/resolve/main/gemma-2-2b-it-gpu-int4.task"; 
  final String modelFileName = "gemma-2-2b-it-gpu-int4.task";
  
  bool _isInitialized = false;
  InferenceModel? _model;
  InferenceChat? _chat;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await FlutterGemma.initialize();
      final isInstalled = await FlutterGemma.isModelInstalled(modelFileName);
      if (isInstalled) {
        await loadModel();
      }
    } catch (e) {
      debugPrint("Gemma Init Error: $e");
    }
    _isInitialized = true;
  }

  Future<bool> isModelDownloaded() async {
    return await FlutterGemma.isModelInstalled(modelFileName);
  }

  /// Permission Guard System: Simplified "No-Permission" Lifehack
  /// Using Internal App Directory (getApplicationDocumentsDirectory) requires 0 permissions.
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // 1. Only request Notification for progress tracking (Optional)
      await Permission.notification.request();
    }
    return true; // Bypass storage permissions since we use internal directory
  }

  Future<void> downloadOfflineModel() async {
    // 1. Check Connectivity (Wi-Fi Only Guard)
    var connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.wifi)) {
      statusMessage.value = "Wi-Fi connection required for 1.6GB download.";
      throw Exception("WiFi Required");
    }

    // 2. Storage Verification
    double? freeSpace = await DiskSpacePlus().getFreeDiskSpace; 
    if (freeSpace != null && freeSpace < 3072) {
      statusMessage.value = "Insufficient storage (3GB required).";
      throw Exception("Insufficient storage");
    }

    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount <= maxRetries) {
      try {
        await _startDownload();
        return; 
      } catch (e) {
        if (e is DioException && 
           (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) &&
           retryCount < maxRetries) {
          retryCount++;
          statusMessage.value = "Connection timeout. Retrying ($retryCount/$maxRetries)...";
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        rethrow;
      }
    }
  }

  Future<void> _startDownload() async {
    final appDir = await getApplicationDocumentsDirectory();
    final finalFile = File('${appDir.path}/$modelFileName');
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$modelFileName.part');
    
    int downloadedLength = 0;
    if (tempFile.existsSync()) {
      downloadedLength = tempFile.lengthSync();
    }

    Dio dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      followRedirects: true,
      maxRedirects: 5,
    ));

    try {
      statusMessage.value = downloadedLength > 0 ? "Resuming AI Brain..." : "Downloading AI Brain...";
      
      Response response = await dio.get(
        modelUrl,
        options: Options(
          headers: {'range': 'bytes=$downloadedLength-'},
          responseType: ResponseType.stream,
        ),
      );

      final raf = tempFile.openSync(mode: FileMode.append);
      
      final contentRange = response.headers.value('content-range');
      int totalSize = downloadedLength;
      if (contentRange != null) {
        totalSize = int.parse(contentRange.split('/').last);
      }

      await response.data.stream.listen(
        (List<int> chunk) {
          raf.writeFromSync(chunk);
          downloadedLength += chunk.length;
          if (totalSize > 0) {
            downloadProgress.value = downloadedLength / totalSize;
            statusMessage.value = "Downloading AI Brain: ${(downloadProgress.value * 100).toStringAsFixed(1)}%";
          }
        },
        onDone: () async {
          await raf.close();
        },
        onError: (e) async {
          await raf.close();
          throw e;
        },
        cancelOnError: true,
      ).asFuture();

      // Move to final destination
      if (finalFile.existsSync()) finalFile.deleteSync();
      tempFile.renameSync(finalFile.path);

      statusMessage.value = "Installing AI Brain...";
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.binary,
      ).fromFile(finalFile.path).install();

      await loadModel();
      
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          statusMessage.value = "Model file not found (404).";
        } else {
          statusMessage.value = "Download failed. Please try again.";
        }
      }
      rethrow;
    }
  }

  Future<void> loadModel() async {
    try {
      statusMessage.value = "Optimizing AI for your hardware...";
      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.gpu,
      );
      _chat = await _model!.createChat();
      statusMessage.value = "Gemma is ready!";
    } catch (e) {
      statusMessage.value = "Failed to load model on hardware.";
    }
  }
  
  Future<String> askGemma(String prompt) async {
    try {
      if (_chat == null) await loadModel();
      await _chat!.addQueryChunk(Message(text: prompt, isUser: true));
      final response = await _chat!.generateChatResponse();
      if (response is TextResponse) {
        return response.token.isNotEmpty ? response.token : "No response generated.";
      }
      return "Unsupported response format.";
    } catch (e) {
      return "Local inference memory limit reached.";
    }
  }
}
