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
  client,
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
  final String phone;
  final String joinDate;
  final String address;
  final String gstCertificate;
  final String pan;

  const UserRoleInfo({
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.initials,
    required this.email,
    required this.label,
    required this.nav,
    this.profileImage,
    this.phone = '',
    this.joinDate = '',
    this.address = '',
    this.gstCertificate = '',
    this.pan = '',
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
    String? phone,
    String? joinDate,
    String? address,
    String? gstCertificate,
    String? pan,
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
      phone: phone ?? this.phone,
      joinDate: joinDate ?? this.joinDate,
      address: address ?? this.address,
      gstCertificate: gstCertificate ?? this.gstCertificate,
      pan: pan ?? this.pan,
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

// Full access: 'dashboard', 'projects', 'tasks', 'employees', 'attendance', 'leaves', 'site', 'materials', 'renders', 'reports', 'notifications', 'profile', 'enquiry'
const List<String> managementSidebarNav = ['dashboard', 'clients', 'enquiry', 'projects', 'site', 'employees', 'attendance', 'profile'];
const List<String> managementBottomNav = ['dashboard', 'projects', 'clients', 'employees'];
const List<String> employeeSidebarNav = ['dashboard', 'projects', 'site', 'attendance', 'profile'];
const List<String> employeeBottomNav = ['dashboard', 'projects', 'site', 'attendance'];
const List<String> clientSidebarNav = ['dashboard', 'projects', 'site', 'profile'];
const List<String> clientBottomNav = ['dashboard', 'projects', 'site', 'profile'];

const List<String> fullNav = ['dashboard', 'projects', 'tasks', 'employees', 'attendance', 'leaves', 'site', 'materials', 'renders', 'reports', 'notifications', 'profile', 'enquiry'];
const List<String> hrNav = ['dashboard', 'employees', 'attendance', 'leaves', 'notifications', 'profile'];
const List<String> srNav = ['dashboard', 'projects', 'tasks', 'leaves', 'notifications', 'profile'];
const List<String> jrNav = ['dashboard', 'tasks', 'attendance', 'leaves', 'notifications', 'profile'];
const List<String> liaisonManagerNav = ['dashboard', 'projects', 'tasks', 'attendance', 'leaves', 'notifications', 'profile'];
const List<String> liaisonFieldNav = ['dashboard', 'site', 'tasks', 'attendance', 'leaves', 'notifications', 'profile'];

const Map<UserRole, UserRoleInfo> roleMap = {
  UserRole.admin: UserRoleInfo(
    name: 'Admin',
    firstName: 'Admin',
    lastName: '',
    initials: 'AD',
    email: 'admin@yw.com',
    label: 'ADMIN',
    nav: fullNav,
  ),
  UserRole.coFounder: UserRoleInfo(
    name: 'Co-Founder',
    firstName: 'Co-Founder',
    lastName: '',
    initials: 'CF',
    email: 'cofounder@yw.com',
    label: 'CO_FOUNDER',
    nav: fullNav,
  ),
  UserRole.hr: UserRoleInfo(
    name: 'HR Manager',
    firstName: 'HR',
    lastName: 'Manager',
    initials: 'HR',
    email: 'hr@yw.com',
    label: 'HR',
    nav: hrNav,
  ),
  UserRole.srArchitect: UserRoleInfo(
    name: 'Senior Architect',
    firstName: 'Senior',
    lastName: 'Architect',
    initials: 'SA',
    email: 'srarch@yw.com',
    label: 'SR_ARCHITECT',
    nav: srNav,
  ),
  UserRole.jrArchitect: UserRoleInfo(
    name: 'Junior Architect',
    firstName: 'Junior',
    lastName: 'Architect',
    initials: 'JA',
    email: 'jrarch@yw.com',
    label: 'JR_ARCHITECT',
    nav: jrNav,
  ),
  UserRole.srEngineer: UserRoleInfo(
    name: 'Senior Engineer',
    firstName: 'Senior',
    lastName: 'Engineer',
    initials: 'SE',
    email: 'sreng@yw.com',
    label: 'SR_ENGINEER',
    nav: srNav,
  ),
  UserRole.draftsman: UserRoleInfo(
    name: 'Draftsman',
    firstName: 'Draftsman',
    lastName: '',
    initials: 'DM',
    email: 'drafts@yw.com',
    label: 'DRAFTSMAN',
    nav: jrNav,
  ),
  UserRole.liaisonManager: UserRoleInfo(
    name: 'Liaison Manager',
    firstName: 'Liaison',
    lastName: 'Manager',
    initials: 'LM',
    email: 'liaisonmgr@yw.com',
    label: 'LIAISON_MANAGER',
    nav: liaisonManagerNav,
  ),
  UserRole.liaisonOfficer: UserRoleInfo(
    name: 'Liaison Officer',
    firstName: 'Liaison',
    lastName: 'Officer',
    initials: 'LO',
    email: 'liaisonoff@yw.com',
    label: 'LIAISON_OFFICER',
    nav: liaisonFieldNav,
  ),
  UserRole.liaisonAssistant: UserRoleInfo(
    name: 'Liaison Assistant',
    firstName: 'Liaison',
    lastName: 'Assistant',
    initials: 'LA',
    email: 'liaisonasst@yw.com',
    label: 'LIAISON_ASSISTANT',
    nav: liaisonFieldNav,
  ),
  UserRole.client: UserRoleInfo(
    name: 'Client',
    firstName: 'Client',
    lastName: '',
    initials: 'CL',
    email: 'client@yw.com',
    label: 'CLIENT',
    nav: clientSidebarNav,
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
  'clients': NavItem(key: 'clients', iconData: Icons.people_alt_rounded, label: 'Clients'),
  'attendance': NavItem(key: 'attendance', iconData: Icons.fingerprint_rounded, label: 'Attendance'),
  'leaves': NavItem(key: 'leaves', iconData: Icons.event_available_rounded, label: 'Leaves'),
  'site': NavItem(key: 'site', iconData: Icons.construction_rounded, label: 'Site'),
  'materials': NavItem(key: 'materials', iconData: Icons.inventory_2_rounded, label: 'Materials'),
  'renders': NavItem(key: 'renders', iconData: Icons.view_in_ar_rounded, label: 'Renders'),
  'reports': NavItem(key: 'reports', iconData: Icons.analytics_rounded, label: 'Reports'),
  'notifications': NavItem(key: 'notifications', iconData: Icons.notifications_rounded, label: 'Alerts'),
  'profile': NavItem(key: 'profile', iconData: Icons.manage_accounts_rounded, label: 'Profile'),
  'enquiry': NavItem(key: 'enquiry', iconData: Icons.question_answer_rounded, label: 'Inquiry'),
};

// ── Shared Models ─────────────────────────────────────────────────────────

class Client {
  final int id;
  final String name;
  final String email;
  final String phone;

  const Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
    );
  }
}

class Quotation {
  final int id;
  final String quotationNumber;
  final String title;
  final double amount;
  final String status;
  final String? notes;
  final String? createdAt;
  final bool sended;
  final bool accepted;

  const Quotation({
    required this.id,
    required this.quotationNumber,
    required this.title,
    required this.amount,
    required this.status,
    this.notes,
    this.createdAt,
    this.sended = false,
    this.accepted = false,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] as int? ?? 0,
      quotationNumber: json['quotationNumber']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'DRAFT',
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
      sended: json['sended'] == true || json['sended'] == 'true',
      accepted: json['accepted'] == true || json['accepted'] == 'true',
    );
  }
}
