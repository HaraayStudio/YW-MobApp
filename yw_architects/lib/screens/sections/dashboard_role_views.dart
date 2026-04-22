import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/app_models.dart';
import '../../services/employee_service.dart';
import '../../services/project_service.dart';
import '../../services/client_service.dart';
import '../../services/inquiry_service.dart';
import '../../services/attendance_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../theme/app_theme.dart';
import '../../services/post_sales_service.dart';

// ─────────────────────────────────────────────────────────────
//  ManagementDashboardView (Admin, Co-Founder, HR)
// ─────────────────────────────────────────────────────────────
class ManagementDashboardView extends StatefulWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const ManagementDashboardView({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  State<ManagementDashboardView> createState() =>
      _ManagementDashboardViewState();
}

class _ManagementDashboardViewState extends State<ManagementDashboardView> {
  bool _isLoading = true;
  int _totalProjects = 0;
  int _totalClients = 0;
  int _totalEmployees = 0;
  int _totalLeads = 0;
  List<dynamic> _recentProjects = [];
  Map<String, int> _statusDistribution = {};
  Map<String, double> _monthlyProjects = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    try {
      final results = await Future.wait([
        ProjectService.getAllProjects(),
        ClientService.getAllClients(),
        EmployeeService.getAllEmployees(),
        InquiryService.getAllInquiries(),
      ]);

      final projects = results[0];
      final clients = results[1];
      final emps = results[2];
      final leads = results[3];

      // Calculate distributions
      final distro = <String, int>{};
      for (var p in projects) {
        final s =
            p['projectStatus']?.toString().replaceAll('_', ' ') ?? 'UNKNOWN';
        distro[s] = (distro[s] ?? 0) + 1;
      }

      // Monthly projects (last 6 months)
      final monthly = <String, double>{};
      for (int i = 5; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        final key = DateFormat('MMM').format(d);
        monthly[key] = 0;
      }

      for (var p in projects) {
        final dtStr = p['projectCreatedDateTime'];
        if (dtStr != null) {
          final dt = DateTime.tryParse(dtStr);
          if (dt != null) {
            final key = DateFormat('MMM').format(dt);
            if (monthly.containsKey(key)) {
              monthly[key] = (monthly[key] ?? 0) + 1;
            }
          }
        }
      }

      setState(() {
        _totalProjects = projects.length;
        _totalClients = clients.length;
        _totalEmployees = emps.length;
        _totalLeads = leads.length;
        _recentProjects = projects.take(5).toList();
        _statusDistribution = distro;
        _monthlyProjects = monthly;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Dashboard data error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const DashboardSkeleton();
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title:
                  'Good ${AppTheme.getGreeting()}, ${widget.user.info.firstName} 👋',
              subtitle: DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
            ),
            const SizedBox(height: 12),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // Square ratio to prevent vertical overflows
              children: [
                DashboardStatCard(
                  label: 'Total Projects',
                  value: _totalProjects.toString(),
                  icon: Icons.architecture_rounded,
                  color: AppColors.primary,
                ),
                DashboardStatCard(
                  label: 'Total Leads',
                  value: _totalLeads.toString(),
                  icon: Icons.leaderboard_rounded,
                  color: Colors.orange,
                ),
                DashboardStatCard(
                  label: 'Total Clients',
                  value: _totalClients.toString(),
                  icon: Icons.groups_rounded,
                  color: Colors.blue,
                ),
                DashboardStatCard(
                  label: 'Staff Count',
                  value: _totalEmployees.toString(),
                  icon: Icons.person_search_rounded,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Charts
            DashboardBarChart(
              title: 'Project Inflow (6 Months)',
              data: _monthlyProjects,
            ),
            const SizedBox(height: 16),
            DashboardDonutChart(
              title: 'Project Status',
              data: _statusDistribution,
              colors: const [
                AppColors.primary,
                Colors.blue,
                Colors.orange,
                Colors.green,
                Colors.red,
                Colors.grey,
              ],
            ),
            const SizedBox(height: 28),

            // Recent Projects
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Projects',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate('projects'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._recentProjects
                .map((p) => _RecentProjectTile(project: p))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _RecentProjectTile extends StatelessWidget {
  final dynamic project;
  final VoidCallback? onTap;
  const _RecentProjectTile({required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Handle both flat Project objects and nested PostSale objects
    final bool isPostSale = project is Map && project.containsKey('project');
    final pData = isPostSale ? project['project'] : project;

    final status = (pData['projectStatus'] ?? 'UNKNOWN').toString().replaceAll(
      '_',
      ' ',
    );
    final name = pData['projectName'] ?? 'Unnamed Project';
    final code = pData['projectCode'] ?? '---';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: CardContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.architecture_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EmployeeDashboardView (Sr/Jr Architect, etc.)
// ─────────────────────────────────────────────────────────────
class EmployeeDashboardView extends StatefulWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const EmployeeDashboardView({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  State<EmployeeDashboardView> createState() => _EmployeeDashboardViewState();
}

class _EmployeeDashboardViewState extends State<EmployeeDashboardView> {
  bool _isLoading = true;
  List<dynamic> _myProjects = [];
  Map<String, dynamic>? _todayAttendance;
  int _completedCount = 0;
  double _completionRate = 0.0;
  Timer? _clockTimer;
  String _currentTimeString = "";

  @override
  void initState() {
    super.initState();
    _currentTimeString = DateFormat('hh:mm:ss a').format(DateTime.now());
    _startClock();
    _fetchData();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTimeString = DateFormat('hh:mm:ss a').format(DateTime.now());
        });
      }
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    try {
      final results = await Future.wait([
        EmployeeService.getMyProjects(),
        AttendanceService.getMyMonthlyAttendance(
          now.month,
          now.year,
        ), // Personalized for timing sync
      ]);

      final projects = results[0];
      final attendanceList = results[1];

      // Match by today's date for 100% parity with Attendance section
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final myToday = attendanceList.cast<Map<String, dynamic>>().firstWhere(
        (a) => a['attendanceDate'] == todayStr,
        orElse: () => {},
      );
      int comp = 0;
      for (var p in projects) {
        if (p['projectStatus'] == 'COMPLETED') comp++;
      }

      setState(() {
        _myProjects = projects.take(5).toList();
        _todayAttendance = myToday.isEmpty ? null : myToday;
        _completedCount = comp;
        _completionRate = projects.isEmpty ? 0 : (comp / projects.length);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Employee dashboard error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckIn() async {
    // Explicit duplicate check
    if (_todayAttendance != null && _todayAttendance!['checkIn'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already Checked In for today!')),
      );
      return;
    }

    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final time = DateFormat('HH:mm:ss').format(now);
    final success = await AttendanceService.recordMyCheckIn(date, time);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Check-In Successful')));
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-In Failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCheckOut() async {
    // Check if check-in exists before checking out
    if (_todayAttendance == null || _todayAttendance!['checkIn'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Check-In first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Explicit duplicate check for checkout
    if (_todayAttendance!['checkOut'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already Checked Out for today!')),
      );
      return;
    }

    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final time = DateFormat('HH:mm:ss').format(now);
    final success = await AttendanceService.recordMyCheckOut(
      date,
      time,
      'PRESENT',
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Check-Out Successful')));
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-Out Failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const DashboardSkeleton();
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title:
                  'Good ${AppTheme.getGreeting()}, ${widget.user.info.firstName} 👋',
              subtitle: widget.user.info.label.replaceAll('_', ' '),
            ),
            const SizedBox(height: 12),

            // Attendance Card
            DashboardAttendanceCard(
              checkIn: _todayAttendance?['checkIn'],
              checkOut: _todayAttendance?['checkOut'],
              workingHours: _calculateHours(),
              currentTime: _currentTimeString,
              todayDate: DateFormat('EEEE, d MMMM').format(DateTime.now()),
              onCheckIn: _handleCheckIn,
              onCheckOut: _handleCheckOut,
            ),
            const SizedBox(height: 24),

            // Performance Bar
            CardContainer(
              title: 'My Productivity',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Project Completion',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(_completionRate * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProgressBar(percent: _completionRate),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // My Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // Square ratio to prevent vertical overflows
              children: [
                DashboardStatCard(
                  label: 'Assigned Projects',
                  value: _myProjects.length.toString(),
                  icon: Icons.assignment_rounded,
                  color: AppColors.primary,
                ),
                DashboardStatCard(
                  label: 'Completed',
                  value: _completedCount.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Active Projects
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Active Projects',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate('projects'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._myProjects.map((p) => _RecentProjectTile(project: p)).toList(),
          ],
        ),
      ),
    );
  }

  String _calculateHours() {
    if (_todayAttendance == null ||
        _todayAttendance!['checkIn'] == null ||
        _todayAttendance!['checkOut'] == null) {
      return "0h";
    }
    try {
      final cin = DateFormat('HH:mm:ss').parse(_todayAttendance!['checkIn']);
      final cout = DateFormat('HH:mm:ss').parse(_todayAttendance!['checkOut']);
      final diff = cout.difference(cin);
      return "${diff.inHours}h ${diff.inMinutes % 60}m";
    } catch (_) {
      return "0h";
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  ClientDashboardView
// ─────────────────────────────────────────────────────────────
class ClientDashboardView extends StatefulWidget {
  final AppUser user;
  final Function(String) onNavigate;

  const ClientDashboardView({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  State<ClientDashboardView> createState() => _ClientDashboardViewState();
}

class _ClientDashboardViewState extends State<ClientDashboardView> {
  bool _isLoading = true;
  List<dynamic> _preSales = [];
  List<dynamic> _postSales = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant ClientDashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent screen late-resolves the user ID, we need to completely reset and refetch our data
    if (widget.user.id != oldWidget.user.id && widget.user.id != 0) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final clientId = widget.user.id;

    try {
      final results = await Future.wait([
        InquiryService.getAllInquiries(),
        PostSalesService.getPostSalesByClient(clientId),
      ]);

      final allInquiries = results[0];
      final clientPostSales = results[1];

      setState(() {
        _preSales = allInquiries
            .where((i) => i['client']?['id'] == clientId)
            .toList();
        _postSales = clientPostSales;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Client dashboard error: $e");
      setState(() => _isLoading = false);
    }
  }

  Map<String, int> _getStatusData() {
    final Map<String, int> stats = {};
    for (var p in _postSales) {
      final status = (p['project']?['projectStatus'] ?? 'PLANNING')
          .toString()
          .replaceAll('_', ' ');
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, double> _getProgressData() {
    final Map<String, double> progress = {};
    for (var p in _postSales) {
      final name = (p['project']?['projectName'] ?? 'P-${p['id']}').toString();
      // Calculate progress from stages if available, else use a placeholder or 0
      double pct = 0.0;
      if (p['project']?['stages'] != null) {
        final stages = p['project']['stages'] as List;
        if (stages.isNotEmpty) {
          final sum = stages.fold(
            0.0,
            (s, e) => s + ((e['progressPercentage'] ?? 0.0) as num).toDouble(),
          );
          pct = sum / stages.length;
        }
      }
      progress[name.length > 8 ? name.substring(0, 8) : name] = pct;
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const DashboardSkeleton();
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Welcome back,\n${widget.user.info.firstName} 👋',
              subtitle: 'Track your project status & inquiries',
            ),
            const SizedBox(height: 12),

            // Top Stats
            Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    label: 'Inquiries',
                    value: _preSales.length.toString(),
                    icon: Icons.question_answer_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardStatCard(
                    label: 'Projects',
                    value: _postSales.length.toString(),
                    icon: Icons.architecture_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Charts
            if (_postSales.isNotEmpty) ...[
              DashboardDonutChart(
                title: 'Project Status Distribution',
                data: _getStatusData(),
                colors: const [
                  AppColors.primary,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                ],
              ),
              const SizedBox(height: 24),
              DashboardBarChart(
                title: 'Project Completion %',
                data: _getProgressData(),
              ),
              const SizedBox(height: 24),
            ],

            // Info Card
            CardContainer(
              title: 'Customer Details',
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    val: widget.user.info.email,
                  ),
                  const Divider(height: 24),
                  const _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    val: '+91 98765 43210',
                  ),
                  const Divider(height: 24),
                  const _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    val: 'Pune, Maharashtra',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // List Headers
            const Text(
              'Active Projects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (_postSales.isEmpty)
              const Center(
                child: Text(
                  'No active projects found',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              )
            else
              ..._postSales
                  .map(
                    (p) => _RecentProjectTile(
                      project: p,
                      onTap: () => widget.onNavigate(
                        'project_${p['project']?['projectId'] ?? p['id']}',
                      ),
                    ),
                  )
                  .toList(),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String val;
  const _InfoRow({required this.icon, required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              val,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
