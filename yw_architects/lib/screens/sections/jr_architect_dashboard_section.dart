import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class JrArchitectDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const JrArchitectDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'val': '5', 'error': false},
      {'icon': Icons.done_all_rounded, 'label': 'Completed', 'val': '12', 'error': false},
      {'icon': Icons.schedule_rounded, 'label': 'Due Today', 'val': '2', 'error': true},
      {'icon': Icons.folder_open_rounded, 'label': 'My Projects', 'val': '2', 'error': false},
    ];
    final actions = [
      {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'section': 'tasks'},
      {'icon': Icons.fingerprint_rounded, 'label': 'Attendance', 'section': 'attendance'},
      {'icon': Icons.event_available_rounded, 'label': 'Apply Leave', 'section': 'leaves'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Jr. Architect',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: false,
      showTasks: true,
    );
  }
}
