import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_role_views.dart';

class JrArchitectDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const JrArchitectDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return EmployeeDashboardView(
      user: user,
      onNavigate: onNavigate,
    );
  }
}
