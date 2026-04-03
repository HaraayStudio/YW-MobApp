import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class DraftsmanDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const DraftsmanDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.task_alt_rounded, 'label': 'Drafting Tasks', 'val': '6', 'error': false},
      {'icon': Icons.done_all_rounded, 'label': 'Completed', 'val': '18', 'error': false},
      {'icon': Icons.schedule_rounded, 'label': 'Due Today', 'val': '2', 'error': true},
      {'icon': Icons.folder_open_rounded, 'label': 'Projects', 'val': '3', 'error': false},
    ];
    final actions = [
      {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'section': 'tasks'},
      {'icon': Icons.fingerprint_rounded, 'label': 'Attendance', 'section': 'attendance'},
      {'icon': Icons.event_available_rounded, 'label': 'Apply Leave', 'section': 'leaves'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Draftsman',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: false,
      showTasks: true,
    );
  }
}
