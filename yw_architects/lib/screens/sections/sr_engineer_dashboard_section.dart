import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class SrEngineerDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const SrEngineerDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.construction_rounded, 'label': 'Active Sites', 'val': '3', 'error': false},
      {'icon': Icons.photo_camera_rounded, 'label': 'Today Updates', 'val': '8', 'error': false},
      {'icon': Icons.task_alt_rounded, 'label': 'Open Snags', 'val': '5', 'error': true},
      {'icon': Icons.schedule_rounded, 'label': 'Site Visits', 'val': '2', 'error': false},
    ];
    final actions = [
      {'icon': Icons.gps_fixed_rounded, 'label': 'GPS Check-In', 'section': 'site'},
      {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'section': 'tasks'},
      {'icon': Icons.event_available_rounded, 'label': 'Apply Leave', 'section': 'leaves'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Sr. Engineer',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: false,
      showTasks: true,
    );
  }
}
