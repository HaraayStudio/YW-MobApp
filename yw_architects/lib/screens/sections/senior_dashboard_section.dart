import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class SeniorDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const SeniorDashboardSection({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Senior Architect',
      onNavigate: onNavigate,
      stats: [
        {'icon': Icons.folder_open_rounded, 'label': 'My Projects', 'val': '3', 'error': false},
        {'icon': Icons.task_alt_rounded, 'label': 'Pending Tasks', 'val': '7', 'error': true},
        {'icon': Icons.group_rounded, 'label': 'My Team', 'val': '5', 'error': false},
        {'icon': Icons.schedule_rounded, 'label': 'Due This Week', 'val': '3', 'error': false},
      ],
      quickActions: [
        {'icon': Icons.add_task_rounded, 'label': 'Create Task', 'section': 'tasks'},
        {'icon': Icons.construction_rounded, 'label': 'Site Update', 'section': 'site'},
        {'icon': Icons.event_available_rounded, 'label': 'Apply Leave', 'section': 'leaves'},
      ],
      showProjects: true,
      showTasks: true,
    );
  }
}
