import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class SiteDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const SiteDashboardSection({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Site Engineer',
      onNavigate: onNavigate,
      stats: [
        {'icon': Icons.construction_rounded, 'label': 'Active Sites', 'val': '3', 'error': false},
        {'icon': Icons.photo_camera_rounded, 'label': "Today's Updates", 'val': '8', 'error': false},
        {'icon': Icons.task_alt_rounded, 'label': 'Open Snags', 'val': '5', 'error': true},
        {'icon': Icons.schedule_rounded, 'label': 'Site Visits', 'val': '2', 'error': false},
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
