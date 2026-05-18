import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/medical_context_provider.dart';
import '../../core/theme.dart';

class MedicationGuideScreen extends StatefulWidget {
  const MedicationGuideScreen({super.key});

  @override
  State<MedicationGuideScreen> createState() => _MedicationGuideScreenState();
}

class _MedicationGuideScreenState extends State<MedicationGuideScreen> {
  final _medsCtrl = TextEditingController();
  final _symptomCtrl = TextEditingController();
  
  bool _isLoading = false;
  String _aiOutput = '';

  void _performTripleSafetyCheck() async {
    if (_symptomCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe your symptom or problem.')));
      return;
    }

    setState(() => _isLoading = true);
    final user = Provider.of<AuthService>(context, listen: false).currentUser!;
    final medicalContext = Provider.of<MedicalContextProvider>(context, listen: false);

    final prompt = """
Act as a Senior Clinical Physician. Perform a Triple-Safety Check for:
1. REPORTED SYMPTOM: ${_symptomCtrl.text}
2. UNDERLYING CONDITIONS: ${user.conditions.join(', ')}
3. CURRENT ACTIVE MEDICATIONS: ${_medsCtrl.text}

STRICT INSTRUCTIONS:
- Specifically analyze if taking common OTC medicine (e.g., Paracetamol, Aspirin, Ibuprofen) is safe given the context.
- If unsafe or high risk, STICTLY FORBID it and explain why (e.g., drug interaction or condition contraindication).
- Suggest a safer, natural/non-pharmacological remedy instead.
- Use Clinical Medical English.

Output Format:
[SAFETY_STATUS]: [SAFE / HIGH_RISK / STICTLY_FORBIDDEN]
[CLINICAL_RATIONALE]: [Reason based on interactions/conditions]
[RECOMMENDED_ACTION]: [Step-by-step next steps]
[NATURAL_ALTERNATIVE]: [Safe home remedy]
""";

    final response = await ApiService.fetchGemmaResponse(
      prompt: prompt,
      userStats: 'Clinical Safety Protocol',
      disease: user.conditions.join(', '),
      meds: _medsCtrl.text,
      symptoms: _symptomCtrl.text,
      isOnline: medicalContext.isOnlineOverride,
      localIp: medicalContext.localAiIp,
    );

    setState(() {
      _isLoading = false;
      _aiOutput = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text('Medical Advisor', style: AppTheme.lightTheme.textTheme.titleLarge),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader('Clinical Consultation', 'Triple-Safety Check', 'Verify OTC drug safety against your conditions and medications.'),
              const SizedBox(height: 32),
              _buildLabel('Describe Urgent Symptom'),
              const SizedBox(height: 8),
              TextField(controller: _symptomCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'e.g., Persistent headache or Stomach pain')),
              const SizedBox(height: 24),
              _buildLabel('Current Active Medications'),
              const SizedBox(height: 8),
              TextField(controller: _medsCtrl, decoration: const InputDecoration(hintText: 'e.g., Amlodipine, MetFORMIN')),
              const SizedBox(height: 32),
              _aiOutput.isEmpty ? _buildDiscoveryCard() : _buildSafetyResults(),
              const SizedBox(height: 32),
              _buildActionFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(String s1, String s2, String s3) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s1.toUpperCase(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text(s2, style: AppTheme.lightTheme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(s3, style: AppTheme.lightTheme.textTheme.bodyMedium),
    ]);
  }

  Widget _buildLabel(String t) => Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue));

  Widget _buildDiscoveryCard() => Container(width: double.infinity, padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.03), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1))), child: Column(children: [Icon(Icons.health_and_safety_rounded, color: AppTheme.primaryBlue.withOpacity(0.5), size: 48), const SizedBox(height: 16), const Text('Safety Audit Ready', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)), const SizedBox(height: 8), const Text('Input your symptoms and meds for a physician-grade safety scan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]));

  Widget _buildSafetyResults() {
    final status = _extract(_aiOutput, '[SAFETY_STATUS]');
    final rationale = _extract(_aiOutput, '[CLINICAL_RATIONALE]');
    final action = _extract(_aiOutput, '[RECOMMENDED_ACTION]');
    final alt = _extract(_aiOutput, '[NATURAL_ALTERNATIVE]');
    
    bool isForbidden = _aiOutput.contains('FORBIDDEN') || _aiOutput.contains('HIGH_RISK');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: isForbidden ? Colors.red.withOpacity(0.05) : AppTheme.primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: isForbidden ? Colors.red.withOpacity(0.2) : AppTheme.primaryBlue.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(isForbidden ? Icons.report_problem_rounded : Icons.check_circle_rounded, color: isForbidden ? Colors.red : Colors.green), const SizedBox(width: 12), Text(status, style: TextStyle(fontWeight: FontWeight.bold, color: isForbidden ? Colors.red : Colors.green, fontSize: 16))]),
          const SizedBox(height: 20),
          _buildResultSection('Clinical Rationale', rationale),
          _buildResultSection('Recommended Action', action),
          _buildResultSection('Natural Alternative', alt),
        ],
      ),
    );
  }

  Widget _buildResultSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textPrimary)),
      ]),
    );
  }

  Widget _buildActionFooter() => ElevatedButton(onPressed: _isLoading ? null : _performTripleSafetyCheck, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Run Triple-Safety Scan'));

  String _extract(String text, String tag) {
    if (!text.contains(tag)) return "Awaiting diagnosis...";
    int start = text.indexOf(tag) + tag.length + 1;
    int end = text.indexOf('[', start);
    if (end == -1) end = text.length;
    return text.substring(start, end).trim().replaceAll(':', '');
  }
}
