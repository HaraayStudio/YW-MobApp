import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'dashboard_role_views.dart';

class LiaisonManagerDashboardSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const LiaisonManagerDashboardSection({super.key, required this.user, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return EmployeeDashboardView(
      user: user,
      onNavigate: onNavigate,
    );
  }
}
