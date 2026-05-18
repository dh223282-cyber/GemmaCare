import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/medical_context_provider.dart';
import '../../core/theme.dart';
import 'dart:async';

class HealthTrackTab extends StatefulWidget {
  const HealthTrackTab({super.key});

  @override
  State<HealthTrackTab> createState() => _HealthTrackTabState();
}

class _HealthTrackTabState extends State<HealthTrackTab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  
  bool _isScanning = false;
  bool _isConnected = false;
  BluetoothDevice? _connectedDevice;
  
  double _bpm = 0.0;
  int _steps = 5420;
  double _energy = 85.0;
  String _aiAdvice = "";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startZ86Scan() async {
    setState(() => _isScanning = true);
    
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10), withNames: ['Z86 Pro Max']);
        
        FlutterBluePlus.scanResults.listen((results) {
          for (ScanResult r in results) {
            if (r.device.platformName == 'Z86 Pro Max') {
              FlutterBluePlus.stopScan();
              _connectToZ86(r.device);
              break;
            }
          }
        });
      } catch (e) {
        debugPrint('Scan error: $e');
      }
    }
    
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  Future<void> _connectToZ86(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        _isConnected = true;
        _connectedDevice = device;
        _isScanning = false;
      });
      _analyzeLiveMetrics();
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  }

  Future<void> _analyzeLiveMetrics() async {
    final medicalContext = Provider.of<MedicalContextProvider>(context, listen: false);
    final user = Provider.of<AuthService>(context, listen: false).currentUser!;

    String prompt = "Evaluate Live Biometrics: BPM: $_bpm, Steps: $_steps. Device: Z86 Pro Max. Provide a clinical summary and activity recommendation in Professional English.";

    final response = await ApiService.fetchGemmaResponse(
      prompt: prompt,
      userStats: 'Age: ${user.age}, Device: Z86 Pro Max',
      disease: 'General Monitoring',
      meds: 'N/A',
      symptoms: 'Stable',
      isOnline: medicalContext.isOnlineOverride,
      localIp: medicalContext.localAiIp,
    );

    setState(() => _aiAdvice = response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 32),
            _buildVitalsHero(),
            const SizedBox(height: 32),
            Text('Daily Progress', style: AppTheme.lightTheme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildMetricsGrid(),
            const SizedBox(height: 32),
            if (_aiAdvice.isNotEmpty) _buildInsightCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          _buildConnectionIndicator(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? 'Z86 Pro Max Active' : 'Device Disconnected',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  _isConnected ? 'Live biometric streaming active' : 'Scan for your wearable device',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isScanning ? null : _startZ86Scan,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConnected ? AppTheme.accentTeal.withOpacity(0.1) : AppTheme.primaryBlue,
              foregroundColor: _isConnected ? AppTheme.accentTeal : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
            ),
            child: Text(_isScanning ? 'Scanning...' : (_isConnected ? 'Sync' : 'Scan')),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isScanning)
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryBlue.withOpacity(0.3),
            ),
          ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (_isConnected ? AppTheme.accentTeal : AppTheme.primaryBlue).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isConnected ? Icons.watch_rounded : Icons.bluetooth_searching_rounded,
            color: _isConnected ? AppTheme.accentTeal : AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Heart Rate (Live)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                child: const Text('Real-Time', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.1).animate(_pulseController),
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_bpm.toInt()}',
                  style: GoogleFonts.poppins(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text('BPM', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeroStat(Icons.trending_up, 'Normal Range', '60-100'),
              _buildHeroStat(Icons.history, 'Last Sync', 'Just now'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildMetricCard('Movement', '$_steps', 'Steps', Icons.directions_walk_rounded, AppTheme.accentTeal),
        _buildMetricCard('Energy', '${_energy.toInt()}%', 'Reserve', Icons.bolt_rounded, Colors.orange),
        _buildMetricCard('Calories', '342', 'kcal', Icons.local_fire_department_rounded, Colors.redAccent),
        _buildMetricCard('Rest', '7.4', 'Hours', Icons.nights_stay_rounded, Colors.indigo),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 12),
              Text('Gemma Clinical Insight', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          Text(_aiAdvice, style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
