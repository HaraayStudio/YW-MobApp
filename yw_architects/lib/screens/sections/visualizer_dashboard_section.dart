import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class VisualizerDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const VisualizerDashboardSection({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Visualizer',
      onNavigate: onNavigate,
      stats: [
        {'icon': Icons.view_in_ar_rounded, 'label': 'Render Jobs', 'val': '6', 'error': false},
        {'icon': Icons.done_all_rounded, 'label': 'Delivered', 'val': '18', 'error': false},
        {'icon': Icons.feedback_rounded, 'label': 'Revisions Due', 'val': '3', 'error': true},
        {'icon': Icons.schedule_rounded, 'label': 'Deadlines Today', 'val': '1', 'error': true},
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
