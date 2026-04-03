import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class LiaisonManagerDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const LiaisonManagerDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.handshake_rounded, 'label': 'Active Liaisons', 'val': '5', 'error': false},
      {'icon': Icons.task_alt_rounded, 'label': 'Pending Tasks', 'val': '9', 'error': true},
      {'icon': Icons.group_rounded, 'label': 'Officers', 'val': '4', 'error': false},
      {'icon': Icons.folder_open_rounded, 'label': 'Projects', 'val': '3', 'error': false},
    ];
    final actions = [
      {'icon': Icons.add_task_rounded, 'label': 'Create Task', 'section': 'tasks'},
      {'icon': Icons.folder_special_rounded, 'label': 'Projects', 'section': 'projects'},
      {'icon': Icons.event_available_rounded, 'label': 'Apply Leave', 'section': 'leaves'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Liaison Manager',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: true,
      showTasks: true,
    );
  }
}
