import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../services/employee_service.dart';

// Role-specific dashboard sections
import 'sections/admin_dashboard_section.dart';
import 'sections/co_founder_dashboard_section.dart';
import 'sections/hr_dashboard_section.dart';
import 'sections/sr_architect_dashboard_section.dart';
import 'sections/jr_architect_dashboard_section.dart';
import 'sections/sr_engineer_dashboard_section.dart';
import 'sections/draftsman_dashboard_section.dart';
import 'sections/liaison_manager_dashboard_section.dart';
import 'sections/liaison_officer_dashboard_section.dart';
import 'sections/liaison_assistant_dashboard_section.dart';

import 'sections/dashboard_role_views.dart';

// Feature sections
import 'sections/projects_section.dart';
import 'sections/tasks_section.dart';
import 'sections/attendance_section.dart';
import 'sections/leaves_section.dart';
import 'sections/materials_section.dart';
import 'sections/renders_section.dart';
import 'sites/sites_screen.dart';
import 'sections/employees_section.dart';
import 'sections/clients_section.dart';
import 'sections/reports_section.dart';
import 'sections/notifications_section.dart';
import 'sections/profile_section.dart';
import 'sections/enquiry_section.dart';

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
  int? _projectToEdit;
  int? _siteProjectId; // project ID to auto-open in Sites section
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    if (_user.info.label == 'CLIENT') return;

    try {
      final profile = await EmployeeService.getEmployeeData();
      print("[MainAppScreen] Fetched profile: $profile");
      
      if (profile != null) {
        // RESILIENT NAME EXTRACTION - Handles nested or flat, camel or snake
        String? fName = profile['firstName']?.toString() ?? profile['first_name']?.toString();
        String? lName = profile['lastName']?.toString() ?? profile['last_name']?.toString();

        // Check if nested inside 'employee' or 'user' object (Spring Data REST common pattern)
        if (fName == null && profile['user'] != null) {
          final u = profile['user'];
          fName = u['firstName']?.toString() ?? u['first_name']?.toString();
          lName = u['lastName']?.toString() ?? u['last_name']?.toString();
        }
        if (fName == null && profile['employee'] != null) {
          final e = profile['employee'];
          fName = e['firstName']?.toString() ?? e['first_name']?.toString();
          lName = e['lastName']?.toString() ?? e['last_name']?.toString();
        }

        final finalFName = fName ?? _user.info.firstName;
        final finalLName = lName ?? _user.info.lastName;

        // Diagnostic Toast (Temporary)
        _toast("Detected Name: $finalFName $finalLName");

        setState(() {
          _user = _user.copyWith(
            info: _user.info.copyWith(
              name: '$finalFName $finalLName'.trim(),
              firstName: finalFName,
              lastName: finalLName,
              initials: (finalFName.isNotEmpty ? finalFName[0] : '') + (finalLName.isNotEmpty ? finalLName[0] : ''),
              profileImage: (profile['profileImage'] ?? profile['profile_image'])?.toString(),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('[MainAppScreen] Error refreshing profile: $e');
    }
  }

  // Bottom nav customization based on user group
  List<String> get _bottomNavItems {
    final role = _user.role;

    // Management roles (Admin, Co-Founder, HR) get specific bottom nav
    if (role == UserRole.admin || role == UserRole.coFounder || role == UserRole.hr) {
      return managementBottomNav;
    }

    // All other employees
    return employeeBottomNav;
  }

  // Sidebar items customization
  List<String> get _sidebarNavItems {
    final role = _user.role;
    if (role == UserRole.admin || role == UserRole.coFounder || role == UserRole.hr) {
      return managementSidebarNav;
    }
    return employeeSidebarNav;
  }

  void _navigate(String section) {
    if (section != 'projects') {
      _projectToEdit = null;
    }
    setState(() => _currentSection = section);
  }

  void _toast(String msg) => showAppToast(context, msg);

  // ── Role-specific dashboard ─────────────────────────────────────────────
  Widget _buildDashboard() {
    switch (_user.role) {
      case UserRole.admin:
        if (_user.info.label == 'CLIENT') {
          return ClientDashboardView(user: _user, onNavigate: _navigate);
        }
        return AdminDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.coFounder:
        return CoFounderDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.hr:
        return HrDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.srArchitect:
        return SrArchitectDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.jrArchitect:
        return JrArchitectDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.srEngineer:
        return SrEngineerDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.draftsman:
        return DraftsmanDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.liaisonManager:
        return LiaisonManagerDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.liaisonOfficer:
        return LiaisonOfficerDashboardSection(user: _user, onNavigate: _navigate);
      case UserRole.liaisonAssistant:
        return LiaisonAssistantDashboardSection(user: _user, onNavigate: _navigate);
    }
  }

  // ── Section switcher ────────────────────────────────────────────────────
  Widget _buildSection() {
    switch (_currentSection) {
      case 'dashboard':     return _buildDashboard();
      case 'projects':      return ProjectsSection(
                              user: _user,
                              onToast: _toast,
                              editProjectId: _projectToEdit,
                              onNavigateToSite: (projectId) {
                                setState(() {
                                  _siteProjectId = projectId;
                                  _currentSection = 'site';
                                });
                              },
                            );
      case 'tasks':         return TasksSection(user: _user, onToast: _toast);
      case 'attendance':    if ([UserRole.admin, UserRole.hr, UserRole.coFounder].contains(_user.role)) {
                              return EmployeesSection(onToast: _toast, initialTabIndex: 1);
                            }
                            return AttendanceSection(user: _user, onToast: _toast);
      case 'leaves':        return LeavesSection(user: _user, onToast: _toast);
      case 'site':          return SitesScreen(
                              user: _user, 
                              onToast: _toast,
                              initialProjectId: _siteProjectId,
                              onEditProject: (id) {
                                setState(() {
                                  _siteProjectId = null; // clear after use
                                  _projectToEdit = id;
                                  _currentSection = 'projects';
                                });
                              },
                            );
      case 'materials':     return MaterialsSection(user: _user, onToast: _toast);
      case 'renders':       return RendersSection(user: _user, onToast: _toast);
      case 'employees':     return EmployeesSection(onToast: _toast);
      case 'clients':       return ClientsSection(onToast: _toast);
      case 'reports':       return ReportsSection(onToast: _toast);
      case 'notifications': return NotificationsSection(onToast: _toast);
      case 'profile':       return ProfileSection(user: _user, onLogout: widget.onLogout, onToast: _toast);
      case 'enquiry':       return EnquirySection(user: _user, onToast: _toast);
      default:              return _buildDashboard();
    }
  }

  String get _topbarTitle => navConfig[_currentSection]?.label ?? 'Dashboard';

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Keep status bar icons dark
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surface,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(_currentSection),
                child: _buildSection(),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      // Use SafeArea padding + explicit height so nothing clips on any device
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      height: MediaQuery.of(context).padding.top + 56,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.96),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hamburger
          InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.menu_rounded, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 10),
          // Title + subtitle
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _topbarTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
                Text(
                  _user.info.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Notification bell
          Stack(
            children: [
              InkWell(
                onTap: () => _navigate('notifications'),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.notifications_rounded,
                      color: AppColors.primary, size: 22),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // Avatar
          GestureDetector(
            onTap: () => _navigate('profile'),
            child: AvatarWidget(
              initials: _user.info.initials,
              size: 36,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = _bottomNavItems;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.97),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // SafeArea bottom padding
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 4,
        top: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((key) {
          final cfg = navConfig[key]!;
          final active = _currentSection == key;
          return Expanded(
            child: InkWell(
              onTap: () => _navigate(key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Active: filled background pill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        cfg.iconData,
                        color: active
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cfg.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? AppColors.primary
                            : AppColors.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    final allItems = _sidebarNavItems;
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(gradient: goldGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'YW',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YW Architects',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Management System',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // User chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      AvatarWidget(
                        initials: _user.info.initials,
                        size: 36,
                        fontSize: 13,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user.info.name,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _user.info.label,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Text(
                    'MAIN MENU',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...allItems.map((key) {
                  final cfg = navConfig[key]!;
                  final active = _currentSection == key;
                  return ListTile(
                    dense: true,
                    selected: active,
                    selectedTileColor: AppColors.primary.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    leading: Icon(cfg.iconData,
                        size: 20,
                        color: active
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant),
                    title: Text(
                      cfg.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _navigate(key);
                    },
                  );
                }),
              ],
            ),
          ),

          // Sign out
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
              top: 8,
              left: 12,
              right: 12,
            ),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20),
              title: Text(
                'Sign Out',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
