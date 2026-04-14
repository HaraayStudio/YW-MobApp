import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import '../../services/attendance_service.dart';

class AttendanceSection extends StatefulWidget {
  final AppUser user;
  final Function(String) onToast;

  const AttendanceSection({super.key, required this.user, required this.onToast});

  @override
  State<AttendanceSection> createState() => _AttendanceSectionState();
}

class _AttendanceSectionState extends State<AttendanceSection> {
  bool _isLoading = true;
  List<dynamic> _monthlyRecords = [];
  DateTime _currentMonth = DateTime.now();
  Timer? _clockTimer;
  String _currentTimeString = "";

  @override
  void initState() {
    super.initState();
    _currentTimeString = DateFormat('hh:mm:ss a').format(DateTime.now());
    _startClock();
    _fetchData();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTimeString = DateFormat('hh:mm:ss a').format(DateTime.now());
        });
      }
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final records = await AttendanceService.getMyMonthlyAttendance(
      _currentMonth.month,
      _currentMonth.year,
    );
    if (mounted) {
      setState(() {
        _monthlyRecords = records;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? get _todayRecord {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      return _monthlyRecords.firstWhere((r) => r['attendanceDate'] == todayStr);
    } catch (_) {
      return null;
    }
  }

  bool get _hasCheckedIn => _todayRecord?['checkIn'] != null;
  bool get _hasCheckedOut => _todayRecord?['checkOut'] != null;

  Future<void> _handleAction() async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('HH:mm:ss').format(now);

    bool success = false;
    if (!_hasCheckedIn) {
      success = await AttendanceService.recordMyCheckIn(dateStr, timeStr);
      if (success) widget.onToast("Check-in recorded at ${DateFormat('hh:mm a').format(now)}");
    } else if (!_hasCheckedOut) {
      // Default to PRESENT for checkout
      success = await AttendanceService.recordMyCheckOut(dateStr, timeStr, "PRESENT");
      if (success) widget.onToast("Check-out recorded at ${DateFormat('hh:mm a').format(now)}");
    }

    if (success) {
      _fetchData();
    } else {
      widget.onToast("Action failed. Please try again.");
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta, 1);
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _monthlyRecords.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final today = DateTime.now();
    final todayFormatted = DateFormat('EEEE, d MMMM').format(today);
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    // Calculate stats
    int present = _monthlyRecords.where((r) => r['status'] == 'PRESENT').length;
    int absent = _monthlyRecords.where((r) => r['status'] == 'ABSENT').length;
    int late = _monthlyRecords.where((r) => r['status'] == 'LATE').length;
    int leave = _monthlyRecords.where((r) => r['status'] == 'ON_LEAVE').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Attendance',
            subtitle: monthName,
            action: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                  onPressed: () => _changeMonth(-1),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Check In/Out Card
          _buildCheckActionCard(todayFormatted),
          const SizedBox(height: 24),

          // Monthly Summary Row
          _buildSummaryStats(present, absent, late, leave),
          const SizedBox(height: 24),

          // Visual Calendar Grid
          _buildAttendanceGrid(),
          const SizedBox(height: 24),

          // Recent Activity Log
          const Text('Daily Logs', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 12),
          _buildLogsList(),
        ],
      ),
    );
  }

  Widget _buildCheckActionCard(String todayFormatted) {
    final rec = _todayRecord;
    final inTime = rec?['checkIn'] != null ? _formatTime(rec!['checkIn']) : '--:--';
    final outTime = rec?['checkOut'] != null ? _formatTime(rec!['checkOut']) : '--:--';

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                  Text(todayFormatted, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_currentTimeString, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const Text('Live Time', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _timeBox('Check In', inTime, _hasCheckedIn ? 'Success' : 'Pending', _hasCheckedIn)),
              const SizedBox(width: 12),
              Expanded(child: _timeBox('Check Out', outTime, _hasCheckedOut ? 'Success' : 'Working...', _hasCheckedOut)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GoldGradientButton(
                  text: _hasCheckedIn ? 'Checked In' : 'Check In',
                  icon: Icons.login_rounded,
                  verticalPadding: 12,
                  onTap: _hasCheckedIn ? null : _handleAction,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GoldGradientButton(
                  text: _hasCheckedOut ? 'Checked Out' : 'Check Out',
                  icon: Icons.logout_rounded,
                  verticalPadding: 12,
                  onTap: (!_hasCheckedIn || _hasCheckedOut) ? null : _handleAction,
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
        color: active ? AppColors.primary.withOpacity(0.05) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: active ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
          Text(sub, style: TextStyle(fontSize: 10, color: active ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(int p, int a, int l, int le) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Month Overview', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface, fontSize: 15)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(p.toString(), 'Present', AppColors.chipDoneFg, AppColors.chipDoneBg),
              _statItem(l.toString(), 'Late', const Color(0xFFB45309), const Color(0xFFFEF3C7)),
              _statItem(a.toString(), 'Absent', AppColors.error, const Color(0xFFFEE2E2)),
              _statItem(le.toString(), 'Leave', const Color(0xFF4338CA), const Color(0xFFE0E7FF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, Color fg, Color bg) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg))),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildAttendanceGrid() {
    final totalDays = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).getDate();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attendance Grid', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        const SizedBox(height: 12),
        CardContainer(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: totalDays,
            itemBuilder: (context, index) {
              final dayNum = index + 1;
              final dateStr = DateFormat('yyyy-MM-dd').format(DateTime(_currentMonth.year, _currentMonth.month, dayNum));
              Map<String, dynamic>? record;
              try {
                record = _monthlyRecords.firstWhere((r) => r['attendanceDate'] == dateStr);
              } catch (_) {}

              Color color = AppColors.surfaceContainerHigh;
              if (record != null) {
                switch (record['status']) {
                  case 'PRESENT': color = AppColors.chipDoneFg; break;
                  case 'ABSENT':  color = AppColors.error; break;
                  case 'LATE':    color = const Color(0xFFF59E0B); break;
                  case 'ON_LEAVE': color = const Color(0xFF6366F1); break;
                  case 'WORK_FROM_HOME': color = const Color(0xFF10B981); break;
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    dayNum.toString(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color == AppColors.surfaceContainerHigh ? AppColors.onSurfaceVariant : color),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogsList() {
    if (_monthlyRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.onSurfaceVariant.withOpacity(0.3)),
              const SizedBox(height: 12),
              const Text('No dynamic records for this month', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    // Sort by date descending
    final sorted = List.from(_monthlyRecords)..sort((a, b) => b['attendanceDate'].compareTo(a['attendanceDate']));
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length.clamp(0, 15), 
      itemBuilder: (context, index) {
        final r = sorted[index];
        final date = DateTime.parse(r['attendanceDate']);
        final dayStr = DateFormat('dd').format(date);
        final dowStr = DateFormat('EEE').format(date);
        
        String specialLabel = "";
        if (r['attendanceDate'] == todayStr) specialLabel = "(Today)";
        else if (r['attendanceDate'] == yesterdayStr) specialLabel = "(Yesterday)";
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CardContainer(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Text(dayStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                      Text(dowStr, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['checkIn'] != null ? '${_formatTime(r['checkIn'])} → ${r['checkOut'] != null ? _formatTime(r['checkOut']) : 'Working'}' : 'Not Logged',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                      Text('${r['status'] ?? '—'} $specialLabel', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                StatusChip(status: r['status'] ?? 'N/A'),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(String raw) {
    // "HH:mm:ss" -> "hh:mm a"
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
}

extension DateTimeExt on DateTime {
  int getDate() => DateTime(year, month + 1, 0).day;
}
