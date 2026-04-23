import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' as org_scroll;
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
  bool _isSearchExpanded = false;
  final ScrollController _scrollController = ScrollController();
  bool _isBottomBarVisible = true;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        org_scroll.ScrollDirection.reverse) {
      if (_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        org_scroll.ScrollDirection.forward) {
      if (!_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final empsData = await EmployeeService.getAllEmployees();
      final todayData = await AttendanceService.getTodayAttendance();

      final emps = empsData.map((e) => EmployeeModel.fromJson(e)).toList();
      final Map<int, Map<String, dynamic>> map = {};

      for (var e in emps) {
        final existing = todayData.firstWhere(
          (r) => r['user']?['id'] == e.id,
          orElse: () => null,
        );
        map[e.id] = {
          'status': (existing?['status']?.toString() ?? 'UNMARKED')
              .toUpperCase(),
          'checkIn': existing?['checkIn']?.toString() ?? '',
          'checkOut': existing?['checkOut'] ?? '',
          'remarks': existing?['remarks'] ?? '',
        };
      }

      if (!mounted) return;
      setState(() {
        _employees = emps;
        _attendanceMap = map;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      final currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      for (var id in _attendanceMap.keys) {
        _attendanceMap[id]!['status'] = status;
        // The user wants time captured for both Present, Absent, and potentially Late.
        _attendanceMap[id]!['checkIn'] = currentTime;
      }
    });
  }

  Map<String, int> get _summary {
    int present = 0, absent = 0, unmarked = 0;
    _attendanceMap.values.forEach((v) {
      if (v['status'] == 'PRESENT')
        present++;
      else if (v['status'] == 'ABSENT')
        absent++;
      else
        unmarked++;
    });
    return {'PRESENT': present, 'ABSENT': absent, 'UNMARKED': unmarked};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthSelector(),
        _buildHeader(),
        _buildSummaryRow(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTable(),
        ),
        _buildAnimatedBottomBar(),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 10, bottom: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 12,
        itemBuilder: (context, index) {
          final isSelected = _selectedMonth == index + 1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _months[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedMonth = index + 1;
                    _selectedDate = DateTime(_selectedYear, _selectedMonth, 1);
                  });
                  _loadData();
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerHigh,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                            _selectedMonth = picked.month;
                            _selectedYear = picked.year;
                          });
                          _loadData();
                        }
                      },
                      child: Text(
                        DateFormat('EEEE, MMM dd yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      'Daily Attendance',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
                      icon: Icon(
                        _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: _MarkButton(
                        label: 'Present',
                        color: const Color(0xff22c55e),
                        onTap: () => _markAll('PRESENT'),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: _MarkButton(
                        label: 'Absent',
                        color: const Color(0xffef4444),
                        onTap: () => _markAll('ABSENT'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isSearchExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SearchField(
                hint: 'Filter team...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final s = _summary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: AttendanceSummaryCard(
              label: 'Present',
              value: '${s['PRESENT']}',
              icon: Icons.check_circle_rounded,
              color: const Color(0xff14532d),
              bg: const Color(0xffdcfce7),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AttendanceSummaryCard(
              label: 'Absent',
              value: '${s['ABSENT']}',
              icon: Icons.cancel_rounded,
              color: const Color(0xff991b1b),
              bg: const Color(0xfffee2e2),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AttendanceSummaryCard(
              label: 'Unmarked',
              value: '${s['UNMARKED']}',
              icon: Icons.help_rounded,
              color: AppColors.onSurfaceVariant,
              bg: AppColors.surfaceContainerHigh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final filtered = _employees
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 32,
                  child: Text(
                    'EMPLOYEE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 24,
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 22,
                  child: Text(
                    'IN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 22,
                  child: Text(
                    'OUT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filtered.length,
              itemBuilder: (context, i) => _AttendanceRow(
                employee: filtered[i],
                record: _attendanceMap[filtered[i].id]!,
                onChanged: (map) =>
                    setState(() => _attendanceMap[filtered[i].id] = map),
                onShowHistory: (emp) => _showEmployeeHistory(context, emp),
                isLast: i == filtered.length - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBottomBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isBottomBarVisible ? 90 : 0,
      curve: Curves.easeInOut,
      child: Wrap( // Wrap prevents overflow when height is 0
        children: [
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final s = _summary;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              s['UNMARKED']! > 0
                  ? '${s['UNMARKED']} unmarked'
                  : 'All marked',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          GoldGradientButton(
            text: 'Save Attendance',
            icon: Icons.save_rounded,
            width: 160,
            height: 44,
            onTap: _saveAttendance,
          ),
        ],
      ),
    );
  }

  void _showEmployeeHistory(BuildContext context, EmployeeModel employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    AvatarWidget(initials: employee.initials, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Attendance History - ${_months[_selectedMonth - 1]} $_selectedYear",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: AttendanceService.getEmployeeAttendanceHistory(
                    employee.id,
                    _selectedMonth,
                    _selectedYear,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No records found"));
                    }

                    final history = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: DateTime(_selectedYear, _selectedMonth + 1, 0).day,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final date = DateTime(_selectedYear, _selectedMonth, day);
                        final dateStr = DateFormat('yyyy-MM-dd').format(date);
                        
                        final record = history.firstWhere(
                          (h) => h['attendanceDate'] == dateStr,
                          orElse: () => {},
                        );

                        final status = record['status']?.toString().toUpperCase() ?? 'NONE';
                        Color statusColor = AppColors.outline;
                        if (status == 'PRESENT') statusColor = Colors.green;
                        if (status == 'ABSENT') statusColor = Colors.red;
                        if (status == 'HALF_DAY') statusColor = Colors.orange;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                child: Column(
                                  children: [
                                    Text(
                                      day.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('EEE').format(date),
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  status == 'NONE' ? 'No Record' : status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              if (record['checkIn'] != null && record['checkIn'].toString().isNotEmpty)
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "${record['checkIn'].toString().substring(0, 5)} - ${record['checkOut']?.toString().substring(0, 5) ?? '--:--'}",
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MarkButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final EmployeeModel employee;
  final Map<String, dynamic> record;
  final Function(Map<String, dynamic>) onChanged;
  final Function(EmployeeModel) onShowHistory;
  final bool isLast;

  const _AttendanceRow({
    required this.employee,
    required this.record,
    required this.onChanged,
    required this.onShowHistory,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          left: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          right: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 32,
            child: InkWell(
              onTap: () => onShowHistory(employee),
              child: Row(
                children: [
                  AvatarWidget(
                    initials: employee.initials,
                    size: 24,
                    fontSize: 9,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary, // Highlight clickable
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 24,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: record['status'],
                isDense: true,
                iconSize: 16,
                items:
                    [
                          'UNMARKED',
                          'PRESENT',
                          'ABSENT',
                          'HALF_DAY',
                          'LATE',
                          'ON_LEAVE',
                        ]
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                s,
                                style: const TextStyle(fontSize: 9),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  final newRecord = {...record, 'status': v};
                  if (v == 'PRESENT' || v == 'LATE' || v == 'ABSENT' || v == 'HALF_DAY') {
                    newRecord['checkIn'] = DateFormat(
                      'HH:mm:ss',
                    ).format(DateTime.now());
                  }
                  onChanged(newRecord);
                },
              ),
            ),
          ),
          Expanded(
            flex: 22,
            child: _TimePicker(
              time: record['checkIn'],
              onSelected: (t) {
                final newRec = {...record, 'checkIn': t};
                if (newRec['status'] == 'UNMARKED') newRec['status'] = 'PRESENT';
                onChanged(newRec);
              },
              isEnabled: record['status'] != 'ON_LEAVE',
              emptyLabel: 'IN',
            ),
          ),
          Expanded(
            flex: 22,
            child: _TimePicker(
              time: record['checkOut'],
              onSelected: (t) {
                final newRec = {...record, 'checkOut': t};
                if (newRec['status'] == 'UNMARKED') newRec['status'] = 'PRESENT';
                onChanged(newRec);
              },
              isEnabled: record['status'] != 'ON_LEAVE',
              emptyLabel: 'OUT',
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
  final String emptyLabel;
  const _TimePicker({
    required this.time,
    required this.onSelected,
    required this.isEnabled,
    this.emptyLabel = '--',
  });

  @override
  Widget build(BuildContext context) {
    final noTime = !isEnabled;
    return GestureDetector(
      onTap: isEnabled
          ? () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                final hour = picked.hour.toString().padLeft(2, '0');
                final minute = picked.minute.toString().padLeft(2, '0');
                onSelected('$hour:$minute:00');
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: noTime
              ? Colors.grey.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(4),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            noTime
                ? '--'
                : (time == ''
                    ? emptyLabel
                    : (time.length > 5 ? time.substring(0, 5) : time)),
            style: TextStyle(
              fontSize: 10,
              color: noTime ? Colors.grey : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
