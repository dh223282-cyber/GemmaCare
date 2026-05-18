import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/gemma_offline_manager.dart';
import '../../core/theme.dart';

class MentalHealthBotScreen extends StatefulWidget {
  const MentalHealthBotScreen({super.key});

  @override
  State<MentalHealthBotScreen> createState() => _MentalHealthBotScreenState();
}

class _MentalHealthBotScreenState extends State<MentalHealthBotScreen> {
  final List<Map<String, String>> _messages = [
    {'role': 'bot', 'content': 'Hello! I am Gemma, your Mental Health Buddy. How are you feeling today? I am here to listen and share positive vibes.'},
  ];
  final _msgCtrl = TextEditingController();
  bool _isTyping = false;

  void _sendMessage() async {
    if (_msgCtrl.text.isEmpty) return;

    String userMsg = _msgCtrl.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userMsg});
      _msgCtrl.clear();
      _isTyping = true;
    });

    final prompt = """
Act as a Mental Health Buddy Chatbot. Be extremely positive, encouraging, and kind.
User says: $userMsg
Respond with a helpful, positive, and clinical-yet-friendly tone. Focus on mental well-being.
""";

    try {
      final manager = GemmaOfflineManager();
      final response = await manager.askGemma(prompt);

      setState(() {
        _messages.add({'role': 'bot', 'content': response});
        _isTyping = false;
      });
    } catch (e) {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Mental Health Buddy', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryBlue), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 20),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                    ),
                    child: Text(
                      msg['content']!,
                      style: GoogleFonts.poppins(color: isUser ? Colors.white : AppTheme.textPrimary, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Text('Gemma is typing...', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: 'Talk to Gemma...',
                hintStyle: GoogleFonts.poppins(color: AppTheme.textSecondary),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(backgroundColor: AppTheme.primaryBlue, child: Icon(Icons.send_rounded, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
