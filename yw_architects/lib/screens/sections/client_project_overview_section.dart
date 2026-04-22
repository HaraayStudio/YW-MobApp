import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_models.dart';
import '../../models/site_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/common_widgets.dart';
import '../../services/project_service.dart';
import '../../services/post_sales_service.dart';
import 'package:intl/intl.dart';

class ClientProjectOverviewSection extends StatefulWidget {
  final AppUser user;
  final int projectId;
  final VoidCallback onBack;

  const ClientProjectOverviewSection({
    super.key,
    required this.user,
    required this.projectId,
    required this.onBack,
  });

  @override
  State<ClientProjectOverviewSection> createState() =>
      _ClientProjectOverviewSectionState();
}

class _ClientProjectOverviewSectionState extends State<ClientProjectOverviewSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _projectData;
  Site? _siteData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      final results = await Future.wait([
        PostSalesService.getPostSaleByProjectId(widget.projectId),
        ProjectService.getProjectById(widget.projectId),
      ]);

      final postSale = results[0];
      final fullProject = results[1];

      if (postSale != null && fullProject != null) {
        // Build the site model from the full project data (which contains stages/structures)
        _siteData = Site.fromJson(fullProject);
        _projectData = postSale;
        // Inject full details into the project node if needed
        _projectData!['project'] = fullProject;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Error fetching client project overview: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_projectData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Project not found"),
            const SizedBox(height: 16),
            TextButton(onPressed: widget.onBack, child: const Text("Go Back")),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(project: _projectData!),
              _StagesTab(site: _siteData!),
              _DocumentsTab(site: _siteData!),
              _UpdatesTab(site: _siteData!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final project = _projectData!['project'] ?? {};
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, MediaQuery.of(context).padding.top + 10.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['projectName'] ?? "Unnamed Project",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      project['projectCode'] ?? "---",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(project['projectStatus'] ?? 'PLANNING'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.sp),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.sp),
        tabs: const [
          Tab(text: "Overview"),
          Tab(text: "Stages"),
          Tab(text: "Docs"),
          Tab(text: "Updates"),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// OVERVIEW TAB
// ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> project;
  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project['project'] ?? {};
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoCard("Project Details", [
            _infoRow(Icons.location_on_outlined, "Location", p['city'] ?? "N/A"),
            _infoRow(Icons.map_outlined, "Address", p['address'] ?? "N/A"),
            _infoRow(Icons.square_foot_outlined, "Area", "${p['plotArea'] ?? 'N/A'} sq.ft"),
          ]),
          SizedBox(height: 16.h),
          _infoCard("Timeline", [
            _infoRow(Icons.calendar_today_outlined, "Start Date", _fmt(p['projectStartDateTime'])),
            _infoRow(Icons.event_available_outlined, "Expected End", _fmt(p['projectExpectedEndDate'])),
          ]),
        ],
      ),
    );
  }

  String _fmt(dynamic d) {
    if (d == null) return "Pending";
    try {
      final dt = DateTime.parse(d.toString());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return "TBD";
    }
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return CardContainer(
      title: title,
      child: Column(children: rows),
    );
  }

  Widget _infoRow(IconData icon, String label, String val) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.w, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.onSurfaceVariant)),
                Text(val, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STAGES TAB
// ─────────────────────────────────────────────────────────────
class _StagesTab extends StatelessWidget {
  final Site site;
  const _StagesTab({required this.site});

  @override
  Widget build(BuildContext context) {
    if (site.stages.isEmpty) {
      return const Center(child: Text("No stages initialized yet."));
    }
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: site.stages.length,
      itemBuilder: (context, index) {
        final stage = site.stages[index];
        final bool isDone = stage.status == 'COMPLETED';
        return _buildStageTile(stage, isDone, index == site.stages.length - 1);
      },
    );
  }

  Widget _buildStageTile(SiteStage stage, bool isDone, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: isDone ? Icon(Icons.check, size: 14.w, color: Colors.white) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.primary.withValues(alpha: 0.3)),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: CardContainer(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.stageName,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          stage.status.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isDone ? Colors.green : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${stage.progressPercentage.toInt()}%",
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ProgressBar(percent: stage.progressPercentage / 100, height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DOCUMENTS TAB
// ─────────────────────────────────────────────────────────────
class _DocumentsTab extends StatelessWidget {
  final Site site;
  const _DocumentsTab({required this.site});

  @override
  Widget build(BuildContext context) {
    final allDocs = <StageDocument>[];
    for (var s in site.stages) {
      allDocs.addAll(s.documents);
      for (var cs in s.childStages) {
        allDocs.addAll(cs.documents);
      }
    }

    if (allDocs.isEmpty) {
      return const Center(child: Text("No documents shared yet."));
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: allDocs.length,
      itemBuilder: (context, index) {
        final doc = allDocs[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: CardContainer(
            padding: EdgeInsets.all(12.w),
            child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Icon(Icons.insert_drive_file_outlined, color: AppColors.primary, size: 20.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fileName ?? "Unnamed Document",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doc.documentType ?? "PDF",
                      style: TextStyle(fontSize: 10.sp, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {}, // Download logic placeholder
                icon: const Icon(Icons.download_rounded, color: AppColors.primary),
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// UPDATES TAB
// ─────────────────────────────────────────────────────────────
class _UpdatesTab extends StatelessWidget {
  final Site site;
  const _UpdatesTab({required this.site});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [];
    
    // Add document updates
    for (var s in site.stages) {
      for (var d in s.documents) {
        activities.add({
          'title': 'New Document: ${d.fileName}',
          'sub': 'Uploaded to ${s.stageName}',
          'date': d.uploadedAt ?? DateTime.now(),
          'icon': Icons.file_upload_outlined,
        });
      }
    }

    // Sort by date descending
    activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    if (activities.isEmpty) {
      return const Center(child: Text("No recent updates."));
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final act = activities[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                margin: EdgeInsets.only(top: 4.h),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM, hh:mm a').format(act['date'] as DateTime),
                      style: TextStyle(fontSize: 10.sp, color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      act['title'] as String,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
                    ),
                    Text(
                      act['sub'] as String,
                      style: TextStyle(fontSize: 11.sp, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
