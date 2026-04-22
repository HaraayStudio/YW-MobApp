import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

// ─── Stat Card ──────────────────────────────────────────────────────────────
class DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtext;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
    this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (subtext != null)
                Flexible(
                  child: Text(
                    subtext!,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Simple Bar Chart ────────────────────────────────────────────────────────
class DashboardBarChart extends StatelessWidget {
  final String title;
  final Map<String, double> data;
  final double height;

  const DashboardBarChart({
    super.key,
    required this.title,
    required this.data,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.values.isEmpty
        ? 1.0
        : data.values.reduce((v, e) => v > e ? v : e);

    return CardContainer(
      title: title,
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.entries.map((e) {
            final ratio = maxVal == 0 ? 0.0 : e.value / maxVal;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: 24,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            width: 24,
                            height: (height - 40) * ratio,
                            decoration: BoxDecoration(
                              gradient: goldGradient,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Donut Chart ────────────────────────────────────────────────────────────
class DashboardDonutChart extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  final List<Color> colors;

  const DashboardDonutChart({
    super.key,
    required this.title,
    required this.data,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (sum, v) => sum + v);
    final entries = data.entries.toList();

    return CardContainer(
      title: title,
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutPainter(
                data: data.values.toList(),
                colors: colors,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(entries.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        entries[i].value.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<int> data;
  final List<Color> colors;

  _DonutPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold(0, (sum, v) => sum + v);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -3.14159 / 2;
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * 3.14159;
      paint.color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + 0.05, // Small gap
        sweepAngle - 0.1,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── Quick Attendance Card ──────────────────────────────────────────────────
class DashboardAttendanceCard extends StatelessWidget {
  final String? checkIn;
  final String? checkOut;
  final String workingHours;
  final String currentTime;
  final String todayDate;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final bool isLoading;

  const DashboardAttendanceCard({
    super.key,
    this.checkIn,
    this.checkOut,
    required this.workingHours,
    required this.currentTime,
    required this.todayDate,
    required this.onCheckIn,
    required this.onCheckOut,
    this.isLoading = false,
  });

  String _formatTime(String raw) {
    try {
      final parts = raw.split(':');
      final hour = int.parse(parts[0]);
      final min = int.parse(parts[1]);
      final dt = DateTime(2000, 1, 1, hour, min);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCheckedIn = checkIn != null;
    final hasCheckedOut = checkOut != null;

    final inTime = hasCheckedIn ? _formatTime(checkIn!) : '--:--';
    final outTime = hasCheckedOut ? _formatTime(checkOut!) : '--:--';

    return CardContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      todayDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentTime,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'Live Time',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _timeBox(
                  'Check In',
                  inTime,
                  hasCheckedIn ? 'Success' : 'Pending',
                  hasCheckedIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timeBox(
                  'Check Out',
                  outTime,
                  hasCheckedOut ? 'Success' : 'Working...',
                  hasCheckedOut,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GoldGradientButton(
                  text: hasCheckedIn ? 'Checked In' : 'Check In',
                  icon: Icons.login_rounded,
                  verticalPadding: 12,
                  onTap: hasCheckedIn || isLoading ? null : onCheckIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GoldGradientButton(
                  text: hasCheckedOut ? 'Checked Out' : 'Check Out',
                  icon: Icons.logout_rounded,
                  verticalPadding: 12,
                  onTap: (!hasCheckedIn || hasCheckedOut || isLoading)
                      ? null
                      : onCheckOut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String label, String time, String sub, bool active) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: active
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: active
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
