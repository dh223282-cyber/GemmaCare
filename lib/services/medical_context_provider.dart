import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

class ClinicalRecord {
  final String date;
  final List<String> conditions;
  final List<String> medications;
  final String reportText;
  final int healthScore;

  ClinicalRecord({
    required this.date,
    required this.conditions,
    required this.medications,
    required this.reportText,
    required this.healthScore,
  });

  Map<String, dynamic> toMap() => {
    'date': date,
    'conditions': conditions,
    'medications': medications,
    'reportText': reportText,
    'healthScore': healthScore,
  };

  factory ClinicalRecord.fromMap(Map<String, dynamic> map) => ClinicalRecord(
    date: map['date'],
    conditions: List<String>.from(map['conditions']),
    medications: List<String>.from(map['medications']),
    reportText: map['reportText'],
    healthScore: map['healthScore'],
  );
}

class MedicalContextProvider extends ChangeNotifier {
  List<String> _conditions = [];
  List<String> get conditions => _conditions;

  List<String> _medications = [];
  List<String> get medications => _medications;

  String _reportText = '';
  String get reportText => _reportText;

  int _healthScore = 90;
  int get healthScore => _healthScore;

  List<ClinicalRecord> _history = [];
  List<ClinicalRecord> get history => _history;

  String _localAiIp = '10.39.254.102';
  String get localAiIp => _localAiIp;

  bool _isOnlineOverride = false;
  bool get isOnlineOverride => _isOnlineOverride;

  MedicalContextProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _conditions = prefs.getStringList('medical_conditions') ?? [];
      _medications = prefs.getStringList('current_medications') ?? [];
      _healthScore = prefs.getInt('health_score') ?? 90;
      _localAiIp = prefs.getString('local_ai_ip') ?? '10.39.254.102';
      _isOnlineOverride = prefs.getBool('is_online_override') ?? false;
      
      final historyJson = prefs.getString('clinical_history');
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _history = decoded.map((i) => ClinicalRecord.fromMap(i)).toList();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Persistence Load Error: $e");
    }
  }

  Future<void> updateClinicalData({
    List<String>? conditions,
    List<String>? medications,
    String? reportText,
    int? score,
  }) async {
    if (conditions != null) _conditions = conditions;
    if (medications != null) _medications = medications;
    if (reportText != null) _reportText = reportText;
    if (score != null) _healthScore = score;

    final now = DateTime.now();
    final dateStr = "${now.day}/${now.month}/${now.year}";
    
    // Add to history or update today's record
    int existingIndex = _history.indexWhere((r) => r.date == dateStr);
    final newRecord = ClinicalRecord(
      date: dateStr,
      conditions: _conditions,
      medications: _medications,
      reportText: _reportText,
      healthScore: _healthScore,
    );

    if (existingIndex != -1) {
      _history[existingIndex] = newRecord;
    } else {
      _history.insert(0, newRecord);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('medical_conditions', _conditions);
      await prefs.setStringList('current_medications', _medications);
      await prefs.setInt('health_score', _healthScore);
      await prefs.setString('clinical_history', jsonEncode(_history.map((r) => r.toMap()).toList()));
    } catch (e) {
      debugPrint("Save Error: $e");
    }
    notifyListeners();
  }

  Future<void> updateSettings({String? ip, bool? online}) async {
    if (ip != null) _localAiIp = ip;
    if (online != null) _isOnlineOverride = online;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      if (ip != null) await prefs.setString('local_ai_ip', ip);
      if (online != null) await prefs.setBool('is_online_override', online);
    } catch (e) {
      debugPrint("Settings Save Error: $e");
    }
    notifyListeners();
  }

  void clearAll() async {
    _conditions = [];
    _medications = [];
    _reportText = '';
    _history = [];
    _healthScore = 90;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint("Clear Error: $e");
    }
    notifyListeners();
  }
}
