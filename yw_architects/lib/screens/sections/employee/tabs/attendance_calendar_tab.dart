import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yw_architects/theme/app_theme.dart';
import 'package:yw_architects/services/attendance_service.dart';
import 'package:yw_architects/screens/sections/employee/widgets/attendance_widgets.dart';

class AttendanceCalendarTab extends StatefulWidget {
  final Function(String) onToast;
  const AttendanceCalendarTab({super.key, required this.onToast});

  @override
  State<AttendanceCalendarTab> createState() => _AttendanceCalendarTabState();
}

class _AttendanceCalendarTabState extends State<AttendanceCalendarTab> {
  DateTime _viewDate = DateTime.now();
  Map<int, List<dynamic>> _monthlyAttendance = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMonthlyData();
  }

  Future<void> _fetchMonthlyData() async {
    setState(() => _isLoading = true);
    try {
      final data = await AttendanceService.getAllEmployeesMonthlyAttendance(_viewDate.month, _viewDate.year);
      final Map<int, List<dynamic>> grouped = {};
      for (var record in data) {
        // Support common date keys: 'date', 'attendanceDate', 'checkInDate'
        final dateObj = record['date'] ?? record['attendanceDate'] ?? record['checkInDate'];
        if (dateObj == null) continue;
        
        final dateStr = dateObj.toString().split(' ')[0]; // Handle 'YYYY-MM-DD 10:00:00'
        if (dateStr.length < 8) continue; 
        
        try {
          // Flexible separator parsing: yyyy-MM-dd or dd-MM-yyyy or yyyy/MM/dd
          final parts = dateStr.contains('-') ? dateStr.split('-') : dateStr.split('/');
          // Try to find the day (usually the last or first part depending on format)
          int? day;
          if (parts.length >= 3) {
            if (parts[0].length == 4) day = int.parse(parts[2]); // yyyy-MM-dd
            else day = int.parse(parts[0]); // dd-MM-yyyy
          }
          
          if (day != null) {
            grouped.putIfAbsent(day, () => []).add(record);
          }
        } catch (_) {
          continue;
        }
      }
      if (!mounted) return;
      setState(() {
        _monthlyAttendance = grouped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      widget.onToast("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewDate = DateTime(_viewDate.year, _viewDate.month + delta);
      _fetchMonthlyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildDaysHeader(),
        Expanded(
          child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildCalendarGrid(),
        ),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('MMMM yyyy').format(_viewDate),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              Text('Monthly team activity', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const Spacer(),
          _MonthBtn(icon: Icons.chevron_left_rounded, onTap: () => _changeMonth(-1)),
          const SizedBox(width: 8),
          _MonthBtn(icon: Icons.chevron_right_rounded, onTap: () => _changeMonth(1)),
        ],
      ),
    );
  }

  Widget _buildDaysHeader() {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: days.map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))))).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_viewDate.year, _viewDate.month, 1);
    final daysInMonth = DateTime(_viewDate.year, _viewDate.month + 1, 0).day;
    final startOffset = (firstDayOfMonth.weekday - 1); // 0 = Mon

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.7, // Taller cells to prevent overflow
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 42, // 6 weeks
      itemBuilder: (context, i) {
        final dayNum = i - startOffset + 1;
        if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();

        final date = DateTime(_viewDate.year, _viewDate.month, dayNum);
        final records = _monthlyAttendance[dayNum] ?? [];
        return _CalendarDayCell(
          dayNum: dayNum,
          date: date,
          records: records,
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => AttendanceDetailsPopup(
                date: DateFormat('MMM dd, yyyy').format(date),
                records: records,
                onClose: () => Navigator.pop(context),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: const Color(0xff22c55e), label: 'Present'),
          const SizedBox(width: 16),
          _LegendItem(color: const Color(0xffef4444), label: 'Absent'),
          const SizedBox(width: 16),
          _LegendItem(color: const Color(0xfff59e0b), label: 'Other'),
        ],
      ),
    );
  }
}

class _MonthBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerHigh),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final int dayNum;
  final DateTime date;
  final List<dynamic> records;
  final VoidCallback onTap;

  const _CalendarDayCell({required this.dayNum, required this.date, required this.records, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isSunday = date.weekday == DateTime.sunday;
    
    // Background Color Logic:
    // Sunday -> Off (Grey)
    // Has Late -> Warning (Yellow)
    // Has Present (but no late) -> Success (Green)
    // Else -> None (White)
    Color bgColor = Colors.white;
    if (isSunday) {
      bgColor = AppColors.surfaceContainerLow.withOpacity(0.7);
    } else if (records.isNotEmpty) {
      final hasLate = records.any((r) => r['status']?.toString().toUpperCase() == 'LATE');
      final hasPresent = records.any((r) => r['status']?.toString().toUpperCase() == 'PRESENT');
      
      if (hasLate) {
        bgColor = const Color(0xfffff7ed); // Light Orange/Yellow
      } else if (hasPresent) {
        bgColor = const Color(0xfff0fdf4); // Light Green
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.2), 
            width: isToday ? 1.5 : 0.5
          ),
          boxShadow: isToday ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 4)] : null,
        ),
        child: Column(
          children: [
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: isToday ? const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle) : null,
              child: Text(
                '$dayNum', 
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w600, 
                  color: isToday ? Colors.white : (isSunday ? AppColors.outline : AppColors.onSurface)
                )
              ),
            ),
            const Spacer(),
            DayIndicator(records: records),
            const SizedBox(height: 6),
            if (isSunday) const Text('OFF', style: TextStyle(fontSize: 8, color: AppColors.outline, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
