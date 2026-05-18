import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/report_provider.dart';
import '../../core/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;
    final reportProvider = Provider.of<ReportProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text('Clinician Profile', style: AppTheme.lightTheme.textTheme.titleLarge),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(user?.name ?? 'Dhinesh', style: AppTheme.lightTheme.textTheme.displayLarge),
            Text(user?.email ?? 'patient@gemmacare.app', style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 32),
            _buildProfileSection('Physiological Metrics', [
              _buildMetricTile('Age', '${user?.age ?? 25} Years'),
              _buildMetricTile('Weight', '${user?.weight ?? 70.0} kg'),
              _buildMetricTile('Height', '${user?.height ?? 170.0} cm'),
            ]),
            const SizedBox(height: 24),
            _buildProfileSection('Medical Context', [
              _buildInfoTile('Active Conditions', user?.conditions.join(', ') ?? 'None'),
              _buildInfoTile('Clinical Reports', reportProvider.extractedText.isNotEmpty ? 'Analysis Synchronized' : 'No Data Uploaded'),
            ]),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                auth.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Logout Clinical Session', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal, letterSpacing: 2)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, height: 1.4)),
        ],
      ),
    );
  }
}
