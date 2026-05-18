import 'package:flutter/material.dart';
import '../../services/gemma_offline_manager.dart';
import 'offline_chat_screen.dart';

/// 2. OfflineSetupScreen UI (Material 3)
/// Acts as a one-time onboarding gate to download the local AI
class GemmaSetupScreen extends StatefulWidget {
  const GemmaSetupScreen({Key? key}) : super(key: key);

  @override
  State<GemmaSetupScreen> createState() => _GemmaSetupScreenState();
}

class _GemmaSetupScreenState extends State<GemmaSetupScreen> {
  final GemmaOfflineManager _manager = GemmaOfflineManager();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingModel();
  }

  Future<void> _checkExistingModel() async {
    final isInstalled = await _manager.isModelDownloaded();
    if (isInstalled) {
      if (mounted) _navigateToChat();
    }
  }

  void _navigateToChat() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OfflineChatScreen()),
    );
  }

  Future<void> _startDownload() async {
    setState(() => _isDownloading = true);
    try {
      await _manager.downloadOfflineModel();
      if (mounted) _navigateToChat();
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('GemmaCare Initialization'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.psychology_rounded,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 32),
            Text(
              'Install Local AI Brain',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'To ensure maximum privacy and zero latency, GemmaCare runs its intelligence locally on your device hardware. Please download the Core AI Brain.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            if (_isDownloading)
              Column(
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: _manager.downloadProgress,
                    builder: (context, progress, child) {
                      return LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: Colors.teal.shade100,
                        color: Colors.teal,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: _manager.statusMessage,
                    builder: (context, message, child) {
                      return Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.teal,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Local AI Brain (~2.5GB)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
