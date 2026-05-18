import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/medical_context_provider.dart';
import '../../services/mode_provider.dart';
import '../../services/api_service.dart';
import '../../core/theme.dart';

class ExercisePlanScreen extends StatefulWidget {
  const ExercisePlanScreen({super.key});

  @override
  State<ExercisePlanScreen> createState() => _ExercisePlanScreenState();
}

class _ExercisePlanScreenState extends State<ExercisePlanScreen> {
  bool _isLoading = false;
  String _aiOutput = '';

  void _generateKineticPlan() async {
    setState(() => _isLoading = true);
    final medicalContext = Provider.of<MedicalContextProvider>(context, listen: false);
    final mode = Provider.of<ModeProvider>(context, listen: false);

    final prompt = """
Act as a Clinical Exercise Physiologist. Suggest condition-safe exercises.
CONTEXT:
Conditions: ${medicalContext.conditions.join(', ')}
Meds: ${medicalContext.medications.join(', ')}
Health Score: ${medicalContext.healthScore}

Output format:
[STATUS]: (Safe / Caution / Dangerous)
[SUGGESTIONS]: (3 exercises)
[DANGER_WARNING]: (Specific activities to avoid for these conditions)
""";

    try {
      final response = await ApiService.fetchGemmaResponse(
        prompt: prompt,
        userStats: 'Kinetic Analysis',
        disease: medicalContext.conditions.join(', '),
        meds: medicalContext.medications.join(', '),
        symptoms: 'Exercise Suggestion',
        isOnline: medicalContext.isOnlineOverride,
        localIp: medicalContext.localAiIp,
      );
      setState(() {
        _aiOutput = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Kinetic Activity AI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryBlue), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroHeader(),
            const SizedBox(height: 32),
            _buildGenerateButton(),
            const SizedBox(height: 32),
            if (_isLoading) const Center(child: CircularProgressIndicator())
            else if (_aiOutput.isNotEmpty) _buildResults(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Optimization Active'.toUpperCase(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('Personalized Movement', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        const SizedBox(height: 8),
        Text('Activity suggestions calibrated to your current medical condition and medications.', style: GoogleFonts.poppins(color: AppTheme.textSecondary, height: 1.5)),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateKineticPlan,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Text('Sync & Suggest Exercises', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildResults() {
    bool isDangerous = _aiOutput.toLowerCase().contains('dangerous') || _aiOutput.toLowerCase().contains('restrict');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDangerous ? Colors.red.withOpacity(0.1) : AppTheme.accentTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: isDangerous ? Colors.red.withOpacity(0.2) : AppTheme.accentTeal.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isDangerous ? Icons.warning_rounded : Icons.check_circle_rounded, color: isDangerous ? Colors.red : AppTheme.accentTeal),
                  const SizedBox(width: 12),
                  Text('Safety Status', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDangerous ? Colors.red : AppTheme.accentTeal)),
                ],
              ),
              const SizedBox(height: 12),
              Text(_aiOutput, style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
