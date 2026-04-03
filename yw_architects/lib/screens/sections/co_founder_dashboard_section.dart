import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class CoFounderDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const CoFounderDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.payments_rounded, 'label': 'Revenue (Cr)', 'val': '4.2', 'error': false},
      {'icon': Icons.architecture_rounded, 'label': 'Active Projects', 'val': '8', 'error': false},
      {'icon': Icons.pending_actions_rounded, 'label': 'Pending Approvals', 'val': '6', 'error': true},
      {'icon': Icons.groups_rounded, 'label': 'Employees', 'val': '24', 'error': false},
    ];
    final actions = [
      {'icon': Icons.add_circle_rounded, 'label': 'New Project', 'section': 'projects'},
      {'icon': Icons.analytics_rounded, 'label': 'Reports', 'section': 'reports'},
      {'icon': Icons.group_rounded, 'label': 'Employees', 'section': 'employees'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Co-Founder',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: true,
      showTasks: true,
    );
  }
}
