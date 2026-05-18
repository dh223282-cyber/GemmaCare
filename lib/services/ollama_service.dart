import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/user_model.dart';

class OllamaService {
  Future<String> getHealthAdvice({
    required String prompt,
    required AppUser user,
    String? additionalContext,
  }) async {
    final String systemContext = '''
You are Gemma 4, an advanced AI Health Assistant for the 'GemmaCare' application.
User Profile:
- Age: \${user.age}
- Height: \${user.height} cm
- Weight: \${user.weight} kg
- Location: \${user.city}, \${user.country}

Provide precise, medical-grade (but safe) recommendations. Always remind the user to consult a doctor. Keep responses concise and structured.
\${additionalContext ?? ''}
''';

    try {
      final response = await http.post(
        Uri.parse(AppConstants.ollamaBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': AppConstants.ollamaModel,
          'prompt': prompt,
          'system': systemContext,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "I couldn't generate a response.";
      } else {
        return "Error connecting to AI. Please ensure Ollama is running locally.";
      }
    } catch (e) {
      return "Failed to connect to the local AI. If on emulator, ensure 'ollama run gemma:4b' is active.";
    }
  }
}
