import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/mode_provider.dart';

class ResultScreen extends StatelessWidget {
  final String title;
  final String aiResponse;

  const ResultScreen({super.key, required this.title, required this.aiResponse});

  @override
  Widget build(BuildContext context) {
    final mode = Provider.of<ModeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Markdown(
                        data: aiResponse,
                        styleSheet: MarkdownStyleSheet(
                          h1: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                          h2: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF005CB2)),
                          p: GoogleFonts.inter(fontSize: 15, height: 1.6),
                          listBullet: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      mode.isOnlineMode ? Icons.cloud_done : Icons.dns_rounded,
                      color: mode.isOnlineMode ? Colors.green.shade700 : Colors.blue.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Processed via: ${mode.isOnlineMode ? 'Cloud API' : 'Local Ollama'}',
                      style: TextStyle(
                        color: mode.isOnlineMode ? Colors.green.shade700 : Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
