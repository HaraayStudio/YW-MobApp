import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

// Import New Separate Dashboards
import 'sections/admin_dashboard_section.dart';
import 'sections/senior_dashboard_section.dart';
import 'sections/junior_dashboard_section.dart';
import 'sections/interior_dashboard_section.dart';
import 'sections/site_dashboard_section.dart';
import 'sections/visualizer_dashboard_section.dart';
import 'sections/hr_dashboard_section.dart';

import 'sections/projects_section.dart';
import 'sections/tasks_section.dart';
import 'sections/attendance_section.dart';
import 'sections/leaves_section.dart';
import 'sections/site_section.dart';
import 'sections/materials_section.dart';
import 'sections/renders_section.dart';
import 'sections/employees_section.dart';
import 'sections/reports_section.dart';
import 'sections/notifications_section.dart';
import 'sections/profile_section.dart';

class MainAppScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const MainAppScreen({super.key, required this.user, required this.onLogout});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  String _currentSection = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> get bottomNavItems {
    final nav = widget.user.info.nav;
    final items = ['dashboard', ...nav.where((n) => n != 'dashboard' && n != 'notifications' && n != 'profile')];
    return items.take(4).toList();
  }

  Widget _buildDashboard() {
    switch (widget.user.role) {
      case UserRole.admin: return AdminDashboardSection(user: widget.user, onNavigate: _navigate);
      case UserRole.senior: return SeniorDashboardSection(user: widget.user, onNavigate: _navigate);
      case UserRole.junior: return JuniorDashboardSection(user: widget.user, onNavigate: _navigate);
      case UserRole.interior: return InteriorDashboardSection(user: widget.user, onNavigate: _navigate);
      case UserRole.site: return SiteDashboardSection(user: widget.user, onNavigate: _navigate);
      case UserRole.visualizer: return VisualizerDashboardSection(user: widget.user, onNavigate: _navigate);
      case UserRole.hr: return HrDashboardSection(user: widget.user, onNavigate: _navigate);
    }
  }

  Widget _buildSection() {
    switch (_currentSection) {
      case 'dashboard': return _buildDashboard();
      case 'projects': return ProjectsSection(user: widget.user, onToast: _toast);
      case 'tasks': return TasksSection(user: widget.user, onToast: _toast);
      case 'attendance': return AttendanceSection(user: widget.user, onToast: _toast);
      case 'leaves': return LeavesSection(user: widget.user, onToast: _toast);
      case 'site': return SiteSection(onToast: _toast);
      case 'materials': return MaterialsSection(user: widget.user, onToast: _toast);
      case 'renders': return RendersSection(user: widget.user, onToast: _toast);
      case 'employees': return EmployeesSection(onToast: _toast);
      case 'reports': return ReportsSection(onToast: _toast);
      case 'notifications': return NotificationsSection(onToast: _toast);
      case 'profile': return ProfileSection(user: widget.user, onLogout: widget.onLogout, onToast: _toast);
      default: return _buildDashboard();
    }
  }

  void _navigate(String section) => setState(() => _currentSection = section);

  void _toast(String msg) => showAppToast(context, msg);

  String get _topbarTitle => navConfig[_currentSection]?.label ?? 'Dashboard';

  IconData _navIcon(String key) {
    final icons = {
      'dashboard': Icons.dashboard_rounded,
      'projects': Icons.folder_special_rounded,
      'tasks': Icons.task_alt_rounded,
      'employees': Icons.group_rounded,
      'attendance': Icons.fingerprint_rounded,
      'leaves': Icons.event_available_rounded,
      'site': Icons.construction_rounded,
      'materials': Icons.inventory_2_rounded,
      'renders': Icons.view_in_ar_rounded,
      'reports': Icons.analytics_rounded,
      'notifications': Icons.notifications_rounded,
      'profile': Icons.manage_accounts_rounded,
    };
    return icons[key] ?? Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surface,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_currentSection),
                child: SingleChildScrollView(
                  child: _buildSection(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8, right: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _topbarTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  widget.user.info.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigate('notifications'),
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.primary),
                Positioned(
                  right: 0, top: 0,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _navigate('profile'),
            child: AvatarWidget(
              initials: widget.user.info.initials,
              size: 34,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = bottomNavItems;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: items.map((key) {
          final isActive = _currentSection == key;
          final label = navConfig[key]?.label ?? key;
          return Expanded(
            child: GestureDetector(
              onTap: () => _navigate(key),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _navIcon(key),
                    color: isActive ? AppColors.primary : AppColors.outline,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? AppColors.primary : AppColors.outline,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDrawer() {
    final navItems = widget.user.info.nav;
    return Drawer(
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: BoxDecoration(gradient: goldGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('YW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YW Architects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('Management System', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      AvatarWidget(initials: widget.user.info.initials, size: 40, fontSize: 14),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.info.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            widget.user.info.label,
                            style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8),
                  child: Text(
                    'MAIN MENU',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...navItems.map((key) {
                  final item = navConfig[key];
                  if (item == null) return const SizedBox.shrink();
                  final isActive = _currentSection == key;
                  return ListTile(
                    leading: Icon(_navIcon(key), color: isActive ? AppColors.primary : AppColors.onSurfaceVariant, size: 20),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                    ),
                    selected: isActive,
                    selectedTileColor: AppColors.primary.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      Navigator.pop(context);
                      _navigate(key);
                    },
                  );
                }),
                const Divider(height: 32, color: AppColors.outlineVariant),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onLogout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
