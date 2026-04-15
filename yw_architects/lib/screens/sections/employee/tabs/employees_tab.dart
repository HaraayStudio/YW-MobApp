import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yw_architects/theme/app_theme.dart';
import 'package:yw_architects/widgets/common_widgets.dart';
import 'package:yw_architects/services/employee_service.dart';
import 'package:yw_architects/screens/sections/employee/models/employee_models.dart';
import 'package:yw_architects/screens/sections/employee/widgets/employee_widgets.dart';
import 'package:yw_architects/services/attendance_service.dart';
import 'package:yw_architects/services/project_service.dart';
import 'package:yw_architects/services/site_service.dart';

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
      if (!mounted) return;
      setState(() {
        _employees = rawData.map((e) => EmployeeModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      widget.onToast("Error loading employees: $e");
      setState(() => _isLoading = false);
    }
  }

  List<EmployeeModel> get filteredEmployees {
    return _employees.where((e) {
      final matchesDept = _selectedDept == 'All' || e.dept == _selectedDept;
      final matchesSearch =
          e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
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
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisExtent: 120,
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
          Icon(
            Icons.group_off_rounded,
            size: 64,
            color: AppColors.outlineVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No employees found",
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _DeptChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.outline,
          ),
        ),
      ),
    );
  }
}

class _EmployeeProfileView extends StatefulWidget {
  final EmployeeModel employee;
  final VoidCallback onBack;
  final Function(String) onToast;

  const _EmployeeProfileView({
    required this.employee,
    required this.onBack,
    required this.onToast,
  });

  @override
  State<_EmployeeProfileView> createState() => _EmployeeProfileViewState();
}

class _EmployeeProfileViewState extends State<_EmployeeProfileView> {
  bool _statsLoading = true;
  String _attendanceValueStr = '...';

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _statsLoading = true);
    try {
      final now = DateTime.now();

      // 1. Fetch Attendance & Count Days Present this month
      final attData = await AttendanceService.getAllEmployeesMonthlyAttendance(
        now.month,
        now.year,
      );
      
      // Filter for this specific user AND status 'PRESENT'
      final userRecords = attData.where((r) {
        // Attendance records often have nested user objects: r['user']['id']
        final userObj = r['user'] as Map<String, dynamic>?;
        final nestedId = userObj?['id']?.toString();
        final flatId = r['userId']?.toString();
        
        final userIdMatch = (nestedId == widget.employee.id.toString()) || 
                           (flatId == widget.employee.id.toString());
                           
        final statusMatch = r['status']?.toString().toUpperCase() == 'PRESENT';
        return userIdMatch && statusMatch;
      }).toList();

      debugPrint("[STATS DEBUG] ${widget.employee.name}: Attendance=${userRecords.length}");

      if (mounted) {
        setState(() {
          _attendanceValueStr = '${userRecords.length} Days';
          _statsLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching employee stats: $e");
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),
          const SizedBox(height: 20),
          _ProfileHero(
            e: widget.employee,
            onToast: widget.onToast,
            onRefresh: () {
              widget.onBack();
            },
          ),
          const SizedBox(height: 24),
          _buildStats(),
          const SizedBox(height: 24),
          _DetailsCard(e: widget.employee),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: widget.onBack,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Back to Directory',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return _StatBox(
      label: 'Monthly Presence',
      value: _statsLoading ? '...' : _attendanceValueStr,
      icon: Icons.fingerprint_rounded,
    );
  }
}

class _ProfileHero extends StatefulWidget {
  final EmployeeModel e;
  final Function(String) onToast;
  final VoidCallback onRefresh;

  const _ProfileHero({
    required this.e,
    required this.onToast,
    required this.onRefresh,
  });

  @override
  State<_ProfileHero> createState() => _ProfileHeroState();
}

class _ProfileHeroState extends State<_ProfileHero> {
  bool _isToggling = false;

  Future<void> _toggleStatus() async {
    final isActive = widget.e.status.toLowerCase() == 'active';
    final action = isActive ? "Deactivate" : "Activate";

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action Employee?'),
        content: Text('Are you sure you want to $action ${widget.e.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              action,
              style: TextStyle(
                color: isActive ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isToggling = true);
    try {
      bool success;
      if (isActive) {
        success = await EmployeeService.deleteEmployee(widget.e.id);
      } else {
        success = await EmployeeService.activateEmployee(widget.e.id);
      }

      if (success) {
        widget.onToast(
          isActive ? "Employee deactivated" : "Employee activated",
        );
        widget.onRefresh();
      } else {
        widget.onToast("Failed to update status");
      }
    } catch (e) {
      widget.onToast("Error: $e");
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  void _openEdit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditEmployeeModal(
        employee: widget.e,
        onToast: widget.onToast,
        onSuccess: widget.onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.e.status.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SmallIconButton(
                icon: Icons.edit_rounded,
                onTap: _openEdit,
                label: "Edit",
              ),
              if (_isToggling)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                _SmallIconButton(
                  icon: isActive
                      ? Icons.block_flipped
                      : Icons.check_circle_outline_rounded,
                  color: isActive ? Colors.red : Colors.green,
                  onTap: _toggleStatus,
                  label: isActive ? "Deactivate" : "Activate",
                ),
            ],
          ),
          const SizedBox(height: 8),
          AvatarWidget(initials: widget.e.initials, size: 72, fontSize: 24),
          const SizedBox(height: 16),
          Text(
            widget.e.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.e.roleLabel,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GoldChip(
                text: widget.e.status,
                bg: isActive ? AppColors.chipDoneBg : AppColors.chipHoldBg,
                fg: isActive ? AppColors.chipDoneFg : AppColors.chipHoldFg,
              ),
              const SizedBox(width: 8),
              GoldChip(
                text: 'Joined ${widget.e.since}',
                bg: AppColors.primary.withOpacity(0.1),
                fg: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          GoldGradientButton(
            text: 'Call',
            icon: Icons.call_rounded,
            height: 40,
            onTap: () => widget.onToast('Calling...'),
          ),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  final String label;

  const _SmallIconButton({
    required this.icon,
    this.color,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color ?? AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleAction(icon: icon),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
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
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
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
          _DetailRow(
            icon: Icons.badge_rounded,
            label: 'Employee ID',
            value: e.empId,
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.email_rounded,
            label: 'Email Address',
            value: e.email,
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.phone_android_rounded,
            label: 'Phone Number',
            value: e.phone,
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.apartment_rounded,
            label: 'Department',
            value: e.dept,
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.info_outline_rounded,
            label: 'Current Status',
            value: e.status,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
