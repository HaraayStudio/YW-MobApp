import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yw_architects/theme/app_theme.dart';
import 'package:yw_architects/widgets/common_widgets.dart';
import 'package:yw_architects/services/employee_service.dart';
import 'package:yw_architects/services/attendance_service.dart';
import 'package:yw_architects/screens/sections/employee/models/employee_models.dart';
import 'package:yw_architects/screens/sections/employee/widgets/attendance_widgets.dart';

class DailyAttendanceTab extends StatefulWidget {
  final Function(String) onToast;
  const DailyAttendanceTab({super.key, required this.onToast});

  @override
  State<DailyAttendanceTab> createState() => _DailyAttendanceTabState();
}

class _DailyAttendanceTabState extends State<DailyAttendanceTab> {
  DateTime _selectedDate = DateTime.now();
  List<EmployeeModel> _employees = [];
  Map<int, Map<String, dynamic>> _attendanceMap = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final empsData = await EmployeeService.getAllEmployees();
      final todayData = await AttendanceService.getTodayAttendance();
      
      final emps = empsData.map((e) => EmployeeModel.fromJson(e)).toList();
      final Map<int, Map<String, dynamic>> map = {};
      
      for (var e in emps) {
        final existing = todayData.firstWhere((r) => r['user']?['id'] == e.id, orElse: () => null);
        map[e.id] = {
          'status': existing?['status'] ?? 'UNMARKED',
          'checkIn': existing?['checkIn'] ?? '',
          'checkOut': existing?['checkOut'] ?? '',
          'remarks': existing?['remarks'] ?? '',
        };
      }

      setState(() {
        _employees = emps;
        _attendanceMap = map;
        _isLoading = false;
      });
    } catch (e) {
      widget.onToast("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAttendance() async {
    setState(() => _isLoading = true);
    try {
      final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final List<Map<String, dynamic>> payload = [];
      _attendanceMap.forEach((id, data) {
        if (data['status'] != 'UNMARKED') {
          payload.add({
            'userId': id,
            'status': data['status'],
            'checkIn': data['checkIn'],
            'checkOut': data['checkOut'],
            'remarks': data['remarks'],
          });
        }
      });

      final success = await AttendanceService.markBulkAttendance(date, payload);
      if (success) {
        widget.onToast("Attendance saved successfully!");
        _loadData();
      } else {
        widget.onToast("Failed to save attendance.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      widget.onToast("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void _markAll(String status) {
    setState(() {
      for (var id in _attendanceMap.keys) {
        _attendanceMap[id]!['status'] = status;
        if (status == 'PRESENT' && _attendanceMap[id]!['checkIn'] == '') {
          _attendanceMap[id]!['checkIn'] = '09:00 AM';
        }
      }
    });
  }

  Map<String, int> get _summary {
    int present = 0, absent = 0, unmarked = 0;
    _attendanceMap.values.forEach((v) {
      if (v['status'] == 'PRESENT') present++;
      else if (v['status'] == 'ABSENT') absent++;
      else unmarked++;
    });
    return {'PRESENT': present, 'ABSENT': absent, 'UNMARKED': unmarked};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSummaryRow(),
        Expanded(
          child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildTable(),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Column(
        children: [
          Row(
            children: [
              Text(DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const Spacer(),
              _MarkButton(label: 'All Present', color: const Color(0xff22c55e), onTap: () => _markAll('PRESENT')),
              const SizedBox(width: 8),
              _MarkButton(label: 'All Absent', color: const Color(0xffef4444), onTap: () => _markAll('ABSENT')),
            ],
          ),
          const SizedBox(height: 15),
          SearchField(hint: 'Filter team...', onChanged: (v) => setState(() => _searchQuery = v)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final s = _summary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            AttendanceSummaryCard(label: 'Present', value: '${s['PRESENT']}', icon: Icons.check_circle_rounded, color: const Color(0xff14532d), bg: const Color(0xffdcfce7)),
            const SizedBox(width: 12),
            AttendanceSummaryCard(label: 'Absent', value: '${s['ABSENT']}', icon: Icons.cancel_rounded, color: const Color(0xff991b1b), bg: const Color(0xfffee2e2)),
            const SizedBox(width: 12),
            AttendanceSummaryCard(label: 'Unmarked', value: '${s['UNMARKED']}', icon: Icons.help_rounded, color: AppColors.onSurfaceVariant, bg: AppColors.surfaceContainerHigh),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final filtered = _employees.where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('EMPLOYEE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))),
                Expanded(flex: 2, child: Text('TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) => _AttendanceRow(
                employee: filtered[i],
                record: _attendanceMap[filtered[i].id]!,
                onChanged: (map) => setState(() => _attendanceMap[filtered[i].id] = map),
                isLast: i == filtered.length - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final s = _summary;
    return Container(
      padding: const EdgeInsets.all(20).copyWith(bottom: 30),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(child: Text(s['UNMARKED']! > 0 ? '${s['UNMARKED']} employees unmarked' : 'All marked', style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant))),
          GoldGradientButton(text: 'Save Attendance', icon: Icons.save_rounded, width: 180, onTap: _saveAttendance),
        ],
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MarkButton({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.5)), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final EmployeeModel employee;
  final Map<String, dynamic> record;
  final Function(Map<String, dynamic>) onChanged;
  final bool isLast;

  const _AttendanceRow({required this.employee, required this.record, required this.onChanged, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isLast ? Colors.transparent : AppColors.outlineVariant.withOpacity(0.5)),
          left: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
          right: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                AvatarWidget(initials: employee.initials, size: 32, fontSize: 12),
                const SizedBox(width: 10),
                Expanded(child: Text(employee.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: record['status'],
              underline: const SizedBox(),
              items: ['UNMARKED', 'PRESENT', 'ABSENT', 'HALF_DAY', 'LATE', 'ON_LEAVE'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 11)))).toList(),
              onChanged: (v) => onChanged({...record, 'status': v}),
            ),
          ),
          Expanded(
            flex: 2,
            child: _TimePicker(
              time: record['checkIn'],
              onSelected: (t) => onChanged({...record, 'checkIn': t}),
              isEnabled: record['status'] == 'PRESENT',
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String time;
  final Function(String) onSelected;
  final bool isEnabled;
  const _TimePicker({required this.time, required this.onSelected, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    final noTime = !isEnabled;
    return GestureDetector(
      onTap: isEnabled ? () async {
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (picked != null) onSelected(picked.format(context));
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(color: noTime ? Colors.grey.withOpacity(0.1) : AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
        child: Text(noTime ? '--' : (time == '' ? 'IN' : time), style: TextStyle(fontSize: 11, color: noTime ? Colors.grey : AppColors.primary, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
    );
  }
}
