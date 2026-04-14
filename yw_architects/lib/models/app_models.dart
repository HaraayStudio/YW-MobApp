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
  final String firstName;
  final String lastName;
  final String initials;
  final String email;
  final String label;
  final List<String> nav;
  final String? profileImage;

  const UserRoleInfo({
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.initials,
    required this.email,
    required this.label,
    required this.nav,
    this.profileImage,
  });

  UserRoleInfo copyWith({
    String? name,
    String? firstName,
    String? lastName,
    String? initials,
    String? email,
    String? label,
    List<String>? nav,
    String? profileImage,
  }) {
    return UserRoleInfo(
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      label: label ?? this.label,
      nav: nav ?? this.nav,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

class AppUser {
  final int id;
  final UserRole role;
  final UserRoleInfo info;
  final String? token;

  const AppUser({
    required this.id,
    required this.role,
    required this.info,
    this.token,
  });

  AppUser copyWith({
    int? id,
    UserRole? role,
    UserRoleInfo? info,
    String? token,
  }) {
    return AppUser(
      id: id ?? this.id,
      role: role ?? this.role,
      info: info ?? this.info,
      token: token ?? this.token,
    );
  }
}

// Finalized Navigation Logic
const List<String> managementSidebarNav = [
  'dashboard',
  'clients',
  'enquiry',
  'projects',
  'site',
  'employees',
  'profile',
];
const List<String> managementBottomNav = [
  'dashboard',
  'projects',
  'clients',
  'employees',
];

const List<String> employeeSidebarNav = ['dashboard', 'projects', 'site'];
const List<String> employeeBottomNav = [
  'dashboard',
  'projects',
  'site',
  'attendance',
];

const Map<UserRole, UserRoleInfo> roleMap = {
  UserRole.admin: UserRoleInfo(
    name: 'Admin',
    firstName: 'Admin',
    lastName: '',
    initials: 'AD',
    email: 'admin@yw.com',
    label: 'ADMIN',
    nav: managementSidebarNav,
  ),
  UserRole.coFounder: UserRoleInfo(
    name: 'Co-Founder',
    firstName: 'Co-Founder',
    lastName: '',
    initials: 'CF',
    email: 'cofounder@yw.com',
    label: 'CO_FOUNDER',
    nav: managementSidebarNav,
  ),
  UserRole.hr: UserRoleInfo(
    name: 'HR Manager',
    firstName: 'HR',
    lastName: 'Manager',
    initials: 'HR',
    email: 'hr@yw.com',
    label: 'HR',
    nav: managementSidebarNav,
  ),
  UserRole.srArchitect: UserRoleInfo(
    name: 'Senior Architect',
    firstName: 'Senior',
    lastName: 'Architect',
    initials: 'SA',
    email: 'srarch@yw.com',
    label: 'SR_ARCHITECT',
    nav: employeeSidebarNav,
  ),
  UserRole.jrArchitect: UserRoleInfo(
    name: 'Junior Architect',
    firstName: 'Junior',
    lastName: 'Architect',
    initials: 'JA',
    email: 'jrarch@yw.com',
    label: 'JR_ARCHITECT',
    nav: employeeSidebarNav,
  ),
  UserRole.srEngineer: UserRoleInfo(
    name: 'Senior Engineer',
    firstName: 'Senior',
    lastName: 'Engineer',
    initials: 'SE',
    email: 'sreng@yw.com',
    label: 'SR_ENGINEER',
    nav: employeeSidebarNav,
  ),
  UserRole.draftsman: UserRoleInfo(
    name: 'Draftsman',
    firstName: 'Draftsman',
    lastName: '',
    initials: 'DM',
    email: 'drafts@yw.com',
    label: 'DRAFTSMAN',
    nav: employeeSidebarNav,
  ),
  UserRole.liaisonManager: UserRoleInfo(
    name: 'Liaison Manager',
    firstName: 'Liaison',
    lastName: 'Manager',
    initials: 'LM',
    email: 'liaisonmgr@yw.com',
    label: 'LIAISON_MANAGER',
    nav: employeeSidebarNav,
  ),
  UserRole.liaisonOfficer: UserRoleInfo(
    name: 'Liaison Officer',
    firstName: 'Liaison',
    lastName: 'Officer',
    initials: 'LO',
    email: 'liaisonoff@yw.com',
    label: 'LIAISON_OFFICER',
    nav: employeeSidebarNav,
  ),
  UserRole.liaisonAssistant: UserRoleInfo(
    name: 'Liaison Assistant',
    firstName: 'Liaison',
    lastName: 'Assistant',
    initials: 'LA',
    email: 'liaisonasst@yw.com',
    label: 'LIAISON_ASSISTANT',
    nav: employeeSidebarNav,
  ),
};

class NavItem {
  final String key;
  final IconData iconData;
  final String label;

  const NavItem({
    required this.key,
    required this.iconData,
    required this.label,
  });
}

const Map<String, NavItem> navConfig = {
  'dashboard': NavItem(
    key: 'dashboard',
    iconData: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
  'clients': NavItem(
    key: 'clients',
    iconData: Icons.business_center_rounded,
    label: 'Clients',
  ),
  'projects': NavItem(
    key: 'projects',
    iconData: Icons.folder_special_rounded,
    label: 'Projects',
  ),
  'tasks': NavItem(
    key: 'tasks',
    iconData: Icons.task_alt_rounded,
    label: 'Tasks',
  ),
  'employees': NavItem(
    key: 'employees',
    iconData: Icons.group_rounded,
    label: 'Employees',
  ),
  'attendance': NavItem(
    key: 'attendance',
    iconData: Icons.fingerprint_rounded,
    label: 'Attendance',
  ),
  'leaves': NavItem(
    key: 'leaves',
    iconData: Icons.event_available_rounded,
    label: 'Leaves',
  ),
  'site': NavItem(
    key: 'site',
    iconData: Icons.construction_rounded,
    label: 'Sites',
  ),
  'materials': NavItem(
    key: 'materials',
    iconData: Icons.inventory_2_rounded,
    label: 'Materials',
  ),
  'renders': NavItem(
    key: 'renders',
    iconData: Icons.view_in_ar_rounded,
    label: 'Renders',
  ),
  'reports': NavItem(
    key: 'reports',
    iconData: Icons.analytics_rounded,
    label: 'Reports',
  ),
  'notifications': NavItem(
    key: 'notifications',
    iconData: Icons.notifications_rounded,
    label: 'Alerts',
  ),
  'enquiry': NavItem(
    key: 'enquiry',
    iconData: Icons.question_answer_rounded,
    label: 'Enquiries',
  ),
  'profile': NavItem(
    key: 'profile',
    iconData: Icons.manage_accounts_rounded,
    label: 'Profile',
  ),
};

class Quotation {
  final int id;
  final String quotationNumber;
  final bool accepted;
  final bool sended;
  final String? validTill;
  final String? notes;
  final double? budget;
  final String? createdAt;

  const Quotation({
    required this.id,
    required this.quotationNumber,
    required this.accepted,
    required this.sended,
    this.validTill,
    this.notes,
    this.budget,
    this.createdAt,
  });

  /// Derived status matching web app logic: accepted > sent > draft
  String get status {
    if (accepted) return 'ACCEPTED';
    if (sended) return 'SENT';
    return 'DRAFT';
  }

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] ?? 0,
      quotationNumber: json['quotationNumber']?.toString() ?? '—',
      accepted: json['accepted'] == true,
      sended: json['sended'] == true,
      validTill: json['validTill']?.toString(),
      notes: json['quotationDetails']?.toString() ?? json['notes']?.toString(),
      budget: json['budget'] != null ? double.tryParse(json['budget'].toString()) : null,
      createdAt: json['createdAt']?.toString() ?? json['dateIssued']?.toString(),
    );
  }
}

class Client {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  Client({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'],
      phone: json['phone']?.toString(),
      address: json['address'],
    );
  }
}
