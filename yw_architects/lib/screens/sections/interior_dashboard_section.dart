import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class InteriorDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const InteriorDashboardSection({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Interior Designer',
      onNavigate: onNavigate,
      stats: [
        {'icon': Icons.palette_rounded, 'label': 'Active Designs', 'val': '4', 'error': false},
        {'icon': Icons.inventory_2_rounded, 'label': 'Materials', 'val': '38', 'error': false},
        {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'val': '6', 'error': false},
        {'icon': Icons.schedule_rounded, 'label': 'Due Today', 'val': '1', 'error': true},
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
