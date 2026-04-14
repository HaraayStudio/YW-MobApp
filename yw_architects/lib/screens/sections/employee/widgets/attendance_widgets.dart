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
    
    int present = 0;
    int absent = 0;
    int lateCount = 0;
    int other = 0;
    
    for (var r in records) {
      final status = (r['status']?.toString() ?? '').toUpperCase();
      if (status == 'PRESENT') present++;
      else if (status == 'LATE') lateCount++;
      else if (status == 'ABSENT') absent++;
      else other++;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (present > 0 || lateCount > 0) 
          _StatMini(
            count: present + lateCount, 
            color: lateCount > 0 ? const Color(0xfff59e0b) : const Color(0xff22c55e)
          ),
        if (absent > 0) 
          const SizedBox(width: 4),
        if (absent > 0)
          _StatMini(count: absent, color: const Color(0xffef4444)),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final int count;
  final Color color;
  const _StatMini({required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

class AttendanceDetailsPopup extends StatefulWidget {
  final String date;
  final List<dynamic> records;
  final VoidCallback onClose;

  const AttendanceDetailsPopup({super.key, required this.date, required this.records, required this.onClose});

  @override
  State<AttendanceDetailsPopup> createState() => _AttendanceDetailsPopupState();
}

class _AttendanceDetailsPopupState extends State<AttendanceDetailsPopup> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.records.where((r) {
      final user = r['user'] as Map<String, dynamic>?;
      final name = (user?['fullName'] ?? user?['name'] ?? '${user?['firstName'] ?? ''} ${user?['lastName'] ?? ''}').toString().toLowerCase();
      return name.trim().contains(_search.toLowerCase());
    }).toList();

    final presentCount = widget.records.where((r) => r['status']?.toString().toUpperCase() == 'PRESENT').length;
    final lateCount = widget.records.where((r) => r['status']?.toString().toUpperCase() == 'LATE').length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                      Text('${widget.records.length} employee records', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _CompactStatBadge(label: 'Present: $presentCount', bg: const Color(0xffdcfce7), fg: const Color(0xff14532d), icon: Icons.check_rounded),
                const SizedBox(width: 12),
                if (lateCount > 0)
                  _CompactStatBadge(label: 'Late: $lateCount', bg: const Color(0xfffff7ed), fg: const Color(0xff9a3412), icon: Icons.alarm_rounded),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xffE2E8F0))),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  hintText: 'Search employee...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: const Color(0xfff8fafc),
            child: const Row(
              children: [
                SizedBox(width: 30, child: Text('#', style: _hStyle)),
                Expanded(flex: 3, child: Text('EMPLOYEE', style: _hStyle)),
                Expanded(flex: 2, child: Text('STATUS', style: _hStyle, textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('CHECK-IN', style: _hStyle, textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Table Content
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final r = filtered[i];
                final status = (r['status']?.toString() ?? 'UNMARKED').toUpperCase();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1)))),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: AppColors.outline))),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            _SmartAvatar(
                              name: (r['user']?['fullName'] ?? r['user']?['name'] ?? '${r['user']?['firstName'] ?? ''} ${r['user']?['lastName'] ?? ''}').toString(), 
                              imageUrl: r['user']?['profilePicUrl']
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                (r['user']?['fullName'] ?? r['user']?['name'] ?? '${r['user']?['firstName'] ?? ''} ${r['user']?['lastName'] ?? ''}').toString() == ' ' ? 'Unknown' : (r['user']?['fullName'] ?? r['user']?['name'] ?? '${r['user']?['firstName'] ?? ''} ${r['user']?['lastName'] ?? ''}').toString().trim(), 
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), 
                                overflow: TextOverflow.ellipsis
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Center(child: _StatusPill(status: status))),
                      Expanded(flex: 2, child: Text(r['checkIn']?.toString() ?? '--', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                    ],
                  ),
                );
              },
            ),
          ),
          // Bottom Close
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 120,
              child: OutlinedButton(
                onPressed: widget.onClose,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xffE2E8F0)),
                ),
                child: const Text('Close', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _hStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant, letterSpacing: 1.1);

class _CompactStatBadge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final IconData icon;
  const _CompactStatBadge({required this.label, required this.bg, required this.fg, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});
  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xfff1f5f9), dot = const Color(0xff94a3b8), fg = const Color(0xff475569);
    if (status == 'PRESENT') {
      bg = const Color(0xffdcfce7); dot = const Color(0xff22c55e); fg = const Color(0xff14532d);
    } else if (status == 'LATE') {
      bg = const Color(0xfffff7ed); dot = const Color(0xfff59e0b); fg = const Color(0xff9a3412);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(status, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SmartAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  const _SmartAvatar({required this.name, this.imageUrl});
  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return CircleAvatar(radius: 12, backgroundImage: NetworkImage(imageUrl!));
    }
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(1).join();
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
      child: Center(child: Text(initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary))),
    );
  }
}
