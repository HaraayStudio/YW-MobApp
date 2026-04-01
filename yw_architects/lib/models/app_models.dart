import 'package:flutter/material.dart';

enum UserRole { admin, senior, junior, interior, site, visualizer, hr }

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
}

class AppUser {
  final UserRole role;
  final UserRoleInfo info;

  const AppUser({required this.role, required this.info});
}

const Map<UserRole, UserRoleInfo> roleMap = {
  UserRole.admin: UserRoleInfo(
    name: 'Founder / Admin',
    initials: 'AD',
    email: 'admin@gmail.com',
    label: 'Founder / Admin',
    nav: ['dashboard', 'projects', 'employees', 'reports', 'notifications', 'profile'],
  ),
  UserRole.senior: UserRoleInfo(
    name: 'Senior Architect',
    initials: 'SA',
    email: 'srarchitect@gmail.com',
    label: 'Senior Architect',
    nav: ['dashboard', 'projects', 'tasks', 'leaves', 'notifications', 'profile'],
  ),
  UserRole.junior: UserRoleInfo(
    name: 'Junior Architect',
    initials: 'JA',
    email: 'jrarchitect@gmail.com',
    label: 'Junior Architect',
    nav: ['dashboard', 'tasks', 'attendance', 'leaves', 'notifications', 'profile'],
  ),
  UserRole.interior: UserRoleInfo(
    name: 'Interior Designer',
    initials: 'ID',
    email: 'interior@gmail.com',
    label: 'Interior Designer',
    nav: ['dashboard', 'tasks', 'materials', 'attendance', 'leaves', 'notifications', 'profile'],
  ),
  UserRole.site: UserRoleInfo(
    name: 'Site Engineer',
    initials: 'SE',
    email: 'site@gmail.com',
    label: 'Site Engineer',
    nav: ['dashboard', 'site', 'tasks', 'attendance', 'leaves', 'notifications', 'profile'],
  ),
  UserRole.visualizer: UserRoleInfo(
    name: '3D Visualizer',
    initials: '3V',
    email: 'visualizer@gmail.com',
    label: '3D Visualizer',
    nav: ['dashboard', 'tasks', 'renders', 'attendance', 'leaves', 'notifications', 'profile'],
  ),
  UserRole.hr: UserRoleInfo(
    name: 'Admin / HR',
    initials: 'HR',
    email: 'hr@gmail.com',
    label: 'Admin / HR',
    nav: ['dashboard', 'employees', 'attendance', 'leaves', 'notifications', 'profile'],
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
