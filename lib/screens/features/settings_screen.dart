import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/medical_context_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final medicalContext = Provider.of<MedicalContextProvider>(context, listen: false);
    _ipCtrl.text = medicalContext.localAiIp;
  }

  @override
  Widget build(BuildContext context) {
    final medicalContext = Provider.of<MedicalContextProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preferences', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal, letterSpacing: 2)),
              Text('System Settings', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              const SizedBox(height: 32),
              
              // Operation mode toggle removed for 100% offline pure mode
              
              _buildSettingCard(
                title: 'Local AI IP',
                subtitle: 'Current: ${medicalContext.localAiIp}',
                icon: Icons.computer_rounded,
                onTap: () => _showIpDialog(medicalContext),
              ),
              const SizedBox(height: 16),
              
              _buildComingSoonItem('Language Selection', Icons.language_rounded),
              const SizedBox(height: 16),
              _buildComingSoonItem('Country/Region', Icons.public_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({required String title, required String subtitle, required IconData icon, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue)),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showIpDialog(MedicalContextProvider contextProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Local AI IP', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _ipCtrl,
          decoration: const InputDecoration(hintText: 'e.g. 192.168.1.100'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              contextProvider.updateSettings(ip: _ipCtrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonItem(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 28),
          const SizedBox(width: 16),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textSecondary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('Coming Soon', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
