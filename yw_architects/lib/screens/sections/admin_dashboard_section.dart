import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class AdminDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const AdminDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.architecture_rounded, 'label': 'Active Projects', 'val': '8', 'error': false},
      {'icon': Icons.groups_rounded, 'label': 'Total Staff', 'val': '24', 'error': false},
      {'icon': Icons.event_available_rounded, 'label': 'Leave Requests', 'val': '4', 'error': true},
      {'icon': Icons.person_add_rounded, 'label': 'New Joiners', 'val': '2', 'error': false},
    ];
    final actions = [
      {'icon': Icons.person_add_rounded, 'label': 'Add Employee', 'section': 'employees'},
      {'icon': Icons.event_available_rounded, 'label': 'Leaves', 'section': 'leaves'},
      {'icon': Icons.analytics_rounded, 'label': 'Reports', 'section': 'reports'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Admin',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: true,
      showTasks: true,
    );
  }
}
