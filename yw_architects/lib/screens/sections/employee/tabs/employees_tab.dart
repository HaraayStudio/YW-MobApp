import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yw_architects/theme/app_theme.dart';
import 'package:yw_architects/widgets/common_widgets.dart';
import 'package:yw_architects/services/employee_service.dart';
import 'package:yw_architects/screens/sections/employee/models/employee_models.dart';
import 'package:yw_architects/screens/sections/employee/widgets/employee_widgets.dart';

class EmployeesListTab extends StatefulWidget {
  final Function(String) onToast;
  const EmployeesListTab({super.key, required this.onToast});

  @override
  State<EmployeesListTab> createState() => _EmployeesListTabState();
}

class _EmployeesListTabState extends State<EmployeesListTab> {
  String _selectedDept = 'All';
  String _searchQuery = '';
  List<EmployeeModel> _employees = [];
  bool _isLoading = true;
  EmployeeModel? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await EmployeeService.getAllEmployees();
      setState(() {
        _employees = rawData.map((e) => EmployeeModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      widget.onToast("Error loading employees: $e");
      setState(() => _isLoading = false);
    }
  }

  List<EmployeeModel> get filteredEmployees {
    return _employees.where((e) {
      final matchesDept = _selectedDept == 'All' || e.dept == _selectedDept;
      final matchesSearch = e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.empId.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesDept && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedEmployee != null) {
      return _EmployeeProfileView(
        employee: _selectedEmployee!,
        onBack: () => setState(() => _selectedEmployee = null),
        onToast: widget.onToast,
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredEmployees.isEmpty
                  ? _buildEmptyState()
                  : _buildGrid(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: SectionHeader(
              title: "Employee Directory",
              subtitle: "Manage your studio team and roles",
            ),
          ),
          GoldGradientButton(
            text: "Add New",
            icon: Icons.add_rounded,
            width: 120,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddEmployeeModal(
                onToast: widget.onToast,
                onSuccess: _loadEmployees,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchField(
            hint: "Search by name or ID...",
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: deptTabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _DeptChip(
              label: deptTabs[i],
              isSelected: _selectedDept == deptTabs[i],
              onTap: () => setState(() => _selectedDept = deptTabs[i]),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisExtent: 100,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredEmployees.length,
      itemBuilder: (context, i) => EmployeeCard(
        employee: filteredEmployees[i],
        onToast: widget.onToast,
        onTap: () => setState(() => _selectedEmployee = filteredEmployees[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 64, color: AppColors.outlineVariant.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("No employees found", style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DeptChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _DeptChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.outline)),
      ),
    );
  }
}

class _EmployeeProfileView extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback onBack;
  final Function(String) onToast;
  const _EmployeeProfileView({required this.employee, required this.onBack, required this.onToast});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),
          const SizedBox(height: 20),
          _ProfileHero(e: employee, onToast: onToast),
          const SizedBox(height: 24),
          _buildStats(),
          const SizedBox(height: 24),
          _DetailsCard(e: employee),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: onBack,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text('Back to Directory', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(child: _StatBox(label: 'Projects', value: '${employee.projects}', icon: Icons.folder_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(label: 'Tasks', value: '${employee.tasksDone}', icon: Icons.task_alt_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(label: 'Attendance', value: employee.attendance, icon: Icons.fingerprint_rounded)),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final EmployeeModel e;
  final Function(String) onToast;
  const _ProfileHero({required this.e, required this.onToast});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          AvatarWidget(initials: e.initials, size: 72, fontSize: 24),
          const SizedBox(height: 16),
          Text(e.name, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Text(e.roleLabel, style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GoldChip(text: e.status, bg: e.status.toLowerCase() == 'active' ? AppColors.chipDoneBg : AppColors.chipHoldBg, fg: e.status.toLowerCase() == 'active' ? AppColors.chipDoneFg : AppColors.chipHoldFg),
              const SizedBox(width: 8),
              GoldChip(text: 'Joined ${e.since}', bg: AppColors.primary.withOpacity(0.1), fg: AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),
          GoldGradientButton(text: 'Call', icon: Icons.call_rounded, height: 40, onTap: () => onToast('Calling...')),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatBox({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleAction(icon: icon),
              const Spacer(),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  const _CircleAction({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(999)),
      child: Icon(icon, size: 18, color: AppColors.onSurface),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final EmployeeModel e;
  const _DetailsCard({required this.e});
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      title: 'Official Contact Details',
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _DetailRow(icon: Icons.badge_rounded, label: 'Employee ID', value: e.empId),
          const Divider(height: 32),
          _DetailRow(icon: Icons.email_rounded, label: 'Email Address', value: e.email),
          const Divider(height: 32),
          _DetailRow(icon: Icons.phone_android_rounded, label: 'Phone Number', value: e.phone),
          const Divider(height: 32),
          _DetailRow(icon: Icons.apartment_rounded, label: 'Department', value: e.dept),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          ],
        ),
      ],
    );
  }
}
