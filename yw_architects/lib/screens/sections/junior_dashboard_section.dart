import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class JuniorDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const JuniorDashboardSection({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Junior Architect',
      onNavigate: onNavigate,
      stats: [
        {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'val': '5', 'error': false},
        {'icon': Icons.done_all_rounded, 'label': 'Completed', 'val': '12', 'error': false},
        {'icon': Icons.schedule_rounded, 'label': 'Due Today', 'val': '2', 'error': true},
        {'icon': Icons.folder_open_rounded, 'label': 'Assigned Projects', 'val': '2', 'error': false},
      ],
      quickActions: [
        {'icon': Icons.fingerprint_rounded, 'label': 'Mark Attendance', 'section': 'attendance'},
        {'icon': Icons.event_available_rounded, 'label': 'Apply Leave', 'section': 'leaves'},
        {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'section': 'tasks'},
      ],
      showProjects: false,
      showTasks: true,
    );
  }
}
