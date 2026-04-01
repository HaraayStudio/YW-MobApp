import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Navigate out after 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface, // bg-surface: #f9fbec
      body: Stack(
        children: [
          // Background Architectual Elements (Subtle Textures)
          // radial-gradient(#d0c5b0 0.5px, transparent 0.5px) size 32x32
          Positioned.fill(
            child: Opacity(
              opacity: 0.20,
              child: CustomPaint(
                painter: _DotPainter(
                  color: const Color(0xFFD0C5B0),
                  spacing: 32.0,
                  radius: 1.0,
                ),
              ),
            ),
          ),
          
          // Architectural Blueprint Lines (Decorative Corner) - Bottom Right
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.10,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _CornerBlueprintPainter(color: AppColors.primary),
                ),
              ),
            ),
          ),

          // Central Branding Cluster
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseOpacity.value,
                  child: Transform.scale(
                    scale: _pulseScale.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Mark "YW"
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Y',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 140, // Match large text
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          letterSpacing: -5,
                          color: AppColors.outline, // Gray/Stone #7f7664
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-24, 0), // -ml-6 equivalent
                        child: Text(
                          'W',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 140,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            letterSpacing: -5,
                            color: AppColors.primaryContainer, // Gold/Yellow #b8952a
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Brand Name
                  Text(
                    'YW Architects',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24, // text-2xl
                      fontWeight: FontWeight.w700, // font-bold
                      letterSpacing: 4.8, // tracking-[0.2em] approx 0.2 * 24
                      color: AppColors.onSurface,
                    ).copyWith(height: 1.0),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description with side dividers
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 1, width: 32, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      const SizedBox(width: 16),
                      Text(
                        'MASTERY IN STRUCTURE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 4.0, // tracking-[0.4em]
                          color: AppColors.outline,
                        ).copyWith(height: 1.0),
                      ),
                      const SizedBox(width: 16),
                      Container(height: 1, width: 32, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Footer / Loading Area
          Positioned(
            left: 0,
            right: 0,
            bottom: 64, // bottom-16 equivalent
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular Progress Indicator (ywGold / Primary-Container)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primaryContainer, // text-primary-container
                    backgroundColor: AppColors.surfaceContainerHigh, // text-surface-container-high
                  ),
                ),
                const SizedBox(height: 24),
                // Versioning / Meta
                Text(
                  'SYSTEM INITIALIZING',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0, // tracking-widest
                    color: AppColors.outline.withValues(alpha: 0.5),
                  ).copyWith(height: 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double radius;

  _DotPainter({required this.color, required this.spacing, required this.radius});

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
  bool shouldRepaint(covariant _DotPainter oldDelegate) {
    return color != oldDelegate.color || spacing != oldDelegate.spacing || radius != oldDelegate.radius;
  }
}

class _CornerBlueprintPainter extends CustomPainter {
  final Color color;
  _CornerBlueprintPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Based on matching the SVG paths from HTML
    // M0 199H200V0 -> Line from Left-Bottom to Right-Bottom to Right-Top
    final path1 = Path()
      ..moveTo(0, size.height - 1)
      ..lineTo(size.width, size.height - 1)
      ..lineTo(size.width, 0);
    canvas.drawPath(path1, paint);

    // M20 199V179H0 -> Smaller line
    final path2 = Path()
      ..moveTo(20, size.height - 1)
      ..lineTo(20, size.height - 21)
      ..lineTo(0, size.height - 21);
    canvas.drawPath(path2, paint);

    // circle cx=200, cy=0, r=4 (top right corner of the SVG)
    canvas.drawCircle(Offset(size.width, 0), 4, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
