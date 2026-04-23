import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:yw_architects/theme/app_theme.dart';
import 'package:yw_architects/widgets/common_widgets.dart';
import 'package:yw_architects/utils/responsive.dart';
import 'package:yw_architects/services/employee_service.dart';
import 'package:yw_architects/screens/sections/employee/models/employee_models.dart';
import 'package:yw_architects/screens/sections/employee/widgets/employee_widgets.dart';
import 'package:yw_architects/services/attendance_service.dart';
import 'package:yw_architects/utils/contact_helper.dart';

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
              ? GridView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500.w,
                    mainAxisExtent: 130.h,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, i) => const EmployeeCardSkeleton(),
                )
              : filteredEmployees.isEmpty
              ? _buildEmptyState()
              : _buildGrid(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 15.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SectionHeader(
              title: "Employee Directory",
              subtitle: "Manage your studio team and roles",
            ),
          ),
          SizedBox(width: 12.w),
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
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500.w,
        mainAxisExtent: 130.h,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
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
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
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
  List<dynamic> _presentRecords = []; 
  DateTime _viewDate = DateTime.now(); // Track the currently viewed month

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _statsLoading = true;
      _attendanceValueStr = '...';
    });
    try {
      // Use the currently selected _viewDate instead of current month
      final month = _viewDate.month;
      final year = _viewDate.year;

      final attData = await AttendanceService.getAllEmployeesMonthlyAttendance(
        month,
        year,
      );

      // Filter for this specific user AND status 'PRESENT'
      final userRecords = attData.where((r) {
        // Attendance records often have nested user objects: r['user']['id']
        final userObj = r['user'] as Map<String, dynamic>?;
        final nestedId = userObj?['id']?.toString();
        final flatId = r['userId']?.toString();

        final userIdMatch =
            (nestedId == widget.employee.id.toString()) ||
            (flatId == widget.employee.id.toString());

        final statusMatch = r['status']?.toString().toUpperCase() == 'PRESENT';
        return userIdMatch && statusMatch;
      }).toList();

      debugPrint(
        "[STATS DEBUG] ${widget.employee.name}: Attendance=${userRecords.length}",
      );

      if (mounted) {
        setState(() {
          _presentRecords = userRecords;
          _attendanceValueStr = '${userRecords.length} Days';
          _statsLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching employee stats: $e");
      if (mounted) {
        setState(() {
          _attendanceValueStr = '0 Days';
          _presentRecords = [];
          _statsLoading = false;
        });
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewDate = DateTime(_viewDate.year, _viewDate.month + delta);
    });
    _fetchStats();
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
          _buildMonthSelector(),
          const SizedBox(height: 16),
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

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
            visualDensity: VisualDensity.compact,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_viewDate),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            visualDensity: VisualDensity.compact,
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
      onViewHistory: _presentRecords.isEmpty ? null : _showAttendanceHistory,
    );
  }

  void _showAttendanceHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AttendanceHistorySheet(
        employeeName: widget.employee.name,
        records: _presentRecords,
      ),
    );
  }
}

class _AttendanceHistorySheet extends StatelessWidget {
  final String employeeName;
  final List<dynamic> records;

  const _AttendanceHistorySheet({
    required this.employeeName,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    // Sort records by date descending
    final sortedRecords = List.from(records);
    sortedRecords.sort((a, b) {
      final dateA = a['date']?.toString() ?? '';
      final dateB = b['date']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance History',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employeeName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (records.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('No present records found for this month.'),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sortedRecords.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = sortedRecords[index];
                  // Check all possible date fields from backend
                  final dateRaw = record['date'] ?? record['attendanceDate'] ?? record['checkInDate'];
                  final dateStr = dateRaw?.toString() ?? 'Unknown Date';
                  
                  final checkIn = record['checkIn']?.toString() ?? '--:--';
                  final checkOut = record['checkOut']?.toString() ?? '--:--';
                  
                  // Simple formatting if YYYY-MM-DD
                  String formattedDate = dateStr;
                  if (dateStr != 'Unknown Date') {
                    try {
                      // Handle 'YYYY-MM-DD 10:00:00' format
                      final cleanDate = dateStr.split(' ')[0]; 
                      final dt = DateTime.parse(cleanDate);
                      formattedDate = "${_getDayName(dt.weekday)}, ${dt.day} ${_getMonthName(dt.month)}";
                    } catch (_) {
                      // Fallback: Just show the raw string if parsing fails
                      formattedDate = dateStr;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Check-in: $checkIn  •  Check-out: $checkOut',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const GoldChip(
                          text: 'Present',
                          bg: AppColors.chipDoneBg,
                          fg: AppColors.chipDoneFg,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
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
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
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
          const SizedBox(height: 4),
          AvatarWidget(initials: widget.e.initials, size: 72, fontSize: 24),
          const SizedBox(height: 12),
          Text(
            widget.e.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.e.roleLabel,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
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
                bg: AppColors.primary.withValues(alpha: 0.1),
                fg: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GoldGradientButton(
                  text: 'Call',
                  icon: Icons.call_rounded,
                  height: 40,
                  onTap: () => ContactHelper.makeCall(widget.e.phone),
                  onLongPress: () => ContactHelper.copyToClipboard(widget.e.phone, widget.onToast),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => ContactHelper.sendEmail(widget.e.email),
                    onLongPress: () => ContactHelper.copyToClipboard(widget.e.email, widget.onToast),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email_rounded, size: 18, color: AppColors.onSurface),
                        const SizedBox(width: 8),
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
              color: (color ?? AppColors.primary).withValues(alpha: 0.1),
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
  final VoidCallback? onViewHistory;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    this.onViewHistory,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              if (onViewHistory != null)
                TextButton(
                  onPressed: onViewHistory,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'View History',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
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
            onToast: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.email_rounded,
            label: 'Email Address',
            value: e.email,
            onToast: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.phone_android_rounded,
            label: 'Phone Number',
            value: e.phone,
            onToast: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.apartment_rounded,
            label: 'Department',
            value: e.dept,
            onToast: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.info_outline_rounded,
            label: 'Current Status',
            value: e.status,
            onToast: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
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
  final Function(String) onToast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onToast,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => ContactHelper.copyToClipboard(value, onToast),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
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
      ),
    );
  }
}
