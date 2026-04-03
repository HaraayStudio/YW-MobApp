import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import '../../services/employee_service.dart';
// ← ADDED: import the service

// ══════════════════════════════════════════════════════════════
//  EMPLOYEES SECTION
//  Add Employee form matches backend JSON schema exactly:
//  firstName, lastName, email, phone, password, status,
//  role, birthDate, gender, bloodGroup, joinDate,
//  leaveDate, adharNumber, panNumber
// ══════════════════════════════════════════════════════════════

// ── Employee data model ───────────────────────────────────────
class _Employee {
  final String name;
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

  const _Employee({
    required this.name,
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
}

// ── Sample employees ──────────────────────────────────────────
const _employees = [
  _Employee(name: 'Yash Wadekar',   roleLabel: 'Co-Founder',       role: UserRole.coFounder,       dept: 'Management',     status: 'Active',   since: 'Jan 2018', email: 'yash@ywarchitects.com',        phone: '+91 98000 00001', empId: 'YW-2018-001', initials: 'YW', projects: 8, tasksDone: 120, attendance: '98%'),
  _Employee(name: 'Supriya W.',     roleLabel: 'Admin',             role: UserRole.admin,           dept: 'Administration', status: 'Active',   since: 'Feb 2018', email: 'admin@ywarchitects.com',        phone: '+91 98000 00002', empId: 'YW-2018-002', initials: 'SW', projects: 8, tasksDone: 98,  attendance: '97%'),
  _Employee(name: 'Anita Deshmukh', roleLabel: 'HR',                role: UserRole.hr,              dept: 'Human Resources',status: 'Active',   since: 'Mar 2019', email: 'hr@ywarchitects.com',           phone: '+91 98000 00003', empId: 'YW-2019-003', initials: 'AD', projects: 0, tasksDone: 45,  attendance: '96%'),
  _Employee(name: 'Rahul Kapoor',   roleLabel: 'Senior Architect',  role: UserRole.srArchitect,     dept: 'Architecture',   status: 'Active',   since: 'Jan 2021', email: 'srarchitect@ywarchitects.com',  phone: '+91 98000 00004', empId: 'YW-2021-004', initials: 'RK', projects: 3, tasksDone: 88,  attendance: '94%'),
  _Employee(name: 'Neha Joshi',     roleLabel: 'Senior Architect',  role: UserRole.srArchitect,     dept: 'Architecture',   status: 'Active',   since: 'Jun 2021', email: 'neha@ywarchitects.com',         phone: '+91 98000 00005', empId: 'YW-2021-005', initials: 'NJ', projects: 2, tasksDone: 74,  attendance: '95%'),
  _Employee(name: 'Kavya Rao',      roleLabel: 'Junior Architect',  role: UserRole.jrArchitect,     dept: 'Architecture',   status: 'Active',   since: 'Jun 2023', email: 'jrarchitect@ywarchitects.com',  phone: '+91 98000 00006', empId: 'YW-2023-006', initials: 'KR', projects: 2, tasksDone: 34,  attendance: '92%'),
  _Employee(name: 'Meera Nair',     roleLabel: 'Junior Architect',  role: UserRole.jrArchitect,     dept: 'Architecture',   status: 'On Leave', since: 'Dec 2023', email: 'meera@ywarchitects.com',         phone: '+91 98000 00007', empId: 'YW-2023-007', initials: 'MN', projects: 1, tasksDone: 18,  attendance: '89%'),
  _Employee(name: 'Amit Joshi',     roleLabel: 'Senior Engineer',   role: UserRole.srEngineer,      dept: 'Construction',   status: 'Active',   since: 'Jul 2020', email: 'srengineer@ywarchitects.com',   phone: '+91 98000 00008', empId: 'YW-2020-008', initials: 'AJ', projects: 4, tasksDone: 102, attendance: '96%'),
  _Employee(name: 'Rajan Shinde',   roleLabel: 'Draftsman',         role: UserRole.draftsman,       dept: 'Drafting',       status: 'Active',   since: 'Apr 2022', email: 'draftsman@ywarchitects.com',    phone: '+91 98000 00010', empId: 'YW-2022-010', initials: 'RS', projects: 5, tasksDone: 67,  attendance: '93%'),
  _Employee(name: 'Suresh Kumar',   roleLabel: 'Liaison Manager',   role: UserRole.liaisonManager,  dept: 'Liaison',        status: 'Active',   since: 'May 2020', email: 'lmanager@ywarchitects.com',     phone: '+91 98000 00012', empId: 'YW-2020-012', initials: 'SK', projects: 5, tasksDone: 79,  attendance: '97%'),
  _Employee(name: 'Pooja Sharma',   roleLabel: 'Liaison Officer',   role: UserRole.liaisonOfficer,  dept: 'Liaison',        status: 'Active',   since: 'Aug 2021', email: 'lofficer@ywarchitects.com',     phone: '+91 98000 00013', empId: 'YW-2021-013', initials: 'PS', projects: 3, tasksDone: 52,  attendance: '92%'),
  _Employee(name: 'Tanvi Patil',    roleLabel: 'Liaison Assistant', role: UserRole.liaisonAssistant,dept: 'Liaison',        status: 'Active',   since: 'Mar 2023', email: 'lassistant@ywarchitects.com',   phone: '+91 98000 00015', empId: 'YW-2023-015', initials: 'TP', projects: 2, tasksDone: 22,  attendance: '88%'),
];

const _deptTabs = ['All', 'Management', 'Architecture', 'Construction', 'Drafting', 'Liaison', 'Human Resources'];

// ── Role label → backend string ───────────────────────────────
String _roleToBackend(UserRole role) {
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
  }
}

// ══════════════════════════════════════════════════════════════
//  MAIN SECTION WIDGET
// ══════════════════════════════════════════════════════════════
class EmployeesSection extends StatefulWidget {
  final Function(String) onToast;
  const EmployeesSection({super.key, required this.onToast});

  @override
  State<EmployeesSection> createState() => _EmployeesSectionState();
}

class _EmployeesSectionState extends State<EmployeesSection> {
  _Employee? _selectedEmployee;
  int _selectedTab = 0;
  final _searchCtrl = TextEditingController();

  List<_Employee> get _filtered {
    var list = _employees.toList();
    if (_selectedTab > 0) {
      final dept = _deptTabs[_selectedTab];
      list = list.where((e) => e.dept == dept).toList();
    }
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) =>
        e.name.toLowerCase().contains(q) ||
        e.roleLabel.toLowerCase().contains(q) ||
        e.dept.toLowerCase().contains(q),
      ).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEmployeeModal(onToast: widget.onToast),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedEmployee != null) return _buildProfile(_selectedEmployee!);
    return _buildList();
  }

  // ── LIST VIEW ─────────────────────────────────────────────────────────────
  Widget _buildList() {
    final list = _filtered;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SectionHeader(
                  title: 'Employees',
                  subtitle: '${_employees.length} team members',
                ),
              ),
              GestureDetector(
                onTap: _openAddModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: goldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          Container(
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'Search employees...',
                hintStyle: TextStyle(color: AppColors.outline, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dept filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _deptTabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: i == _selectedTab ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _deptTabs[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i == _selectedTab ? Colors.white : AppColors.outline,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (list.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text('No employees found', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            ),

          // Employee cards
          ...list.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _EmployeeCard(
              employee: e,
              onTap: () => setState(() => _selectedEmployee = e),
              onToast: widget.onToast,
            ),
          )),
        ],
      ),
    );
  }

  // ── PROFILE VIEW ──────────────────────────────────────────────────────────
  Widget _buildProfile(_Employee e) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedEmployee = null),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                Text('Back to Employees', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hero card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                AvatarWidget(initials: e.initials, size: 68, fontSize: 22),
                const SizedBox(height: 10),
                Text(e.name, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Text('${e.roleLabel} · ${e.dept}', style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    GoldChip(text: e.status, bg: e.status == 'Active' ? AppColors.chipDoneBg : AppColors.chipHoldBg, fg: e.status == 'Active' ? AppColors.chipDoneFg : AppColors.chipHoldFg),
                    GoldChip(text: 'SINCE ${e.since.toUpperCase()}', bg: AppColors.primary.withOpacity(0.10), fg: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionBtn(label: 'Call',  icon: Icons.call_rounded,  onTap: () => widget.onToast('Calling ${e.name}...'),  gradient: true),
                    const SizedBox(width: 10),
                    _ActionBtn(label: 'Email', icon: Icons.mail_rounded,  onTap: () => widget.onToast('Opening email...'),       gradient: false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(children: [
            _ProfileStat('${e.projects}', 'Projects'),
            const SizedBox(width: 10),
            _ProfileStat('${e.tasksDone}', 'Tasks Done'),
            const SizedBox(width: 10),
            _ProfileStat(e.attendance, 'Attendance'),
          ]),
          const SizedBox(height: 14),

          CardContainer(
            child: Column(
              children: [
                _InfoRow(Icons.mail_rounded,          'Email',       e.email),
                _InfoRow(Icons.phone_rounded,          'Phone',       e.phone),
                _InfoRow(Icons.badge_rounded,          'Employee ID', e.empId),
                _InfoRow(Icons.home_work_rounded,      'Department',  e.dept),
                _InfoRow(Icons.calendar_today_rounded, 'Joined',      e.since),
              ].map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: w)).toList(),
            ),
          ),
          const SizedBox(height: 14),

          CardContainer(child: _RoleManager(currentRole: e.role, onToast: widget.onToast)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ADD EMPLOYEE MODAL
// ══════════════════════════════════════════════════════════════
class _AddEmployeeModal extends StatefulWidget {
  final Function(String) onToast;
  const _AddEmployeeModal({required this.onToast});

  @override
  State<_AddEmployeeModal> createState() => _AddEmployeeModalState();
}

class _AddEmployeeModalState extends State<_AddEmployeeModal> {

  // ── Controllers ───────────────────────────────────────────────────────────
  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _adharCtrl       = TextEditingController();
  final _panCtrl         = TextEditingController();

  // ── Dropdown / picker state ───────────────────────────────────────────────
  UserRole _selectedRole   = UserRole.jrArchitect;
  String   _selectedStatus = 'ACTIVE';
  String   _selectedGender = 'MALE';
  String   _selectedBlood  = 'B+';

  DateTime? _birthDate;
  DateTime? _joinDate;
  DateTime? _leaveDate;

  bool _pwVisible  = false;
  bool _isLoading  = false;

  // ── Options ───────────────────────────────────────────────────────────────
  static const _statuses    = ['ACTIVE', 'INACTIVE', 'ON_LEAVE'];
  static const _genders     = ['MALE', 'FEMALE', 'OTHER'];
  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _adharCtrl.dispose();
    _panCtrl.dispose();
    super.dispose();
  }

  // ── Date picker helper ────────────────────────────────────────────────────
  Future<void> _pickDate(BuildContext context, {required bool isBirth}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirth ? DateTime(now.year - 25) : now,
      firstDate: isBirth ? DateTime(1960) : DateTime(2000),
      lastDate: isBirth ? DateTime(now.year - 18) : DateTime(now.year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surfaceContainerLowest,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isBirth) _birthDate = picked;
        else         _joinDate  = picked;
      });
    }
  }

  // ── Format date for API ───────────────────────────────────────────────────
  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validate() {
    if (_firstNameCtrl.text.trim().isEmpty) return 'First name is required';
    if (_lastNameCtrl.text.trim().isEmpty)  return 'Last name is required';
    if (_emailCtrl.text.trim().isEmpty)     return 'Email is required';
    if (!_emailCtrl.text.contains('@'))     return 'Enter a valid email';
    if (_passwordCtrl.text.length < 6)      return 'Password must be at least 6 characters';
    if (_phoneCtrl.text.trim().isEmpty)     return 'Phone number is required';
    if (_birthDate == null)                 return 'Date of birth is required';
    if (_joinDate == null)                  return 'Join date is required';
    if (_adharCtrl.text.trim().length != 12) return 'Aadhaar must be 12 digits';
    if (_panCtrl.text.trim().length != 10)   return 'PAN must be 10 characters';
    return null;
  }

  // ── Build the JSON payload ────────────────────────────────────────────────
  Map<String, dynamic> _buildPayload() {
    return {
      'firstName':   _firstNameCtrl.text.trim(),
      'lastName':    _lastNameCtrl.text.trim(),
      'email':       _emailCtrl.text.trim(),
      'phone':       _phoneCtrl.text.trim(),
      'password':    _passwordCtrl.text.trim(),
      'status':      _selectedStatus,
      'role':        _roleToBackend(_selectedRole),
      'birthDate':   _fmtDate(_birthDate),
      'gender':      _selectedGender,
      'bloodGroup':  _selectedBlood,
      'joinDate':    _fmtDate(_joinDate),
      'leaveDate':   _fmtDate(_leaveDate),
      'adharNumber': _adharCtrl.text.trim(),
      'panNumber':   _panCtrl.text.trim().toUpperCase(),
    };
  }

  // ── Submit — calls POST /api/employees/createemployee ────────────────────
  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      widget.onToast(error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await EmployeeService.createEmployee(_buildPayload());
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          widget.onToast('Employee added successfully!');
        } else {
          widget.onToast('Failed to add employee. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onToast('Network error: $e');
      }
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(999)),
              ),
            ),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Employee', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SECTION 1 — Basic Info
            _SectionLabel('Basic Information'),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(child: _FormField(label: 'FIRST NAME', hint: 'Rahul',  controller: _firstNameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _FormField(label: 'LAST NAME',  hint: 'Sharma', controller: _lastNameCtrl)),
            ]),
            const SizedBox(height: 12),

            _FormField(label: 'WORK EMAIL', hint: 'rahul@ywarchitects.com', controller: _emailCtrl, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),

            _FormField(label: 'PHONE', hint: '+91 98765 43210', controller: _phoneCtrl, keyboard: TextInputType.phone),
            const SizedBox(height: 12),

            _PasswordField(controller: _passwordCtrl, visible: _pwVisible, onToggle: () => setState(() => _pwVisible = !_pwVisible)),
            const SizedBox(height: 20),

            // SECTION 2 — Role & Status
            _SectionLabel('Role & Status'),
            const SizedBox(height: 12),

            _DropdownLabel('ROLE'),
            const SizedBox(height: 6),
            _RoleDropdown(
              value: _selectedRole,
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(child: _SimpleDropdown(
                label: 'STATUS',
                value: _selectedStatus,
                items: _statuses,
                onChanged: (v) => setState(() => _selectedStatus = v!),
              )),
              const SizedBox(width: 12),
              Expanded(child: _SimpleDropdown(
                label: 'GENDER',
                value: _selectedGender,
                items: _genders,
                onChanged: (v) => setState(() => _selectedGender = v!),
              )),
            ]),
            const SizedBox(height: 12),

            _SimpleDropdown(
              label: 'BLOOD GROUP',
              value: _selectedBlood,
              items: _bloodGroups,
              onChanged: (v) => setState(() => _selectedBlood = v!),
            ),
            const SizedBox(height: 20),

            // SECTION 3 — Dates
            _SectionLabel('Dates'),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(child: _DatePickerField(
                label: 'DATE OF BIRTH',
                value: _birthDate,
                hint: 'Select DOB',
                onTap: () => _pickDate(context, isBirth: true),
                fmtDate: _fmtDate,
              )),
              const SizedBox(width: 12),
              Expanded(child: _DatePickerField(
                label: 'JOIN DATE',
                value: _joinDate,
                hint: 'Select date',
                onTap: () => _pickDate(context, isBirth: false),
                fmtDate: _fmtDate,
              )),
            ]),
            const SizedBox(height: 20),

            // SECTION 4 — Identity Documents
            _SectionLabel('Identity Documents'),
            const SizedBox(height: 12),

            _FormField(
              label: 'AADHAAR NUMBER',
              hint: '12-digit number',
              controller: _adharCtrl,
              keyboard: TextInputType.number,
              maxLength: 12,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            _FormField(
              label: 'PAN NUMBER',
              hint: 'e.g. ABCDE1234F',
              controller: _panCtrl,
              keyboard: TextInputType.text,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                UpperCaseTextFormatter(),
              ],
            ),
            const SizedBox(height: 28),

            // Submit button
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : GoldGradientButton(
                    text: 'Add Employee',
                    icon: Icons.person_add_rounded,
                    onTap: _submit,
                  ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  REUSABLE FORM WIDGETS
// ══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primaryContainer, width: 3)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboard,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DropdownLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            isDense: true,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;
  const _PasswordField({required this.controller, required this.visible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DropdownLabel('PASSWORD'),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !visible,
          style: const TextStyle(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Min. 6 characters',
            hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            isDense: true,
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(visible ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final UserRole value;
  final ValueChanged<UserRole?> onChanged;
  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(14),
          dropdownColor: AppColors.surfaceContainerLowest,
          style: const TextStyle(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w500),
          icon: const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant, size: 18),
          onChanged: onChanged,
          selectedItemBuilder: (_) => roleMap.entries.map((entry) => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              entry.value.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          items: roleMap.entries.map((entry) => DropdownMenuItem<UserRole>(
            value: entry.key,
            child: Text(
              entry.value.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class _SimpleDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _SimpleDropdown({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DropdownLabel(label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(14),
              dropdownColor: AppColors.surfaceContainerLowest,
              style: const TextStyle(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w500),
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant, size: 18),
              onChanged: onChanged,
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String hint;
  final DateTime? value;
  final VoidCallback onTap;
  final String Function(DateTime?) fmtDate;
  const _DatePickerField({required this.label, required this.hint, required this.value, required this.onTap, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DropdownLabel(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? fmtDate(value) : hint,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: value != null ? AppColors.onSurface : AppColors.outline,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownLabel extends StatelessWidget {
  final String text;
  const _DropdownLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) {
    return newVal.copyWith(text: newVal.text.toUpperCase(), selection: newVal.selection);
  }
}

// ══════════════════════════════════════════════════════════════
//  OTHER SECTION WIDGETS (unchanged)
// ══════════════════════════════════════════════════════════════

class _EmployeeCard extends StatelessWidget {
  final _Employee employee;
  final VoidCallback onTap;
  final Function(String) onToast;

  const _EmployeeCard({required this.employee, required this.onTap, required this.onToast});

  @override
  Widget build(BuildContext context) {
    final e = employee;
    return GestureDetector(
      onTap: onTap,
      child: CardContainer(
        child: Row(
          children: [
            AvatarWidget(initials: e.initials, size: 48, fontSize: 15),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      GoldChip(
                        text: e.status,
                        bg: e.status == 'Active' ? AppColors.chipDoneBg : AppColors.chipHoldBg,
                        fg: e.status == 'Active' ? AppColors.chipDoneFg : AppColors.chipHoldFg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(e.roleLabel, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text('${e.projects} projects', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      const SizedBox(width: 10),
                      const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text('Since ${e.since}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconBtn(Icons.call_rounded, () => onToast('Calling ${e.name}...')),
                const SizedBox(height: 4),
                _IconBtn(Icons.mail_rounded, () => onToast('Opening email...')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleManager extends StatefulWidget {
  final UserRole currentRole;
  final Function(String) onToast;
  const _RoleManager({required this.currentRole, required this.onToast});

  @override
  State<_RoleManager> createState() => _RoleManagerState();
}

class _RoleManagerState extends State<_RoleManager> {
  late UserRole _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Role & Permissions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface)),
        const SizedBox(height: 14),
        const Text('ASSIGNED ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserRole>(
              value: _selected,
              isExpanded: true,
              borderRadius: BorderRadius.circular(14),
              dropdownColor: AppColors.surfaceContainerLowest,
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface, fontWeight: FontWeight.w500),
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant, size: 20),
              onChanged: (v) => setState(() => _selected = v!),
              selectedItemBuilder: (_) => roleMap.entries.map((entry) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  entry.value.label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              items: roleMap.entries.map((entry) => DropdownMenuItem<UserRole>(
                value: entry.key,
                child: Text(entry.value.label, style: const TextStyle(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GoldGradientButton(
          text: 'Update Role',
          verticalPadding: 14,
          onTap: () => widget.onToast('Role updated to ${roleMap[_selected]!.label}!'),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool gradient;
  const _ActionBtn({required this.label, required this.icon, required this.onTap, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient ? goldGradient : null,
          color: gradient ? null : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: gradient ? Colors.white : AppColors.onSurface),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: gradient ? Colors.white : AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
