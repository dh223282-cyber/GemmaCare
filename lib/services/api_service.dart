import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String localModel = 'gemma:2b';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqApiKey = 'YOUR_API_KEY_HERE';
  static const String clinicalModel = 'llama-3.3-70b-versatile';

  static bool _isLocalAlive = false;

  static Future<void> checkLocalConnectivity(String ip) async {
    try {
      final response = await http.get(Uri.parse('http://$ip:11434')).timeout(const Duration(seconds: 3));
      _isLocalAlive = response.statusCode == 200;
    } catch (e) {
      _isLocalAlive = false;
    }
  }

  static Future<String> fetchGemmaResponse({
    required String prompt,
    required String userStats,
    required String disease,
    required String meds,
    required String symptoms,
    required bool isOnline,
    required String localIp,
    bool forceCloud = false,
  }) async {
    // Attempt local discovery
    if (!forceCloud && !isOnline) {
      await checkLocalConnectivity(localIp);
    }

    final String systemContext = '''
You are a Clinical Health AI specialized in nutrition, medicine safety, and kinetic movement.
CONTEXT:
Stats: $userStats
Condition: $disease
Medications: $meds
Symptoms/Query: $symptoms

STRICT RULES:
1. BIO-INTERACTION: Cross-reference every suggestion with the patient's medications ($meds).
2. SAFETY FIRST: If a suggestion is risky given the conditions ($disease), strictly warn the user.
3. OUTPUT: Provide structured, clinical, and helpful responses. Use Markdown for clarity.
''';

    try {
      final bool useLocal = _isLocalAlive && !isOnline && !forceCloud;
      final String targetUrl = useLocal ? 'http://$localIp:11434/api/generate' : groqBaseUrl;
      final String activeModel = useLocal ? localModel : clinicalModel;
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (!useLocal) {
        headers['Authorization'] = 'Bearer $groqApiKey';
      }

      final Map<String, dynamic> body = !useLocal 
        ? {
            'model': activeModel,
            'messages': [
              {'role': 'system', 'content': systemContext},
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.5,
          }
        : {
            'model': localModel,
            'prompt': prompt,
            'system': systemContext,
            'stream': false,
          };

      debugPrint("API Request: ${useLocal ? 'LOCAL' : 'CLOUD'} -> $targetUrl");
      debugPrint("API Headers: $headers");
      debugPrint("API Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(targetUrl),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 45));

      debugPrint("API Response Status: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (useLocal) {
          return data['response'] ?? "Error: Local AI returned no data.";
        } else {
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            return data['choices'][0]['message']['content'] ?? "Error: Cloud AI returned empty content.";
          }
          return "Error: Unexpected Cloud Response Format.";
        }
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
        if (useLocal) {
          // Fallback to Cloud if Local fails (maybe IP was alive but model failed)
          return await fetchGemmaResponse(prompt: prompt, userStats: userStats, disease: disease, meds: meds, symptoms: symptoms, isOnline: true, localIp: localIp, forceCloud: true);
        }
        String errorMsg = "Service Error (${response.statusCode})";
        try {
          final errData = jsonDecode(response.body);
          if (errData['error'] != null && errData['error']['message'] != null) {
            errorMsg = "API Error: ${errData['error']['message']}";
          }
        } catch (_) {}
        return errorMsg;
      }
    } catch (e) {
      debugPrint("Critical API Exception: $e");
      if (!forceCloud) {
        return await fetchGemmaResponse(prompt: prompt, userStats: userStats, disease: disease, meds: meds, symptoms: symptoms, isOnline: true, localIp: localIp, forceCloud: true);
      }
      return "Network Error: $e. Please check your connection.";
    }
  }
}
