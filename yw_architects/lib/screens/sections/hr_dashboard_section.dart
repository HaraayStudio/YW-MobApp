import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class HrDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const HrDashboardSection({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSharedLayout(
      user: user,
      greetingRole: 'HR Admin',
      onNavigate: onNavigate,
      stats: [
        {'icon': Icons.groups_rounded, 'label': 'Total Staff', 'val': '24', 'error': false},
        {'icon': Icons.event_available_rounded, 'label': 'Leaves Pending', 'val': '4', 'error': true},
        {'icon': Icons.person_add_rounded, 'label': 'New Joiners', 'val': '2', 'error': false},
        {'icon': Icons.fingerprint_rounded, 'label': 'Attendance', 'val': '95%', 'error': false},
      ],
      quickActions: [
        {'icon': Icons.person_add_rounded, 'label': 'Add Employee', 'section': 'employees'},
        {'icon': Icons.event_available_rounded, 'label': 'Leave Requests', 'section': 'leaves'},
        {'icon': Icons.fingerprint_rounded, 'label': 'Attendance', 'section': 'attendance'},
      ],
      showProjects: false,
      showTasks: false,
    );
  }
}
