import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'employee/tabs/employees_tab.dart';
import 'employee/tabs/daily_attendance_tab.dart';
import 'employee/tabs/attendance_calendar_tab.dart';

class EmployeesSection extends StatefulWidget {
  final Function(String) onToast;
  final int initialTabIndex;
  const EmployeesSection({super.key, required this.onToast, this.initialTabIndex = 0});

  @override
  State<EmployeesSection> createState() => _EmployeesSectionState();
}

class _EmployeesSectionState extends State<EmployeesSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Directory'),
              Tab(text: 'Daily Attendance'),
              Tab(text: 'Calendar'),
            ],
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              EmployeesListTab(onToast: widget.onToast),
              DailyAttendanceTab(onToast: widget.onToast),
              AttendanceCalendarTab(onToast: widget.onToast),
            ],
          ),
        ),
      ],
    );
  }
}
