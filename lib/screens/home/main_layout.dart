import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/biometrics_screen.dart';
import '../features/settings_screen.dart';
import 'home_tab.dart';
import '../../core/theme.dart';
import '../../services/gemma_manager.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const BiometricsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performStartupCheck();
    });
  }

  // ── Startup gate ───────────────────────────────────────────
  Future<void> _performStartupCheck() async {
    final manager = GemmaManager();
    final isInstalled = await manager.isModelInstalled();

    if (!mounted) return;

    if (!isInstalled) {
      // Show the premium AI Brain Missing dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _AiBrainDialog(manager: manager),
      );
    } else {
      // Auto-load model in background — no blocking UI
      Future.microtask(() => manager.loadModel());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20)
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded), label: 'Biometrics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AiBrainDialog — Premium "AI Brain Missing" popup
// ─────────────────────────────────────────────────────────────────────────────
class _AiBrainDialog extends StatefulWidget {
  final GemmaManager manager;
  const _AiBrainDialog({required this.manager});

  @override
  State<_AiBrainDialog> createState() => _AiBrainDialogState();
}

class _AiBrainDialogState extends State<_AiBrainDialog>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  bool _isDone = false;
  String? _errorMessage;
  late AnimationController _brainPulse;

  @override
  void initState() {
    super.initState();
    _brainPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _brainPulse.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
    });
    widget.manager.downloadProgress.value = 0.0;

    try {
      await widget.manager.downloadModel();
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDone = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = widget.manager.statusMessage.value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              blurRadius: 40,
              spreadRadius: 4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────
            ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.08).animate(
                CurvedAnimation(parent: _brainPulse, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.15),
                      AppTheme.accentTeal.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isDone
                      ? Icons.check_circle_rounded
                      : Icons.psychology_rounded,
                  color:
                      _isDone ? const Color(0xFF4CAF50) : AppTheme.primaryBlue,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────
            Text(
              _isDone ? 'AI Brain Installed!' : '🧠 AI Brain Missing',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppTheme.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // ── Subtitle ──────────────────────────────────
            Text(
              _isDone
                  ? 'Your on-device AI is ready to use. Enjoy private, offline health assistance!'
                  : 'GemmaCare needs to download a local AI model (≈1.6 GB) for private offline support. A Wi-Fi connection is recommended.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── Error message ─────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Download progress ─────────────────────────
            if (_isDownloading) ...[
              ValueListenableBuilder<double>(
                valueListenable: widget.manager.downloadProgress,
                builder: (_, progress, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Downloading AI Brain...',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentTeal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor:
                              AppTheme.primaryBlue.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<String>(
                        valueListenable: widget.manager.statusMessage,
                        builder: (_, msg, __) => Text(
                          msg,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Action buttons ────────────────────────────
            if (!_isDownloading && !_isDone) ...[
              // Primary: Download Now
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download_rounded),
                  label: Text(
                    _errorMessage != null ? 'Retry Download' : 'Download Now',
                    style:
                        GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Secondary: Skip (use cloud only)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Skip (Use Cloud AI)',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tertiary: Exit
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: Text(
                  'Exit App',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade400),
                ),
              ),
            ],

            if (_isDownloading) ...[
              TextButton(
                onPressed: () {
                  // Cancel: just skip to cloud
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel & Use Cloud AI',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
