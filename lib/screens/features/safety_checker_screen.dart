import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/medical_context_provider.dart';
import '../../services/mode_provider.dart';
import '../../services/api_service.dart';
import '../../core/theme.dart';
import 'dart:convert';

class SafetyCheckerScreen extends StatefulWidget {
  const SafetyCheckerScreen({super.key});
  @override
  State<SafetyCheckerScreen> createState() => _SafetyCheckerScreenState();
}

class _SafetyCheckerScreenState extends State<SafetyCheckerScreen>
    with SingleTickerProviderStateMixin {
  final _problemCtrl  = TextEditingController();
  final _durationCtrl = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  late AnimationController _resultAnim;
  late Animation<double>   _resultFade;

  @override
  void initState() {
    super.initState();
    _resultAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _resultFade = CurvedAnimation(parent: _resultAnim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _resultAnim.dispose();
    _problemCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    if (_problemCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please describe the problem.', style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() { _isLoading = true; _result = null; });
    _resultAnim.reset();

    final ctx  = Provider.of<MedicalContextProvider>(context, listen: false);
    final mode = Provider.of<ModeProvider>(context, listen: false);

    final prompt = '''
Act as a Clinical Physician. Suggest safe medication for this problem:
PROBLEM: ${_problemCtrl.text}
DURATION: ${_durationCtrl.text}

PATIENT CONTEXT:
Conditions: ${ctx.conditions.join(', ')}
Current Meds: ${ctx.medications.join(', ')}

STRICT JSON OUTPUT:
{
  "recommendation": "tablet name or advice",
  "dosage": "how much to take",
  "warning": "critical warning for this patient",
  "rationale": "why this is safe/unsafe given conditions",
  "is_safe": true
}
''';

    try {
      final raw = await ApiService.fetchGemmaResponse(
        prompt: prompt, userStats: 'Medicine Safety',
        disease: ctx.conditions.join(', '),
        meds: ctx.medications.join(', '),
        symptoms: _problemCtrl.text,
        isOnline: ctx.isOnlineOverride, localIp: ctx.localAiIp,
      );
      final json  = _extractJson(raw);
      final data  = jsonDecode(json) as Map<String, dynamic>;
      setState(() { _result = data; _isLoading = false; });
      _resultAnim.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Medicine Guard Error: $e');
    }
  }

  String _extractJson(String raw) {
    try {
      final start = raw.indexOf('{');
      final end   = raw.lastIndexOf('}');
      if (start != -1 && end > start) return raw.substring(start, end + 1).trim();
    } catch (_) {}
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final ctx  = Provider.of<MedicalContextProvider>(context);
    final meds = ctx.medications;

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Safety Guard', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.textPrimary)),
            Text('AI Medicine Safety Check', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.errorSurface, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.security_rounded, color: AppTheme.errorRed, size: 18),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Patient Context Chip Row ─────────────────
            if (meds.isNotEmpty) ...[
              Row(
                children: [
                  Text('Active meds: ', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                  ...meds.take(3).map((m) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GcHighlightPill(text: m),
                  )),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // ── Input Card ───────────────────────────────
            _InputCard(
              problemCtrl: _problemCtrl,
              durationCtrl: _durationCtrl,
              isLoading: _isLoading,
              onAnalyze: _runAnalysis,
            ),
            const SizedBox(height: 28),

            // ── Result ───────────────────────────────────
            if (_isLoading) _LoadingCard(label: 'Analyzing Safety...'),
            if (_result != null)
              FadeTransition(opacity: _resultFade, child: _ResultSection(result: _result!)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input Card
// ─────────────────────────────────────────────────────────────────────────────
class _InputCard extends StatelessWidget {
  final TextEditingController problemCtrl;
  final TextEditingController durationCtrl;
  final bool isLoading;
  final VoidCallback onAnalyze;

  const _InputCard({required this.problemCtrl, required this.durationCtrl, required this.isLoading, required this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.errorSurface, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.medical_services_rounded, color: AppTheme.errorRed, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Describe Your Problem', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: problemCtrl,
            maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. I have a severe headache and neck pain...',
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textTertiary),
              filled: true, fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.errorRed, width: 2)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: durationCtrl,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Duration  (e.g. since 2 hours)',
              prefixIcon: const Icon(Icons.timer_outlined, color: AppTheme.textSecondary, size: 18),
              filled: true, fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onAnalyze,
              icon: isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.shield_rounded, size: 18),
              label: Text(isLoading ? 'Analyzing...' : 'Run Safety Analysis', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result Section — with verdict banner + highlighted pills
// ─────────────────────────────────────────────────────────────────────────────
class _ResultSection extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ResultSection({required this.result});

  bool get _isSafe => result['is_safe'] == true || (result['is_safe'] is String && result['is_safe'].toString().toLowerCase() == 'true');

  @override
  Widget build(BuildContext context) {
    final recommendation = result['recommendation'] ?? 'N/A';
    final dosage         = result['dosage']         ?? '';
    final warning        = result['warning']        ?? '';
    final rationale      = result['rationale']      ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text('Clinical Analysis', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.textPrimary)),
        const SizedBox(height: 16),

        // ── VERDICT BANNER ───────────────────────────────
        GcVerdictBanner(
          verdict: _isSafe ? 'SAFE TO TAKE' : 'CAUTION REQUIRED',
          subtitle: _isSafe ? 'Suitable given your current medications' : 'Consult a physician before taking this',
          isPositive: _isSafe,
        ),
        const SizedBox(height: 16),

        // ── Recommendation Card ──────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              GcStatusBadge(
                label: _isSafe ? 'RECOMMENDED' : 'USE WITH CAUTION',
                color: _isSafe ? AppTheme.accentTeal : AppTheme.warningAmber,
                backgroundColor: _isSafe ? AppTheme.successSurface : AppTheme.warningSurface,
                icon: _isSafe ? Icons.check_circle_rounded : Icons.info_rounded,
              ),
              const SizedBox(height: 16),

              // Medication name highlighted
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MEDICATION: ', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                  Expanded(
                    child: GcHighlightPill(
                      text: recommendation,
                      color: AppTheme.accentTeal,
                      backgroundColor: AppTheme.successSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Dosage with quantity highlight
              if (dosage.isNotEmpty) ...[
                Text('DOSAGE', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textTertiary, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                _DosageRow(dosage: dosage),
                const SizedBox(height: 16),
              ],

              // Warning row
              if (warning.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warningSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.warningAmber, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(warning, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF92400E), height: 1.5))),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Rationale Card ───────────────────────────────
        if (rationale.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.subtleShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CLINICAL RATIONALE', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue, letterSpacing: 1.5)),
                const Divider(height: 20),
                Text(rationale, style: GoogleFonts.poppins(fontSize: 13, height: 1.6, color: AppTheme.textPrimary)),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.infoSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.accentSky, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Text('This is AI-assisted guidance only. Always consult a licensed physician before taking medication.', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.primaryBlue, height: 1.5))),
            ],
          ),
        ),
      ],
    );
  }
}

/// Parses dosage text and boldens numeric quantities
class _DosageRow extends StatelessWidget {
  final String dosage;
  const _DosageRow({required this.dosage});

  @override
  Widget build(BuildContext context) {
    // Highlight numbers + units (e.g. "50mg", "500mg", "1 tablet")
    final regex = RegExp(r'\d+(?:\.\d+)?(?:\s?mg|\s?ml|\s?g|\s?tablet|\s?tablets|\s?capsule|%)?', caseSensitive: false);
    final matches = regex.allMatches(dosage);

    if (matches.isEmpty) {
      return Text(dosage, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary));
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;
    for (final m in matches) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: dosage.substring(lastEnd, m.start), style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary)));
      }
      spans.add(WidgetSpan(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(dosage.substring(m.start, m.end), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
        ),
      ));
      lastEnd = m.end;
    }
    if (lastEnd < dosage.length) {
      spans.add(TextSpan(text: dosage.substring(lastEnd), style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary)));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading Card
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  final String label;
  const _LoadingCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppTheme.surfaceWhite, borderRadius: BorderRadius.circular(AppTheme.radiusXl), boxShadow: AppTheme.cardShadow),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}


