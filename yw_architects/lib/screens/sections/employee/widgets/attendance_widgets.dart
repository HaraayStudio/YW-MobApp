import 'package:flutter/material.dart';
import 'package:yw_architects/theme/app_theme.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const AttendanceSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color.withOpacity(0.7)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class AttendanceStatusBadge extends StatelessWidget {
  final String status;
  const AttendanceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: cfg.dot, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(cfg.label, style: TextStyle(color: cfg.color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class StatusConfig {
  final String label;
  final Color bg;
  final Color color;
  final Color dot;
  final String icon;

  StatusConfig({required this.label, required this.bg, required this.color, required this.dot, required this.icon});
}

StatusConfig _getStatusConfig(String status) {
  switch (status.toUpperCase()) {
    case 'PRESENT':
      return StatusConfig(label: 'Present', bg: const Color(0xffdcfce7), color: const Color(0xff14532d), dot: const Color(0xff22c55e), icon: '✓');
    case 'ABSENT':
      return StatusConfig(label: 'Absent', bg: const Color(0xfffee2e2), color: const Color(0xff991b1b), dot: const Color(0xffef4444), icon: '✕');
    case 'HALF_DAY':
      return StatusConfig(label: 'Half Day', bg: const Color(0xfffef3c7), color: const Color(0xff92400e), dot: const Color(0xfff59e0b), icon: '½');
    case 'LATE':
      return StatusConfig(label: 'Late', bg: const Color(0xfffff7ed), color: const Color(0xff9a3412), dot: const Color(0xfff97316), icon: '⏰');
    case 'ON_LEAVE':
      return StatusConfig(label: 'On Leave', bg: const Color(0xffede9fe), color: const Color(0xff4c1d95), dot: const Color(0xff7c3aed), icon: '⏸');
    case 'HOLIDAY':
      return StatusConfig(label: 'Holiday', bg: const Color(0xffdbeafe), color: const Color(0xff1e40af), dot: const Color(0xff3b82f6), icon: '🎉');
    case 'WORK_FROM_HOME':
      return StatusConfig(label: 'WFH', bg: const Color(0xfff0fdf4), color: const Color(0xff166534), dot: const Color(0xff4ade80), icon: '🏠');
    default:
      return StatusConfig(label: 'Unmarked', bg: AppColors.surfaceContainerHigh, color: AppColors.onSurfaceVariant, dot: AppColors.outline, icon: '?');
  }
}

class DayIndicator extends StatelessWidget {
  final List<dynamic> records;
  const DayIndicator({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox.shrink();
    final present = records.where((r) => r['status'] == 'PRESENT').length;
    final absent = records.where((r) => r['status'] == 'ABSENT').length;
    final other = records.length - present - absent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (present > 0) _Dot(color: const Color(0xff22c55e)),
        if (absent > 0) _Dot(color: const Color(0xffef4444)),
        if (other > 0) _Dot(color: const Color(0xfff59e0b)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class AttendanceDetailsPopup extends StatelessWidget {
  final String date;
  final List<dynamic> records;
  final VoidCallback onClose;

  const AttendanceDetailsPopup({super.key, required this.date, required this.records, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Attendance: $date', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No records for this day')))
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: records.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = records[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(r['user']?['fullName'] ?? 'Unknown Employee', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                        AttendanceStatusBadge(status: r['status'] ?? ''),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
