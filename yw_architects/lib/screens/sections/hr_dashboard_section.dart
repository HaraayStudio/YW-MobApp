import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class HrDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const HrDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.groups_rounded, 'label': 'Total Staff', 'val': '24', 'error': false},
      {'icon': Icons.event_available_rounded, 'label': 'Leave Requests', 'val': '4', 'error': true},
      {'icon': Icons.person_add_rounded, 'label': 'New Joiners', 'val': '2', 'error': false},
      {'icon': Icons.fingerprint_rounded, 'label': 'Absent Today', 'val': '3', 'error': true},
    ];
    final actions = [
      {'icon': Icons.person_add_rounded, 'label': 'Add Employee', 'section': 'employees'},
      {'icon': Icons.event_available_rounded, 'label': 'Leaves', 'section': 'leaves'},
      {'icon': Icons.fingerprint_rounded, 'label': 'Attendance', 'section': 'attendance'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'HR',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: false,
      showTasks: false,
    );
  }
}
