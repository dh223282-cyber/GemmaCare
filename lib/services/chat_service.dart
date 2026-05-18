import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'gemma_manager.dart';

/// Enum representing the currently active AI engine.
enum AiEngine { online, offline, unavailable }

/// ChatService — Hybrid AI Router
/// ─────────────────────────────────────────────────────────────
/// DEFAULT  : Online Gemini 1.5 Flash (google_generative_ai)
/// FALLBACK : Local FlutterGemma (flutter_gemma) when:
///              • No internet connectivity
///              • [isForceOffline] == true
/// SAFETY   : If offline engine also fails → returns a friendly
///            'Connection required' message instead of crashing.
/// ─────────────────────────────────────────────────────────────
class ChatService {
  // ── Singleton ──────────────────────────────────────────────
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  // ── Configuration ──────────────────────────────────────────
  static const String _geminiApiKey = 'YOUR_API_KEY_HERE';
  static const String _geminiModel = 'gemini-1.5-flash';

  /// Set to true to force local Gemma regardless of connectivity.
  bool isForceOffline = false;

  // ── State notifiers (consumed by UI) ───────────────────────
  final ValueNotifier<AiEngine> activeEngine =
      ValueNotifier(AiEngine.online);

  // ── Private internals ──────────────────────────────────────
  late final GenerativeModel _geminiOnline;
  ChatSession? _onlineSession;
  bool _onlineInitialized = false;

  // ── Initialization ─────────────────────────────────────────
  void _ensureOnlineInit() {
    if (_onlineInitialized) return;
    _geminiOnline = GenerativeModel(
      model: _geminiModel,
      apiKey: _geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        '''You are GemmaCare AI — a compassionate, evidence-based clinical health assistant.
You help patients understand their medical conditions, medications, nutrition, and exercise safely.
Always prioritize patient safety. Never replace professional medical advice.
Use clear, empathetic language and Markdown formatting for structured responses.''',
      ),
    );
    _onlineSession = _geminiOnline.startChat();
    _onlineInitialized = true;
  }

  // ── Core method: send a chat message ───────────────────────
  Future<String> sendMessage(String userMessage) async {
    final bool isOffline = isForceOffline || !(await _hasInternet());

    if (!isOffline) {
      return _tryOnline(userMessage);
    } else {
      return _tryOffline(userMessage);
    }
  }

  // ── Online path: Gemini 1.5 Flash ──────────────────────────
  Future<String> _tryOnline(String message) async {
    try {
      _ensureOnlineInit();
      activeEngine.value = AiEngine.online;
      final response = await _onlineSession!.sendMessage(
        Content.text(message),
      );
      final text = response.text;
      if (text == null || text.isEmpty) {
        return 'GemmaCare AI returned an empty response. Please try again.';
      }
      return text;
    } catch (e) {
      debugPrint('[ChatService] Online engine failed: $e');
      // Auto-degrade to offline on any online failure
      return _tryOffline(message);
    }
  }

  // ── Offline path: Local FlutterGemma ───────────────────────
  Future<String> _tryOffline(String message) async {
    try {
      final manager = GemmaManager();
      if (!manager.isModelReady) {
        // Attempt a lazy load in case model exists but wasn't loaded
        await manager.loadModel();
      }
      if (!manager.isModelReady) {
        activeEngine.value = AiEngine.unavailable;
        return '🔌 **Connection Required**\n\nThe offline AI model is not loaded yet. '
            'Please connect to the internet or download the AI Brain from the Dashboard.';
      }
      activeEngine.value = AiEngine.offline;
      return await manager.askGemma(message);
    } catch (e) {
      debugPrint('[ChatService] Offline engine failed: $e');
      activeEngine.value = AiEngine.unavailable;
      return '⚠️ **AI Temporarily Unavailable**\n\nBoth online and offline engines encountered an error. '
          'Please check your internet connection and try again.';
    }
  }

  // ── Connectivity helper ────────────────────────────────────
  Future<bool> _hasInternet() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.any((r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet);
    } catch (_) {
      return false;
    }
  }

  // ── Reset chat session (e.g. on new conversation) ──────────
  void resetSession() {
    if (_onlineInitialized) {
      _onlineSession = _geminiOnline.startChat();
    }
  }
}
