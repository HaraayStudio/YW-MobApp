import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../services/project_service.dart';
import '../../services/post_sales_service.dart';
import '../../widgets/common_widgets.dart';

import 'overview_tab_view.dart';
import 'client_tab_view.dart';
import 'sites_tab_view.dart';
import 'proforma_tab_view.dart';
import 'tax_tab_view.dart';
import 'payments_tab_view.dart';

class PostSaleDetailView extends StatefulWidget {
  final int projectId;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int projectId)? onNavigateToSite;
  final AppUser user;

  const PostSaleDetailView({
    Key? key,
    required this.user,
    required this.projectId,
    required this.onBack,
    required this.onEdit,
    this.onNavigateToSite,
  }) : super(key: key);

  @override
  State<PostSaleDetailView> createState() => _PostSaleDetailViewState();
}

class _PostSaleDetailViewState extends State<PostSaleDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _project;
  bool _isLoading = true;

  bool get _isManagement => [
    UserRole.admin,
    UserRole.coFounder,
    UserRole.hr,
  ].contains(widget.user.role);

  @override
  void initState() {
    super.initState();
    final bool showAllTabs = _isManagement || widget.user.role == UserRole.client;
    _tabController = TabController(length: showAllTabs ? 6 : 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch both the overarching PostSale mapped graph AND the raw Full Project (to get heavy fields like Address & Area missed by LiteDTO)
      final postSaleFuture = PostSalesService.getPostSaleByProjectId(
        widget.projectId,
      );
      final fullProjectFuture = ProjectService.getProjectById(widget.projectId);

      final results = await Future.wait([postSaleFuture, fullProjectFuture]);
      final postSaleRes = results[0];
      final fullProjectRes = results[1];

      if (postSaleRes != null && fullProjectRes != null) {
        // Overwrite the lightweight ProjectLiteDTO with the heavy Project payload
        postSaleRes['project'] = fullProjectRes;
      }

      if (mounted) {
        setState(() {
          _project = postSaleRes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Column(
        children: [
          SizedBox(height: 100),
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      );
    }

    if (_project == null) {
      return Column(
        children: [
          const SizedBox(height: 100),
          const Center(child: Text('Failed to load project details')),
          TextButton(onPressed: widget.onBack, child: const Text('Back')),
        ],
      );
    }

    // Determine derived identities
    final projectNode = _project!['project'] ?? {};
    final clientNode = _project!['client'] ?? {};

    final pName =
        projectNode['projectName'] ??
        projectNode['project_name'] ??
        'Unknown Project';
    final pCode =
        projectNode['projectCode'] ?? projectNode['project_code'] ?? '—';
    final clientId = clientNode['id']?.toString() ?? 'N/A';
    final date =
        projectNode['projectCreatedDateTime']?.toString().split('T').first ??
        '';

    final status = projectNode['projectStatus']?.toString() ?? 'IN_PROGRESS';

    final isNotified = _project!['notified'] == true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nav row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Back to Projects',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_isManagement || widget.user.role == UserRole.client)
                IconButton.filled(
                  onPressed: () => widget.onEdit(_project!),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Header Card
          CardContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fake Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.apartment_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pName.toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '#${_project!['id']}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '•',
                                style: TextStyle(
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                pCode.toString(),
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _PostSaleStatusBadge(status: status),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isNotified
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isNotified
                                        ? const Color(
                                            0xFF16A34A,
                                          ).withOpacity(0.3)
                                        : const Color(
                                            0xFFD97706,
                                          ).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isNotified
                                          ? Icons.check_circle_rounded
                                          : Icons.warning_amber_rounded,
                                      size: 14,
                                      color: isNotified
                                          ? const Color(0xFF166534)
                                          : const Color(0xFFB45309),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isNotified
                                          ? 'Client Notified'
                                          : 'Not Notified',
                                      style: TextStyle(
                                        color: isNotified
                                            ? const Color(0xFF166534)
                                            : const Color(0xFFB45309),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabs row
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              tabs: [
                const Tab(text: 'Overview'),
                const Tab(text: 'Client'),
                const Tab(text: 'Sites'),
                if (_isManagement || widget.user.role == UserRole.client) ...[
                  const Tab(text: 'Proforma Invoices'),
                  const Tab(text: 'Tax Invoices'),
                  const Tab(text: 'Payments'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab Views
          Expanded(
            child: IndexedStack(
              index: _tabController.index,
              children: [
                OverviewTabView(project: _project!, user: widget.user),
                ClientTabView(project: _project!),
                SitesTabView(
                  project: _project!,
                  onOpenSite: widget.onNavigateToSite != null
                      ? () => widget.onNavigateToSite!(widget.projectId)
                      : null,
                ),
                if (_isManagement || widget.user.role == UserRole.client) ...[
                  ProformaTabView(
                    project: _project!,
                    user: widget.user,
                    onRefresh: _fetchData,
                    onTabRequest: (idx) => _tabController.animateTo(idx),
                  ),
                  TaxTabView(
                    project: _project!,
                    user: widget.user,
                    onRefresh: _fetchData,
                  ),
                  PaymentsTabView(
                    project: _project!,
                    user: widget.user,
                    onRefresh: _fetchData,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostSaleStatusBadge extends StatelessWidget {
  final String status;
  const _PostSaleStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFE0F2FE);
    Color fg = const Color(0xFF0369A1);
    Color dot = const Color(0xFF0284C7);

    if (status == 'IN_PROGRESS' || status == 'IN PROGRESS') {
      bg = const Color(0xFFFEF9C3);
      fg = const Color(0xFF854D0E);
      dot = const Color(0xFFCA8A04);
    } else if (status == 'COMPLETED') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF166534);
      dot = const Color(0xFF16A34A);
    } else if (status == 'CANCELLED') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF991B1B);
      dot = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.replaceFirst('_', ' '),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
