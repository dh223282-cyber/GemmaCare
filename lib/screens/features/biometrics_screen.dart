import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class BiometricsScreen extends StatelessWidget {
  const BiometricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Connection', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal, letterSpacing: 2)),
              Text('Biometrics Sync', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              const SizedBox(height: 32),
              _buildDeviceCard('Samsung Galaxy Watch', Icons.watch_rounded),
              const SizedBox(height: 16),
              _buildDeviceCard('Apple Watch Series', Icons.apple_rounded),
              const SizedBox(height: 48),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.bluetooth_searching_rounded, size: 64, color: AppTheme.primaryBlue),
                    SizedBox(height: 16),
                    Text('Searching for devices...', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 32),
          const SizedBox(width: 16),
          Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue)),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
