import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/medical_context_provider.dart';
import '../../core/theme.dart';
import '../features/food_suggestion_screen.dart';
import '../features/exercise_plan_screen.dart';
import '../features/safety_checker_screen.dart';
import '../features/patient_details_screen.dart';
import '../features/mental_health_bot_screen.dart';
import '../features/gemma_setup_screen.dart';
import '../features/hybrid_chat_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _scoreAnim;
  late Animation<double> _scoreProgress;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scoreAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final score = Provider.of<MedicalContextProvider>(context).healthScore;
    _scoreProgress = Tween<double>(begin: 0, end: score / 100)
        .animate(CurvedAnimation(parent: _scoreAnim, curve: Curves.easeOutCubic));
    _scoreAnim.forward(from: 0);
  }

  @override
  void dispose() {
    _scoreAnim.dispose();
    super.dispose();
  }

  // ── Emergency QR ──────────────────────────────────────────────
  void _showEmergencyQR(MedicalContextProvider ctx, String name) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Emergency ID', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryBlue)),
              const SizedBox(height: 4),
              Text('Scan for critical medical data', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.backgroundWhite, borderRadius: BorderRadius.circular(16)),
                child: QrImageView(
                  data: 'PATIENT: $name | CONDITIONS: ${ctx.conditions.join(', ')} | MEDICATIONS: ${ctx.medications.join(', ')}',
                  version: QrVersions.auto, size: 180,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: AppTheme.primaryBlue),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medCtx  = Provider.of<MedicalContextProvider>(context);
    final user    = Provider.of<AuthService>(context).currentUser;
    final name    = user?.name ?? 'Dhinesh';
    final score   = medCtx.healthScore;
    final isGood  = score >= 70;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundWhite,
      drawer: _buildProfileDrawer(name),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Compact SliverAppBar ───────────────────────
            SliverAppBar(
              backgroundColor: AppTheme.backgroundWhite,
              elevation: 0,
              pinned: true,
              toolbarHeight: 72,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppTheme.backgroundWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar to open drawer
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.accentSky],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Welcome back,', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w400)),
                            Text(name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue, height: 1.2)),
                          ],
                        ),
                      ),
                      // QR Button
                      _IconBtn(
                        icon: Icons.qr_code_rounded,
                        tooltip: 'Emergency ID',
                        onTap: () => _showEmergencyQR(medCtx, name),
                      ),
                      const SizedBox(width: 8),
                      // Notification placeholder
                      _IconBtn(
                        icon: Icons.notifications_none_rounded,
                        tooltip: 'Notifications',
                        onTap: () {},
                        badge: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Body content ──────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Clinical Profile Bar ─────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientDetailsScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryBlue, Color(0xFF2D52A8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.medical_information_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Clinical Health Profile', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                if (medCtx.conditions.isNotEmpty)
                                  Text(medCtx.conditions.take(2).join(' · '), style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11))
                                else
                                  Text('Tap to update your medical data', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Health Score Card ────────────────────
                  _HealthScoreCard(
                    score: score,
                    isGood: isGood,
                    animation: _scoreProgress,
                    conditions: medCtx.conditions,
                    onQrTap: () => _showEmergencyQR(medCtx, name),
                  ),
                  const SizedBox(height: 28),

                  // ── Core Health Services ─────────────────
                  GcSectionHeader(title: 'Core Health Services'),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.88,
                    children: [
                      _ServiceTile(icon: Icons.restaurant_rounded,     label: 'Medical\nDiet',      color: AppTheme.accentTeal,   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodSuggestionScreen()))),
                      _ServiceTile(icon: Icons.security_rounded,       label: 'Safety\nGuard',      color: AppTheme.errorRed,     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyCheckerScreen()))),
                      _ServiceTile(icon: Icons.fitness_center_rounded, label: 'Kinetic\nActivity',  color: AppTheme.warningAmber, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisePlanScreen()))),
                      _ServiceTile(icon: Icons.psychology_rounded,     label: 'Mental\nHealth',     color: AppTheme.accentSky,    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalHealthBotScreen()))),
                      _ServiceTile(icon: Icons.memory_rounded,         label: 'Offline\nAI Setup',  color: const Color(0xFF7C3AED), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GemmaSetupScreen()))),
                      _ServiceTile(icon: Icons.auto_awesome_rounded,   label: 'GemmaCare\nAI Chat', color: AppTheme.primaryBlue,  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HybridChatScreen())), isPrimary: true),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Clinical History ─────────────────────
                  if (medCtx.history.isNotEmpty) ...[
                    GcSectionHeader(title: 'Clinical History'),
                    const SizedBox(height: 16),
                    ...medCtx.history.map((r) => _HistoryCard(record: r, onTap: () {
                      medCtx.updateClinicalData(conditions: r.conditions, medications: r.medications, reportText: r.reportText, score: r.healthScore);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientDetailsScreen()));
                    })),
                    const SizedBox(height: 16),
                  ],

                  // ── Quick AI Banner ──────────────────────
                  _AiBanner(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ── Profile Drawer ────────────────────────────────────────────
  Widget _buildProfileDrawer(String name) {
    return Drawer(
      backgroundColor: AppTheme.surfaceWhite,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue, Color(0xFF2D52A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    gradient: const LinearGradient(colors: [AppTheme.accentSky, AppTheme.accentTeal]),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Premium Member', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _DrawerItem(
            icon: Icons.language_rounded,
            title: 'Language',
            onTap: () => _showComingSoon('Language Settings'),
          ),
          _DrawerItem(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () => _showComingSoon('Advanced Settings'),
          ),
          const Spacer(),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            isDestructive: true,
            onTap: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    Navigator.pop(context); // close drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('\$feature is coming soon!', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({required this.icon, required this.title, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTheme.errorRed : AppTheme.textPrimary;
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.errorRed : AppTheme.primaryBlue),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Score Card — beautiful circular arc with animated fill
// ─────────────────────────────────────────────────────────────────────────────
class _HealthScoreCard extends StatelessWidget {
  final int score;
  final bool isGood;
  final Animation<double> animation;
  final List<String> conditions;
  final VoidCallback onQrTap;

  const _HealthScoreCard({required this.score, required this.isGood, required this.animation, required this.conditions, required this.onQrTap});

  Color get _ringColor => score >= 80 ? AppTheme.accentTeal : score >= 60 ? AppTheme.warningAmber : AppTheme.errorRed;

  @override
  Widget build(BuildContext context) {
    return GcCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gemma Health Score', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
              GcStatusBadge(
                label: isGood ? 'OPTIMAL' : 'NEEDS CARE',
                color: isGood ? AppTheme.accentTeal : AppTheme.warningAmber,
                backgroundColor: isGood ? AppTheme.successSurface : AppTheme.warningSurface,
                icon: isGood ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Circular score
          AnimatedBuilder(
            animation: animation,
            builder: (_, __) => SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _ScoreArcPainter(progress: animation.value, color: _ringColor),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '${(animation.value * 100).toInt()}',
                            style: GoogleFonts.poppins(fontSize: 44, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue, height: 1),
                          ),
                          TextSpan(
                            text: '/100',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 4),
                      Text('Today', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textTertiary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Score insight row
          Row(
            children: [
              _ScoreInsight(label: 'Conditions', value: conditions.isEmpty ? 'None' : '${conditions.length}', icon: Icons.monitor_heart_rounded, color: AppTheme.errorRed),
              const SizedBox(width: 12),
              _ScoreInsight(label: 'Status', value: isGood ? 'Good' : 'Fair', icon: Icons.health_and_safety_rounded, color: isGood ? AppTheme.accentTeal : AppTheme.warningAmber),
              const SizedBox(width: 12),
              _ScoreInsight(label: 'Updated', value: 'Today', icon: Icons.calendar_today_rounded, color: AppTheme.accentSky),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreInsight extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ScoreInsight({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary)),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// Custom arc painter for health score ring
class _ScoreArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScoreArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 12.0;

    // Background track
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,          // start at top
      2 * math.pi * progress, // sweep angle
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [color.withValues(alpha: 0.6), color],
          startAngle: 0,
          endAngle: 2 * math.pi * progress,
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ScoreArcPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Service Tile — Monochromatic outline icon in soft circle
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ServiceTile({required this.icon, required this.label, required this.color, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryBlue : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withValues(alpha: 0.15) : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isPrimary ? Colors.white : color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Card
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final ClinicalRecord record;
  final VoidCallback onTap;

  const _HistoryCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGood = record.healthScore >= 70;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isGood ? AppTheme.successSurface : AppTheme.warningSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isGood ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                color: isGood ? AppTheme.accentTeal : AppTheme.warningAmber,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.date, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                  Text('Score: ${record.healthScore} · ${record.conditions.length} condition(s)', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick AI Banner
// ─────────────────────────────────────────────────────────────────────────────
class _AiBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HybridChatScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GemmaCare AI', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                  Text('Ask me anything about your health', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text('Chat', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primaryBlue)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable icon button for header
// ─────────────────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool badge;

  const _IconBtn({required this.icon, required this.tooltip, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppTheme.surfaceWhite, shape: BoxShape.circle, boxShadow: AppTheme.subtleShadow),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            if (badge) Positioned(
              top: 8, right: 8,
              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.errorRed, shape: BoxShape.circle)),
            ),
          ],
        ),
      ),
    );
  }
}


