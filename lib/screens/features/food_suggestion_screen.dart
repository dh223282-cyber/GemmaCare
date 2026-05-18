import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/mode_provider.dart';
import '../../services/medical_context_provider.dart';
import '../../core/theme.dart';
import 'dart:convert';

class FoodSuggestionScreen extends StatefulWidget {
  const FoodSuggestionScreen({super.key});

  @override
  State<FoodSuggestionScreen> createState() => _FoodSuggestionScreenState();
}

class _FoodSuggestionScreenState extends State<FoodSuggestionScreen> {
  final _lastMealCtrl = TextEditingController();
  final _mealTimeCtrl = TextEditingController();
  final _instantFoodCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _isBreakfastSelected = true;
  bool _isLunchSelected = true;
  bool _isDinnerSelected = true;

  Map<String, dynamic> _mealData = {};

  void _generateClinicalDietPlan() async {
    if (_lastMealCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter last meal details.')));
      return;
    }

    setState(() => _isLoading = true);
    final medicalContext = Provider.of<MedicalContextProvider>(context, listen: false);
    final mode = Provider.of<ModeProvider>(context, listen: false);

    String selection = "";
    if (_isBreakfastSelected) selection += "Breakfast, ";
    if (_isLunchSelected) selection += "Lunch, ";
    if (_isDinnerSelected) selection += "Dinner, ";

    final prompt = """
Act as a Medical Nutritionist. Generate a diet plan for: $selection.
CONTEXT:
Conditions: ${medicalContext.conditions.join(', ')}
Meds: ${medicalContext.medications.join(', ')}
Last Meal: ${_lastMealCtrl.text} at ${_mealTimeCtrl.text}

STRICT JSON OUTPUT:
{
  "breakfast": {"food": "name", "tip": "why"},
  "lunch": {"food": "name", "tip": "why"},
  "dinner": {"food": "name", "tip": "why"}
}
""";

    try {
      final response = await ApiService.fetchGemmaResponse(
        prompt: prompt,
        userStats: 'Metabolic Sync',
        disease: medicalContext.conditions.join(', '),
        meds: medicalContext.medications.join(', '),
        symptoms: 'N/A',
        isOnline: medicalContext.isOnlineOverride,
        localIp: medicalContext.localAiIp,
      );
      String cleanJson = _extractJson(response);
      setState(() {
        _mealData = jsonDecode(cleanJson);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Diet Error: $e');
    }
  }

  void _instantCheck() async {
    if (_instantFoodCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    final medicalContext = Provider.of<MedicalContextProvider>(context, listen: false);
    
    final prompt = """
Can a patient with ${medicalContext.conditions.join(', ')} eat ${_instantFoodCtrl.text} (Quantity: ${_quantityCtrl.text})?
Give a clear YES/NO, how much to eat, and risks.
""";

    try {
      final response = await ApiService.fetchGemmaResponse(
        prompt: prompt,
        userStats: 'Instant Food Analysis',
        disease: medicalContext.conditions.join(', '),
        meds: medicalContext.medications.join(', '),
        symptoms: 'N/A',
        isOnline: medicalContext.isOnlineOverride,
        localIp: medicalContext.localAiIp,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Instant Food Check', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(response, style: GoogleFonts.poppins(fontSize: 14)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
          ],
        ),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFoodPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    
    setState(() => _isLoading = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analyzing food label...')));

    try {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String extracted = recognizedText.text.replaceAll('\n', ' ');
      if (extracted.isEmpty) extracted = "Unknown Food Item";
      
      setState(() {
        _instantFoodCtrl.text = extracted.length > 50 ? extracted.substring(0, 50) + '...' : extracted;
        _isLoading = false;
      });
      
      textRecognizer.close();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food text extracted! Tap Check to analyze.')));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to read image.')));
    }
  }

  String _extractJson(String raw) {
    try {
      int start = raw.indexOf('{');
      int end = raw.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        return raw.substring(start, end + 1).trim();
      }
    } catch (e) {
      debugPrint("JSON Extract Error: $e");
    }
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Medical Diet AI', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryBlue), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Context Intake',
              child: Column(
                children: [
                  _buildInputField(_lastMealCtrl, 'What was your last meal?', Icons.restaurant_menu),
                  const SizedBox(height: 16),
                  _buildInputField(_mealTimeCtrl, 'When did you eat?', Icons.access_time),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionHeader('Suggest For:'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChoiceChip('Breakfast', _isBreakfastSelected, (v) => setState(() => _isBreakfastSelected = v)),
                const SizedBox(width: 8),
                _buildChoiceChip('Lunch', _isLunchSelected, (v) => setState(() => _isLunchSelected = v)),
                const SizedBox(width: 8),
                _buildChoiceChip('Dinner', _isDinnerSelected, (v) => setState(() => _isDinnerSelected = v)),
              ],
            ),
            const SizedBox(height: 24),

            _buildGenerateButton(),
            const SizedBox(height: 32),

            if (_mealData.isNotEmpty) ...[
              _buildSectionHeader('Your Plan'),
              const SizedBox(height: 16),
              if (_isBreakfastSelected) _buildMealResult('Breakfast', _mealData['breakfast']),
              if (_isLunchSelected) _buildMealResult('Lunch', _mealData['lunch']),
              if (_isDinnerSelected) _buildMealResult('Dinner', _mealData['dinner']),
            ],

            const SizedBox(height: 32),
            _buildInstantCheckSection(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue));
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryBlue,
      labelStyle: GoogleFonts.poppins(color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _generateClinicalDietPlan,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Generate Suggestion', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildMealResult(String type, dynamic data) {
    if (data == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
          const SizedBox(height: 8),
          Text(data['food'] ?? 'N/A', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          const SizedBox(height: 4),
          Text(data['tip'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInstantCheckSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text('Instant Food Check', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue)),
          const SizedBox(height: 20),
          _buildInputField(_instantFoodCtrl, 'Food Name', Icons.fastfood_rounded),
          const SizedBox(height: 12),
          _buildInputField(_quantityCtrl, 'Quantity (e.g. 1 bowl)', Icons.scale_rounded),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFoodPhoto,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _instantCheck,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Check'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
