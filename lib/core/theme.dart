import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
// GemmaCare Material 3 Design System
// ═══════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  // ── Brand Palette ────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF1E3A8A); // Deep Navy
  static const Color accentSky     = Color(0xFF60A5FA); // Sky Blue
  static const Color accentTeal    = Color(0xFF10B981); // Emerald Green
  static const Color errorRed      = Color(0xFFEF4444); // Crimson Red
  static const Color warningAmber  = Color(0xFFF59E0B); // Amber

  // ── Surface & Background ─────────────────────────────────────
  static const Color backgroundWhite = Color(0xFFF8FAFC); // Subtle off-white
  static const Color surfaceWhite    = Color(0xFFFFFFFF);
  static const Color surfaceCard     = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary  = Color(0xFF94A3B8); // Slate 400

  // ── Status Colors (semantic) ─────────────────────────────────
  static const Color success  = Color(0xFF10B981);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color error    = Color(0xFFEF4444);
  static const Color info     = Color(0xFF60A5FA);

  // ── Status Tinted Surfaces ────────────────────────────────────
  static const Color successSurface = Color(0xFFD1FAE5);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color errorSurface   = Color(0xFFFEE2E2);
  static const Color infoSurface    = Color(0xFFDBEAFE);

  // ── Radius tokens ─────────────────────────────────────────────
  static const double radiusSm  = 12;
  static const double radiusMd  = 16;
  static const double radiusLg  = 24;
  static const double radiusXl  = 28;
  static const double radiusXxl = 32;

  // ── Shadow helper ─────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1E3A8A).withValues(alpha: 0.06),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  // ── ThemeData ─────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundWhite,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: accentSky,
        onSecondary: Colors.white,
        tertiary: accentTeal,
        surface: surfaceWhite,
        error: errorRed,
      ),

      // ── Typography ─────────────────────────────────────────
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        // Hero numbers (Health score, etc.)
        displayLarge: GoogleFonts.poppins(
          color: primaryBlue, fontSize: 48,
          fontWeight: FontWeight.w800, letterSpacing: -1,
        ),
        // Page titles
        displayMedium: GoogleFonts.poppins(
          color: textPrimary, fontSize: 28,
          fontWeight: FontWeight.bold, letterSpacing: -0.5,
        ),
        // Section headers
        titleLarge: GoogleFonts.poppins(
          color: textPrimary, fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textPrimary, fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.poppins(
          color: textSecondary, fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        // Body text
        bodyLarge: GoogleFonts.poppins(
          color: textPrimary, fontSize: 15,
          fontWeight: FontWeight.w400, height: 1.6,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: textSecondary, fontSize: 13,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          color: textTertiary, fontSize: 11,
          fontWeight: FontWeight.w500, letterSpacing: 0.3,
        ),
        // Label
        labelLarge: GoogleFonts.poppins(
          color: Colors.white, fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── AppBar ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundWhite,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        centerTitle: false,
        iconTheme: const IconThemeData(color: primaryBlue, size: 22),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary, fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ── Elevated Button ────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Card ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: textTertiary, fontSize: 14),
      ),

      // ── Chip ──────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: const Color(0xFFDBEAFE),
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Divider ───────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GC Design Components  — shared reusable widgets
// ═══════════════════════════════════════════════════════════════

/// A pill-shaped status badge  e.g. "[STATUS]: Safe"
class GcStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData? icon;

  const GcStatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.icon,
  });

  factory GcStatusBadge.safe({String label = 'SAFE'}) => GcStatusBadge(
    label: label,
    color: AppTheme.accentTeal,
    backgroundColor: AppTheme.successSurface,
    icon: Icons.check_circle_rounded,
  );

  factory GcStatusBadge.warning({String label = 'CAUTION'}) => GcStatusBadge(
    label: label,
    color: AppTheme.warningAmber,
    backgroundColor: AppTheme.warningSurface,
    icon: Icons.warning_amber_rounded,
  );

  factory GcStatusBadge.danger({String label = 'DANGER'}) => GcStatusBadge(
    label: label,
    color: AppTheme.errorRed,
    backgroundColor: AppTheme.errorSurface,
    icon: Icons.dangerous_rounded,
  );

  factory GcStatusBadge.info({String label = 'INFO'}) => GcStatusBadge(
    label: label,
    color: AppTheme.accentSky,
    backgroundColor: AppTheme.infoSurface,
    icon: Icons.info_rounded,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A highlighted keyword pill — e.g. 'Metformin' in green
class GcHighlightPill extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;

  const GcHighlightPill({
    super.key,
    required this.text,
    this.color = AppTheme.accentTeal,
    this.backgroundColor = AppTheme.successSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Full-width verdict banner  e.g. "YES, WITH MODERATION"
class GcVerdictBanner extends StatelessWidget {
  final String verdict;
  final String subtitle;
  final bool isPositive;

  const GcVerdictBanner({
    super.key,
    required this.verdict,
    this.subtitle = '',
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppTheme.accentTeal : AppTheme.errorRed;
    final bg    = isPositive ? AppTheme.successSurface : AppTheme.errorSurface;
    final icon  = isPositive ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verdict,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 12, color: color.withValues(alpha: 0.8)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A prominent quantity highlight widget
class GcQuantityHighlight extends StatelessWidget {
  final String quantity;
  final String unit;

  const GcQuantityHighlight({super.key, required this.quantity, this.unit = ''});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: quantity,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryBlue,
            decoration: TextDecoration.underline,
            decorationColor: AppTheme.accentSky,
            decorationThickness: 2,
          ),
        ),
        if (unit.isNotEmpty)
          TextSpan(
            text: ' $unit',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
      ]),
    );
  }
}

/// Section header with optional action
class GcSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const GcSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.accentSky, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

/// A standard GemmaCare screen card with soft shadow
class GcCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? color;
  final Border? border;

  const GcCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppTheme.radiusLg,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );
  }
}
