import 'package:yw_architects/models/app_models.dart';

class EmployeeModel {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String roleLabel;
  final UserRole role;
  final String dept;
  final String status;
  final String since;
  final String email;
  final String phone;
  final String empId;
  final String initials;
  final int projects;
  final int tasksDone;
  final String attendance;

  const EmployeeModel({
    this.id = 0,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.roleLabel,
    required this.role,
    required this.dept,
    required this.status,
    required this.since,
    required this.email,
    required this.phone,
    required this.empId,
    required this.initials,
    required this.projects,
    required this.tasksDone,
    required this.attendance,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final fName = json['firstName']?.toString() ?? 'Unknown';
    final lName = json['lastName']?.toString() ?? '';
    final roleStr = json['role']?.toString() ?? '';
    
    UserRole parsedRole = backendToRole(roleStr);
    final basicRoleInfo = roleMap[parsedRole] ?? roleMap[UserRole.admin]!;

    return EmployeeModel(
      id: json['id'] as int? ?? 0,
      name: '$fName $lName'.trim(),
      firstName: fName,
      lastName: lName,
      roleLabel: basicRoleInfo.name, 
      role: parsedRole,
      dept: roleToDept(parsedRole),
      status: json['status']?.toString() ?? 'Active',
      since: json['joinDate']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      empId: 'YW-${(json['id'] ?? '0').toString().padLeft(3, '0')}',
      initials: (fName.isNotEmpty ? fName[0] : '') + (lName.isNotEmpty ? lName[0] : ''),
      projects: 0,
      tasksDone: 0,
      attendance: '100%',
    );
  }
}

UserRole backendToRole(String val) {
  switch (val.trim().toUpperCase()) {
    case 'ADMIN': return UserRole.admin;
    case 'CO_FOUNDER': return UserRole.coFounder;
    case 'HR': return UserRole.hr;
    case 'SR_ARCHITECT': return UserRole.srArchitect;
    case 'JR_ARCHITECT': return UserRole.jrArchitect;
    case 'SR_ENGINEER': return UserRole.srEngineer;
    case 'DRAFTSMAN': return UserRole.draftsman;
    case 'LIAISON_MANAGER': return UserRole.liaisonManager;
    case 'LIAISON_OFFICER': return UserRole.liaisonOfficer;
    case 'LIAISON_ASSISTANT': return UserRole.liaisonAssistant;
    case 'CLIENT': return UserRole.client;
    default: return UserRole.jrArchitect;
  }
}

String roleToDept(UserRole role) {
  switch (role) {
    case UserRole.admin: return 'Administration';
    case UserRole.coFounder: return 'Management';
    case UserRole.hr: return 'Human Resources';
    case UserRole.srArchitect:
    case UserRole.jrArchitect: return 'Architecture';
    case UserRole.srEngineer: return 'Construction';
    case UserRole.draftsman: return 'Drafting';
    case UserRole.liaisonManager:
    case UserRole.liaisonOfficer:
    case UserRole.liaisonAssistant: return 'Liaison';
    case UserRole.client: return 'Client';
  }
}

String roleToBackend(UserRole role) {
  switch (role) {
    case UserRole.admin:            return 'ADMIN';
    case UserRole.coFounder:        return 'CO_FOUNDER';
    case UserRole.hr:               return 'HR';
    case UserRole.srArchitect:      return 'SR_ARCHITECT';
    case UserRole.jrArchitect:      return 'JR_ARCHITECT';
    case UserRole.srEngineer:       return 'SR_ENGINEER';
    case UserRole.draftsman:        return 'DRAFTSMAN';
    case UserRole.liaisonManager:   return 'LIAISON_MANAGER';
    case UserRole.liaisonOfficer:   return 'LIAISON_OFFICER';
    case UserRole.liaisonAssistant: return 'LIAISON_ASSISTANT';
    case UserRole.client:           return 'CLIENT';
  }
}

const deptTabs = ['All', 'Management', 'Architecture', 'Construction', 'Drafting', 'Liaison', 'Human Resources'];
