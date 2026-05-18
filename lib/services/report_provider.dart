import 'package:flutter/material.dart';

class ReportProvider extends ChangeNotifier {
  String _extractedText = '';
  String get extractedText => _extractedText;

  bool _hasClinicalAlert = false;
  bool get hasClinicalAlert => _hasClinicalAlert;

  String _alertMessage = '';
  String get alertMessage => _alertMessage;

  int _healthScore = 85; 
  int get healthScore => _healthScore;

  String _healthTip = "Metabolic stability detected. Maintain current hydration.";
  String get healthTip => _healthTip;

  void updateExtractedText(String text) {
    _extractedText = text;
    _analyzeForAlerts(text);
    _calculateHealthScore(text);
    notifyListeners();
  }

  void _analyzeForAlerts(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('high glucose') || lowerText.contains('sugar') || lowerText.contains('glucose') || lowerText.contains('diabetes') || lowerText.contains('hba1c')) {
      _hasClinicalAlert = true;
      _alertMessage = "CRITICAL: High Glucose Level Detected in Reports.";
    } else if (lowerText.contains('abnormal') || lowerText.contains('elevated') || lowerText.contains('critical')) {
      _hasClinicalAlert = true;
      _alertMessage = "CRITICAL: Abnormal Biomarkers Detected in Medical Reports.";
    } else {
      _hasClinicalAlert = false;
      _alertMessage = "";
    }
  }

  void _calculateHealthScore(String text) {
    final lowerText = text.toLowerCase();
    int score = 85;
    
    if (lowerText.contains('high sugar') || lowerText.contains('glucose: high') || lowerText.contains('diabetes')) {
      score -= 25;
      _healthTip = "Urgent: High sugar detected. Reduce carb intake and maintain medication cycle.";
    } else if (lowerText.contains('abnormal')) {
      score -= 15;
      _healthTip = "Note: Abnormal lab values found. Follow clinical guidelines strictly.";
    } else {
      score += 5;
      _healthTip = "Excellent: Lab values are within optimal ranges. Keep it up!";
    }

    if (score > 100) score = 100;
    if (score < 10) score = 10;
    _healthScore = score;
  }

  void updateLiveVitals(int bpm) {
    // Basic score adjustment based on BPM
    if (bpm > 100 || bpm < 50) {
      _healthScore -= 5;
    }
    notifyListeners();
  }

  void clearReports() {
    _extractedText = '';
    _hasClinicalAlert = false;
    _alertMessage = '';
    _healthScore = 85;
    _healthTip = "Metabolic stability detected. Maintain current hydration.";
    notifyListeners();
  }
}
