import 'package:flutter/material.dart';

enum UserRole {
  admin,
  coFounder,
  hr,
  srArchitect,
  jrArchitect,
  srEngineer,
  draftsman,
  liaisonManager,
  liaisonOfficer,
  liaisonAssistant,
}

class UserRoleInfo {
  final String name;
  final String initials;
  final String email;
  final String label;
  final List<String> nav;

  const UserRoleInfo({
    required this.name,
    required this.initials,
    required this.email,
    required this.label,
    required this.nav,
  });

  UserRoleInfo copyWith({
    String? name,
    String? initials,
    String? email,
    String? label,
    List<String>? nav,
  }) {
    return UserRoleInfo(
      name:     name     ?? this.name,
      initials: initials ?? this.initials,
      email:    email    ?? this.email,
      label:    label    ?? this.label,
      nav:      nav      ?? this.nav,
    );
  }
}


class AppUser {
  final UserRole role;
  final UserRoleInfo info;
  final String? token;      // ← ADD THIS

  const AppUser({
    required this.role,
    required this.info,
    this.token,             // ← nullable, so existing code doesn't break
  });
}

// Full access: 'dashboard', 'projects', 'tasks', 'employees', 'attendance', 'leaves', 'site', 'materials', 'renders', 'reports', 'notifications', 'profile'
const List<String> fullNav = ['dashboard', 'clients', 'projects', 'tasks', 'employees', 'attendance', 'leaves', 'site', 'materials', 'renders', 'reports', 'notifications', 'profile'];
const List<String> hrNav = ['dashboard', 'employees', 'attendance', 'leaves', 'notifications', 'profile'];
const List<String> srNav = ['dashboard', 'clients', 'projects', 'tasks', 'leaves', 'notifications', 'profile'];
const List<String> jrNav = ['dashboard', 'tasks', 'attendance', 'leaves', 'notifications', 'profile'];
const List<String> liaisonManagerNav = ['dashboard', 'projects', 'tasks', 'attendance', 'leaves', 'notifications', 'profile'];
const List<String> liaisonFieldNav = ['dashboard', 'site', 'tasks', 'attendance', 'leaves', 'notifications', 'profile'];

const Map<UserRole, UserRoleInfo> roleMap = {
  UserRole.admin: UserRoleInfo(
    name: 'Admin',
    initials: 'AD',
    email: 'admin@yw.com',
    label: 'ADMIN',
    nav: fullNav,
  ),
  UserRole.coFounder: UserRoleInfo(
    name: 'Co-Founder',
    initials: 'CF',
    email: 'cofounder@yw.com',
    label: 'CO_FOUNDER',
    nav: fullNav,
  ),
  UserRole.hr: UserRoleInfo(
    name: 'HR Manager',
    initials: 'HR',
    email: 'hr@yw.com',
    label: 'HR',
    nav: hrNav,
  ),
  UserRole.srArchitect: UserRoleInfo(
    name: 'Senior Architect',
    initials: 'SA',
    email: 'srarch@yw.com',
    label: 'SR_ARCHITECT',
    nav: srNav,
  ),
  UserRole.jrArchitect: UserRoleInfo(
    name: 'Junior Architect',
    initials: 'JA',
    email: 'jrarch@yw.com',
    label: 'JR_ARCHITECT',
    nav: jrNav,
  ),
  UserRole.srEngineer: UserRoleInfo(
    name: 'Senior Engineer',
    initials: 'SE',
    email: 'sreng@yw.com',
    label: 'SR_ENGINEER',
    nav: srNav,
  ),
  UserRole.draftsman: UserRoleInfo(
    name: 'Draftsman',
    initials: 'DM',
    email: 'drafts@yw.com',
    label: 'DRAFTSMAN',
    nav: jrNav,
  ),
  UserRole.liaisonManager: UserRoleInfo(
    name: 'Liaison Manager',
    initials: 'LM',
    email: 'liaisonmgr@yw.com',
    label: 'LIAISON_MANAGER',
    nav: liaisonManagerNav,
  ),
  UserRole.liaisonOfficer: UserRoleInfo(
    name: 'Liaison Officer',
    initials: 'LO',
    email: 'liaisonoff@yw.com',
    label: 'LIAISON_OFFICER',
    nav: liaisonFieldNav,
  ),
  UserRole.liaisonAssistant: UserRoleInfo(
    name: 'Liaison Assistant',
    initials: 'LA',
    email: 'liaisonasst@yw.com',
    label: 'LIAISON_ASSISTANT',
    nav: liaisonFieldNav,
  ),
};

class NavItem {
  final String key;
  final IconData iconData;
  final String label;

  const NavItem({required this.key, required this.iconData, required this.label});
}

const Map<String, NavItem> navConfig = {
  'dashboard': NavItem(key: 'dashboard', iconData: Icons.dashboard_rounded, label: 'Dashboard'),
  'clients': NavItem(key: 'clients', iconData: Icons.business_center_rounded, label: 'Clients'),
  'projects': NavItem(key: 'projects', iconData: Icons.folder_special_rounded, label: 'Projects'),
  'tasks': NavItem(key: 'tasks', iconData: Icons.task_alt_rounded, label: 'Tasks'),
  'employees': NavItem(key: 'employees', iconData: Icons.group_rounded, label: 'Employees'),
  'attendance': NavItem(key: 'attendance', iconData: Icons.fingerprint_rounded, label: 'Attendance'),
  'leaves': NavItem(key: 'leaves', iconData: Icons.event_available_rounded, label: 'Leaves'),
  'site': NavItem(key: 'site', iconData: Icons.construction_rounded, label: 'Site'),
  'materials': NavItem(key: 'materials', iconData: Icons.inventory_2_rounded, label: 'Materials'),
  'renders': NavItem(key: 'renders', iconData: Icons.view_in_ar_rounded, label: 'Renders'),
  'reports': NavItem(key: 'reports', iconData: Icons.analytics_rounded, label: 'Reports'),
  'notifications': NavItem(key: 'notifications', iconData: Icons.notifications_rounded, label: 'Alerts'),
  'profile': NavItem(key: 'profile', iconData: Icons.manage_accounts_rounded, label: 'Profile'),
};
