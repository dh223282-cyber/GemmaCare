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
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite, 
        borderRadius: BorderRadius.circular(AppTheme.radiusXl), 
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('Tap to sync data', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue, 
              foregroundColor: Colors.white, 
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text('Add', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
