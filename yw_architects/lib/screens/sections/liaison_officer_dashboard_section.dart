import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class LiaisonOfficerDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const LiaisonOfficerDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'val': '7', 'error': false},
      {'icon': Icons.done_all_rounded, 'label': 'Completed', 'val': '14', 'error': false},
      {'icon': Icons.schedule_rounded, 'label': 'Due Today', 'val': '3', 'error': true},
      {'icon': Icons.handshake_rounded, 'label': 'Active Liaisons', 'val': '3', 'error': false},
    ];
    final actions = [
      {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'section': 'tasks'},
      {'icon': Icons.fingerprint_rounded, 'label': 'Attendance', 'section': 'attendance'},
      {'icon': Icons.event_available_rounded, 'label': 'Apply Leave', 'section': 'leaves'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Liaison Officer',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: false,
      showTasks: true,
    );
  }
}
