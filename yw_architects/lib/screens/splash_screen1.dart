import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// NEW CONSTRUCTION SPLASH SCREEN
/// ─────────────────────────────────────────────────────────────
/// Features:
/// 1. SVG-style line drawing animation using CustomPainter.
/// 2. Staggered construction sequence matching HTML reference exactly.
/// 3. Brand surface styling (Dot grid, Gold accent bars).
/// 4. Synchronized progress bar for workspace initialization.
/// ─────────────────────────────────────────────────────────────

class SplashScreen1 extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen1({super.key, required this.onComplete});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Staggered Animations (mapped to HTML timings)
  late final Animation<double> _groundLine;     // 0.5s start
  late final Animation<double> _foundation;     // 1.1s start
  late final Animation<double> _structure;      // 1.5s start
  late final Animation<double> _roof;           // 1.9s start
  late final Animation<double> _floors;         // 2.0s start
  late final Animation<double> _parapet;        // 2.2s start
  late final Animation<double> _windows;        // 2.3s start
  late final Animation<double> _penthouse;      // 2.7s start
  late final Animation<double> _flag;           // 3.0s start
  late final Animation<double> _trees;          // 3.15s start
  late final Animation<double> _brandFade;      // 3.6s start
  late final Animation<double> _progressBar;    // Over 3.5s

  static const _totalDuration = Duration(milliseconds: 5000);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _ctrl = AnimationController(vsync: this, duration: _totalDuration);

    // Ground line: 0.11 - 0.25 (finish by 1.25s)
    _groundLine = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.11, 0.25, curve: Curves.easeOut),
    );

    // Foundation: 0.24 - 0.35 (finish by 1.75s)
    _foundation = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.24, 0.35, curve: Curves.easeOut),
    );

    // Structure (Walls): 0.33 - 0.42 (finish by 2.1s)
    _structure = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.33, 0.42, curve: Curves.easeOut),
    );

    // Floor lines: 0.40 - 0.50 (finish by 2.5s)
    _floors = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.40, 0.50, curve: Curves.easeOut),
    );

    // Roof: 0.38 - 0.48 (finish by 2.4s)
    _roof = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.38, 0.48, curve: Curves.easeOut),
    );

    // Parapet: 0.46 - 0.58 (finish by 2.9s)
    _parapet = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.46, 0.58, curve: Curves.easeOut),
    );

    // Windows: 0.48 - 0.68 (finish by 3.4s)
    _windows = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.48, 0.68, curve: Curves.easeOut),
    );

    // Penthouse: 0.58 - 0.72 (finish by 3.6s)
    _penthouse = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.58, 0.72, curve: Curves.easeOut),
    );

    // Flag: 0.65 - 0.75 (finish by 3.75s)
    _flag = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 0.75, curve: Curves.easeOut),
    );

    // Trees: 0.68 - 0.78 (finish by 3.9s)
    _trees = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.68, 0.78, curve: Curves.easeOut),
    );

    // Branding: 0.75 - 0.95 (finish by 4.75s)
    _brandFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.75, 0.95, curve: Curves.easeIn),
    );

    // Progress bar: 0.11 - 0.90 (finish by 4.5s)
    _progressBar = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.11, 0.90, curve: Curves.linear),
      ),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait a small beat at the end state before signaling completion
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) widget.onComplete();
        });
      }
    });

    // Added a small delay before starting to ensure the screen is fully visible
    // after the native splash screen transition.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBEC),
      body: Stack(
        children: [
          // ── Dot Grid ───────────────────────────────────────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _DotGridPainter(
                  color: const Color(0xFFC8BAA0).withValues(alpha: 0.25),
                  spacing: 24.0,
                ),
              ),
            ),
          ),

          // ── Accent Bars ────────────────────────────────────────────────────
          _buildAccentBar(left: true, delay: 0.3),
          _buildAccentBar(left: false, delay: 0.5),

          // ── Main Content ───────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Building Animation
                  SizedBox(
                    width: 320,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _BuildingPainter(
                            ground: _groundLine.value,
                            foundation: _foundation.value,
                            structure: _structure.value,
                            floors: _floors.value,
                            roof: _roof.value,
                            parapet: _parapet.value,
                            windows: _windows.value,
                            penthouse: _penthouse.value,
                            flag: _flag.value,
                            trees: _trees.value,
                            glow: _brandFade.value,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Branding
                  FadeTransition(
                    opacity: _brandFade,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/icon/yw_logo_final.png',
                          width: 48,
                          height: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'YW ARCHITECTS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 5.0,
                            color: const Color(0xFF1A1D14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 1,
                              color: const Color(
                                0xFFD0C5B0,
                              ).withValues(alpha: 0.6),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'DESIGN · BUILD · INSPIRE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3.0,
                                  color: const Color(0xFF7F7664),
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 1,
                              color: const Color(
                                0xFFD0C5B0,
                              ).withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Progress Bar ───────────────────────────────────────────────────
          Positioned(
            bottom: 48,
            left: 60,
            right: 60,
            child: FadeTransition(
              opacity: _brandFade,
              child: AnimatedBuilder(
                animation: _progressBar,
                builder: (context, _) => Column(
                  children: [
                    Container(
                      height: 2,
                      width: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E4D5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressBar.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF755B00), Color(0xFFB8952A)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'INITIALIZING WORKSPACE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: const Color(0xFF7F7664).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentBar({required bool left, required double delay}) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      width: 3,
      child: FadeTransition(
        opacity: _ctrl.drive(
          CurveTween(curve: Interval(delay, delay + 0.2, curve: Curves.easeIn)),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFFB8952A).withValues(alpha: 0.8),
                const Color(0xFF755B00),
                Colors.transparent,
              ],
              stops: const [0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Building Painter ─────────────────────────────────────────────────────────

class _BuildingPainter extends CustomPainter {
  final double ground;
  final double foundation;
  final double structure;
  final double floors;
  final double roof;
  final double parapet;
  final double windows;
  final double penthouse;
  final double flag;
  final double trees;
  final double glow;

  _BuildingPainter({
    required this.ground,
    required this.foundation,
    required this.structure,
    required this.floors,
    required this.roof,
    required this.parapet,
    required this.windows,
    required this.penthouse,
    required this.flag,
    required this.trees,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ground Line
    if (ground > 0) {
      final paint = Paint()
        ..color = const Color(0xFFB8952A)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(20, 258)
        ..lineTo(300, 258);
      _drawAnimatedPath(canvas, path, paint, ground);
    }

    // 2. Foundation
    if (foundation > 0) {
      final paint = Paint()
        ..color = const Color(0xFF755B00)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(60, 245, 200, 13),
            const Radius.circular(1),
          ),
        );
      _drawAnimatedPath(canvas, path, paint, foundation);
    }

    // 3. Main Structure (Walls)
    if (structure > 0) {
      final paint = Paint()
        ..color = const Color(0xFF755B00)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Left Wall
      final leftWall = Path()
        ..moveTo(72, 245)
        ..lineTo(72, 90);
      _drawAnimatedPath(canvas, leftWall, paint, structure);

      // Right Wall
      final rightWall = Path()
        ..moveTo(248, 245)
        ..lineTo(248, 90);
      _drawAnimatedPath(canvas, rightWall, paint, structure);
    }

    // 4. Floor lines
    if (floors > 0) {
      final dividerPaint = Paint()
        ..color = const Color(0xFFD0C5B0).withValues(alpha: 0.6)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      final floorYs = [205.0, 165.0, 128.0];
      for (var y in floorYs) {
        final fPath = Path()
          ..moveTo(72, y)
          ..lineTo(248, y);
        _drawAnimatedPath(canvas, fPath, dividerPaint, floors);
      }
    }

    // 5. Roof base
    if (roof > 0) {
      final paint = Paint()
        ..color = const Color(0xFF755B00)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(72, 90)
        ..lineTo(248, 90);
      _drawAnimatedPath(canvas, path, paint, roof);
    }

    // 6. Parapet
    if (parapet > 0) {
      final paint = Paint()
        ..color = const Color(0xFFB8952A)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(72, 90)
        ..lineTo(72, 74)
        ..lineTo(248, 74)
        ..lineTo(248, 90);
      _drawAnimatedPath(canvas, path, paint, parapet);
    }

    // 7. Penthouse
    if (penthouse > 0) {
      final paint = Paint()
        ..color = const Color(0xFFB8952A)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(130, 52, 60, 22),
            const Radius.circular(1),
          ),
        );
      _drawAnimatedPath(canvas, path, paint, penthouse);

      // Penthouse windows
      if (penthouse > 0.5) {
        final pWinPaint = Paint()
          ..color = const Color(0xFF755B00)
          ..strokeWidth = 0.9
          ..style = PaintingStyle.stroke;
        final p1 = Path()..addRect(const Rect.fromLTWH(138, 57, 14, 11));
        final p2 = Path()..addRect(const Rect.fromLTWH(168, 57, 14, 11));
        _drawAnimatedPath(canvas, p1, pWinPaint, (penthouse - 0.5) * 2);
        _drawAnimatedPath(canvas, p2, pWinPaint, (penthouse - 0.5) * 2);
      }
    }

    // 8. Windows
    if (windows > 0) {
      final paint = Paint()
        ..color = const Color(0xFFB8952A)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      final fill = Paint()
        ..color = const Color(0xFFB8952A).withValues(alpha: 0.06 * windows)
        ..style = PaintingStyle.fill;

      // Ground floor windows & door
      final gWins = [90.0, 124.0, 184.0, 218.0];
      for (var x in gWins) {
        final r = Rect.fromLTWH(x, 215, 22, 24);
        canvas.drawRect(r, fill);
        _drawAnimatedPath(canvas, Path()..addRect(r), paint, windows);
      }
      // Door
      final doorRect = const Rect.fromLTWH(150, 221, 20, 24);
      canvas.drawRect(doorRect, Paint()..color = const Color(0xFF755B00).withValues(alpha: 0.08 * windows));
      _drawAnimatedPath(canvas, Path()..addRect(doorRect), Paint()..color = const Color(0xFF755B00)..strokeWidth = 1.2..style = PaintingStyle.stroke, windows);

      // Floor 2 & 3 (rows of 5)
      final floorsY = [175.0, 137.0];
      final winsX = [85.0, 115.0, 150.0, 185.0, 215.0];
      for (var y in floorsY) {
        for (var x in winsX) {
          final r = Rect.fromLTWH(x, y, 20, 20);
          canvas.drawRect(r, fill);
          _drawAnimatedPath(canvas, Path()..addRect(r), paint, windows);
        }
      }

      // Floor 4 (top row of 3)
      final topWinsX = [100.0, 150.0, 200.0];
      for (var x in topWinsX) {
        final r = Rect.fromLTWH(x, 97, 20, 22);
        canvas.drawRect(r, fill);
        _drawAnimatedPath(canvas, Path()..addRect(r), paint, windows);
      }
    }

    // 9. Flag
    if (flag > 0) {
      final paint = Paint()
        ..color = const Color(0xFF755B00)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      // Pole
      canvas.drawLine(const Offset(160, 52), const Offset(160, 36), paint);
      // Flag
      final flagPath = Path()
        ..moveTo(160, 36)
        ..lineTo(174, 40)
        ..lineTo(160, 44)
        ..close();
      _drawAnimatedPath(canvas, flagPath, Paint()..color = const Color(0xFFB8952A)..strokeWidth = 1..style = PaintingStyle.stroke, flag);
      if (flag > 0.8) {
        canvas.drawPath(flagPath, Paint()..color = const Color(0xFFB8952A).withValues(alpha: 0.15));
      }
    }

    // 10. Trees
    if (trees > 0) {
      final paint = Paint()
        ..color = const Color(0xFF7F7664).withValues(alpha: 0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      // Trunk & Canopy (Left)
      canvas.drawLine(const Offset(38, 258), const Offset(38, 228), paint);
      _drawAnimatedPath(canvas, Path()..addOval(const Rect.fromLTWH(26, 204, 24, 28)), paint, trees);

      // Trunk & Canopy (Right)
      canvas.drawLine(const Offset(282, 258), const Offset(282, 228), paint);
      _drawAnimatedPath(canvas, Path()..addOval(const Rect.fromLTWH(270, 204, 24, 28)), paint, trees);
    }

    // 11. Glow & Blueprint lines
    if (glow > 0) {
      // Dimension line
      final dimPaint = Paint()
        ..color = const Color(0xFFD0C5B0).withValues(alpha: 0.3 * glow)
        ..strokeWidth = 0.5;
      canvas.drawLine(const Offset(72, 64), const Offset(248, 64), dimPaint);
      canvas.drawLine(const Offset(72, 60), const Offset(72, 68), dimPaint);
      canvas.drawLine(const Offset(248, 60), const Offset(248, 68), dimPaint);

      // Centerline
      final centerPaint = Paint()
        ..color = const Color(0xFFB8952A).withValues(alpha: 0.15 * glow)
        ..strokeWidth = 0.5;
      _drawDashedLine(canvas, const Offset(160, 36), const Offset(160, 258), centerPaint);

      // Building Fill
      final fillPaint = Paint()
        ..color = const Color(0xFFB8952A).withValues(alpha: 0.03 * glow)
        ..style = PaintingStyle.fill;
      canvas.drawRect(const Rect.fromLTWH(72, 90, 176, 155), fillPaint);
    }
  }

  void _drawAnimatedPath(Canvas canvas, Path path, Paint paint, double val) {
    for (final metric in path.computeMetrics()) {
      final extract = metric.extractPath(0.0, metric.length * val);
      canvas.drawPath(extract, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 6.0;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += (dashWidth + dashSpace)) {
      canvas.drawLine(
        p1 + Offset(0, i),
        p1 + Offset(0, i + dashWidth),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BuildingPainter oldDelegate) => true;
}

// ── Background Dots ──────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _DotGridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
