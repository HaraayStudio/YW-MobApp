import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_shared.dart';

class LiaisonAssistantDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const LiaisonAssistantDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'val': '4', 'error': false},
      {'icon': Icons.done_all_rounded, 'label': 'Completed', 'val': '9', 'error': false},
      {'icon': Icons.schedule_rounded, 'label': 'Due Today', 'val': '1', 'error': false},
      {'icon': Icons.handshake_rounded, 'label': 'Support Tasks', 'val': '2', 'error': false},
    ];
    final actions = [
      {'icon': Icons.task_alt_rounded, 'label': 'My Tasks', 'section': 'tasks'},
      {'icon': Icons.fingerprint_rounded, 'label': 'Attendance', 'section': 'attendance'},
      {'icon': Icons.event_available_rounded, 'label': 'Apply Leave', 'section': 'leaves'},
    ];

    return DashboardSharedLayout(
      user: user,
      greetingRole: 'Liaison Assistant',
      onNavigate: onNavigate,
      stats: stats,
      quickActions: actions,
      showProjects: false,
      showTasks: true,
    );
  }
}
