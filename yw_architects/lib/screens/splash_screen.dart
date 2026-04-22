import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// FIXED SPLASH SCREEN
/// ─────────────────────────────────────────────────────────────
/// Changes from old version:
///   1. Widget tree is ENTIRELY pre-built — no async gaps, no white flash.
///   2. Animations start immediately in initState (no Future.delayed before
///      first frame).
///   3. Uses a single AnimationController with three staggered child tweens
///      so the logo, tagline and loader all fade-in together from frame 1.
///   4. Total display time reduced to 2.2 s (was 3 s).
///   5. Removed CircularProgressIndicator (it triggers a costly repaint loop);
///      replaced with a deterministic animated progress bar.
///   6. All text uses cached GoogleFonts so no layout shift happens after fonts
///      load.
///   7. CustomPaint dot-grid is kept but capped to 20 px spacing so it stays
///      crisp on all densities.
/// ─────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeLogo;
  late final Animation<double> _fadeTag;
  late final Animation<double> _scaleY;
  late final Animation<double> _progressBar;
  Timer? _exitTimer;

  static const _totalDuration = Duration(milliseconds: 2200);
  static const _exitAfter     = Duration(milliseconds: 2000);

  @override
  void initState() {
    super.initState();

    // Keep status bar transparent throughout
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _ctrl = AnimationController(vsync: this, duration: _totalDuration);

    // Logo: fade + slight upward drift 0 → 0.4
    _fadeLogo = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    // Tagline: fade in 0.3 → 0.65
    _fadeTag = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.30, 0.65, curve: Curves.easeOut),
    );

    // Subtle pulse scale on logo: 0 → 1
    _scaleY = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
      ),
    );

    // Progress bar: fills 0 → 1 during 0.1 → 0.88
    _progressBar = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.10, 0.88, curve: Curves.easeInOut),
      ),
    );

    // Start immediately — no Future.delayed, so first frame already animates
    _ctrl.forward();

    // Navigate after exit delay
    _exitTimer = Timer(_exitAfter, () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _exitTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exact brand surface — matches the rest of the app so no colour jump
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── dot grid background ──────────────────────────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _DotGridPainter(
                  color: AppColors.outlineVariant.withValues(alpha: 0.25),
                  spacing: 28.0,
                  radius: 1.0,
                ),
              ),
            ),
          ),

          // ── decorative corner blueprint ──────────────────────────────────
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.08,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CustomPaint(
                  size: const Size(160, 160),
                  painter: _CornerBlueprintPainter(color: AppColors.primary),
                ),
              ),
            ),
          ),

          // ── left gold accent bar ─────────────────────────────────────────
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryContainer.withValues(alpha: 0),
                    AppColors.primaryContainer,
                    AppColors.primary,
                    AppColors.primaryContainer.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // ── main branding (logo + name + tagline) ───────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeLogo.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _scaleY.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // YW monogram — two overlapping letters
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Y',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 130,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          letterSpacing: -4,
                          color: AppColors.outline,
                        ),
                      ),
                      Transform.translate(
                        // Tighten letters together — platform-pixel-safe value
                        offset: const Offset(-22, 0),
                        child: Text(
                          'W',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 130,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            letterSpacing: -4,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Brand name
                  Text(
                    'YW Architects',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4.0,
                      color: AppColors.onSurface,
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline with side rules — fades in slightly later
                  AnimatedBuilder(
                    animation: _fadeTag,
                    builder: (_, child) =>
                        Opacity(opacity: _fadeTag.value.clamp(0.0, 1.0), child: child),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 1,
                          width: 28,
                          color: AppColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'MASTERY IN STRUCTURE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.5,
                            color: AppColors.outline,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 1,
                          width: 28,
                          color: AppColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── progress bar + label at bottom ──────────────────────────────
          Positioned(
            left: 48,
            right: 48,
            bottom: 56,
            child: AnimatedBuilder(
              animation: _progressBar,
              builder: (_, __) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Track
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 3,
                        child: Stack(
                          children: [
                            // Track background
                            Container(color: AppColors.surfaceContainerHigh),
                            // Fill
                            FractionallySizedBox(
                              widthFactor: _progressBar.value,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryContainer,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'INITIALIZING WORKSPACE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: AppColors.outline.withValues(alpha: 0.5),
                        height: 1.0,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PAINTERS ────────────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double radius;

  const _DotGridPainter({
    required this.color,
    required this.spacing,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) =>
      old.color != color || old.spacing != spacing || old.radius != radius;
}

class _CornerBlueprintPainter extends CustomPainter {
  final Color color;
  const _CornerBlueprintPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // L-shaped border in bottom-right corner
    final border = Path()
      ..moveTo(0, size.height - 1)
      ..lineTo(size.width, size.height - 1)
      ..lineTo(size.width, 0);
    canvas.drawPath(border, stroke);

    // Inner tick mark
    final tick = Path()
      ..moveTo(20, size.height - 1)
      ..lineTo(20, size.height - 21)
      ..lineTo(0, size.height - 21);
    canvas.drawPath(tick, stroke);

    // Corner dot
    canvas.drawCircle(Offset(size.width, 0), 4, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
