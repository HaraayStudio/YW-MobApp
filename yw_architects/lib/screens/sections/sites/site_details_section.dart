import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../models/site_model.dart';
import '../../../services/employee_service.dart';
import '../../../services/post_sales_service.dart';
import '../../../services/project_service.dart';
import '../../../services/site_visit_service.dart';
import '../../../services/meeting_service.dart';
import '../../../services/rera_service.dart';
import '../../../services/stage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:url_launcher/url_launcher.dart';
import '../../../models/app_models.dart';

class SiteDetailsSection extends StatefulWidget {
  final Site site;
  final VoidCallback onBack;
  final Function(int) onEditProject;
  final AppUser user;

  const SiteDetailsSection({
    super.key,
    required this.user,
    required this.site,
    required this.onBack,
    required this.onEditProject,
  });

  @override
  State<SiteDetailsSection> createState() => _SiteDetailsSectionState();
}

class _SiteDetailsSectionState extends State<SiteDetailsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool get _isManager => [
    UserRole.admin,
    UserRole.coFounder,
    UserRole.hr
  ].contains(widget.user.role);

  late Site _detailedSite;
  bool _isLoading = false;

  // NUCLEAR DEBUG STORAGE
  String? _rawPostSalesJson;
  String? _rawProjectJson;

  List<Map<String, dynamic>> get _tabs => [
    {'label': 'Overview', 'icon': Icons.dashboard_outlined},
    {
      'label': 'Stages',
      'icon': Icons.account_tree_outlined,
      'count': _detailedSite.stages.length,
    },
    {
      'label': 'Documents',
      'icon': Icons.folder_open_outlined,
      'count': _allDocuments.length,
    },
    {
      'label': 'Team',
      'icon': Icons.people_outline,
      'count': _detailedSite.team.isNotEmpty ? _detailedSite.team.length : null,
    },
    {
      'label': 'Site Visits',
      'icon': Icons.location_on_outlined,
      'count': _detailedSite.visits.length,
    },
    {
      'label': 'Structures',
      'icon': Icons.business_outlined,
      'count': _detailedSite.structures.length,
    },
    {
      'label': 'Meetings',
      'icon': Icons.handshake_outlined,
      'count': _detailedSite.meetings.length,
    },
    {
      'label': 'RERA',
      'icon': Icons.assignment_outlined,
      'count': _detailedSite.reraProjects.length,
    },
  ];

  List<Map<String, dynamic>> get _allDocuments {
    final docs = <Map<String, dynamic>>[];
    final seenIds = <int>{};
    _recursiveCollectDocs(_detailedSite.stages, docs, seenIds);
    return docs;
  }

  void _recursiveCollectDocs(
    List<SiteStage> stages,
    List<Map<String, dynamic>> results,
    Set<int> seenIds,
  ) {
    for (var stage in stages) {
      if (stage.documents.isNotEmpty) {
        for (var doc in stage.documents) {
          if (!seenIds.contains(doc.id)) {
            results.add({'doc': doc, 'stageName': stage.stageName});
            seenIds.add(doc.id);
          }
        }
      }
      if (stage.childStages.isNotEmpty) {
        _recursiveCollectDocs(stage.childStages, results, seenIds);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _detailedSite = widget.site;
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    setState(() => _isLoading = true);
    try {
      int idToFetch = _detailedSite.projectId > 0
          ? _detailedSite.projectId
          : _detailedSite.id;

      debugPrint("INITIATING DATA SYNC FOR PROJECT ID: $idToFetch");

      // PRIMARY: Use ProjectService — same service the working Projects screen uses.
      // Reads directly from raw JSON, no Site.fromJson() transformation.
      try {
        final raw = await ProjectService.getProjectById(idToFetch);
        final meetingsRaw = await MeetingService.getMeetingsByProject(
          idToFetch,
        );
        final reraRaw = await ReraService.getReraByProjectId(idToFetch);
        if (mounted && raw != null) {
          _rawProjectJson = raw.toString();
          debugPrint("✅ RAW PROJECT FETCHED — keys: ${raw.keys.toList()}");
          debugPrint(
            "   city=${raw['city']}, address=${raw['address']}, priority=${raw['priority']}",
          );

          // Helper: safely parse a double from dynamic value
          double? parseDbl(dynamic v) => v == null
              ? null
              : (v is num ? v.toDouble() : double.tryParse(v.toString()));

          setState(() {
            _detailedSite = _detailedSite.copyWith(
              // Identity
              siteName: (raw['projectName'] ?? '').toString().isNotEmpty
                  ? raw['projectName'].toString()
                  : _detailedSite.siteName,
              status: (raw['projectStatus'] ?? '').toString().isNotEmpty
                  ? raw['projectStatus'].toString()
                  : _detailedSite.status,
              projectCode: (raw['projectCode'] ?? '').toString().isNotEmpty
                  ? raw['projectCode'].toString()
                  : _detailedSite.projectCode,
              permanentProjectId:
                  (raw['permanentProjectId'] ?? '').toString().isNotEmpty
                  ? raw['permanentProjectId'].toString()
                  : _detailedSite.permanentProjectId,
              projectDetails:
                  raw['projectDetails']?.toString() ??
                  _detailedSite.projectDetails,
              logoUrl: raw['logoUrl']?.toString() ?? _detailedSite.logoUrl,
              priority: (raw['priority'] ?? '').toString().isNotEmpty
                  ? raw['priority'].toString()
                  : _detailedSite.priority,

              // Location — read exactly like web app: p.city, p.address
              city: (raw['city'] ?? '').toString().isNotEmpty
                  ? raw['city'].toString()
                  : _detailedSite.city,
              address: (raw['address'] ?? '').toString().isNotEmpty
                  ? raw['address'].toString()
                  : _detailedSite.address,
              latitude: parseDbl(raw['latitude']) ?? _detailedSite.latitude,
              longitude: parseDbl(raw['longitude']) ?? _detailedSite.longitude,

              // Area — read exactly like web app: p.plotArea, p.totalBuiltUpArea
              plotArea: parseDbl(raw['plotArea']) ?? _detailedSite.plotArea,
              builtUpArea:
                  parseDbl(raw['totalBuiltUpArea']) ??
                  _detailedSite.builtUpArea,
              totalCarpetArea:
                  parseDbl(raw['totalCarpetArea']) ??
                  _detailedSite.totalCarpetArea,

              // Dates — read exactly like web app: p.projectCreatedDateTime etc.
              createdAt:
                  DateTime.tryParse(
                    raw['projectCreatedDateTime']?.toString() ?? '',
                  ) ??
                  _detailedSite.createdAt,
              projectStartDateTime:
                  DateTime.tryParse(
                    raw['projectStartDateTime']?.toString() ?? '',
                  ) ??
                  _detailedSite.projectStartDateTime,
              projectExpectedEndDate:
                  DateTime.tryParse(
                    raw['projectExpectedEndDate']?.toString() ?? '',
                  ) ??
                  _detailedSite.projectExpectedEndDate,
              projectEndDateTime:
                  DateTime.tryParse(
                    raw['projectEndDateTime']?.toString() ?? '',
                  ) ??
                  _detailedSite.projectEndDateTime,

              // Team members — backend key is 'workingEmployees'
              team: (raw['workingEmployees'] as List?) ?? _detailedSite.team,
              stages: Site.processStages(raw['stages']),
              structures:
                  (raw['structures'] as List?)
                      ?.map((s) => SiteStructure.fromJson(s))
                      .toList() ??
                  _detailedSite.structures,
              visits:
                  (raw['siteVisits'] as List?)
                      ?.map((v) => SiteVisit.fromJson(v))
                      .toList() ??
                  _detailedSite.visits,
              meetings: meetingsRaw.map((m) => Meeting.fromJson(m)).toList(),
              reraProjects:
                  (raw['reraProjects'] as List?)
                      ?.map((r) => ReraProject.fromJson(r))
                      .toList() ??
                  [],
            );
          });

          debugPrint("--- FINAL STATE ---");
          debugPrint("CITY: ${_detailedSite.city}");
          debugPrint("ADDR: ${_detailedSite.address}");
          debugPrint("PRIORITY: ${_detailedSite.priority}");
          debugPrint("PLOT: ${_detailedSite.plotArea}");
          debugPrint("BUILT: ${_detailedSite.builtUpArea}");
          debugPrint("-------------------");
        }
      } catch (e) {
        debugPrint("❌ PROJECT FETCH ERROR: $e");
      }

      // SECONDARY: PostSales only used for the postSalesId number
      try {
        final postSaleMap = await PostSalesService.getPostSaleByProjectId(
          idToFetch,
        );
        if (mounted && postSaleMap != null) {
          _rawPostSalesJson = jsonEncode(postSaleMap);
          final int? psId = postSaleMap['id'] as int?;
          if (psId != null) {
            setState(() {
              _detailedSite = _detailedSite.copyWith(postSalesId: psId);
            });
          }
        }
      } catch (e) {
        debugPrint("⚠️ POST-SALE FETCH ERROR: $e");
      }
    } catch (e) {
      debugPrint("GLOBAL FETCH ERROR: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hierarchical Mock Data for 11 Stages
  final List<Map<String, dynamic>> _mockStages = [
    {
      'id': 1,
      'name': 'Concept Design',
      'status': 'COMPLETED',
      'subStages': [
        'Concept Drawings',
        'Massing Study',
        'Basic Floor Plans',
        'Client Approval on Concept',
      ],
    },
    {
      'id': 2,
      'name': 'Final Drawings',
      'status': 'COMPLETED',
      'subStages': [
        'Architectural Layouts',
        'Sections & Elevations',
        'Parking Layout',
        'Area Statement',
        '3D Views',
      ],
    },
    {
      'id': 3,
      'name': 'Documentation Stage',
      'status': 'IN_PROGRESS',
      'subStages': [
        'Final Architectural Drawings',
        '7/12 Extract / Property Card',
        'Latest Demarcation Copy',
        'Power of Attorney',
        'DP Opinion',
      ],
    },
    {
      'id': 4,
      'name': 'Building Permission',
      'status': 'NOT_STARTED',
      'isGrouped': true,
      'subStages': [
        {
          'group': 'Water NOC',
          'items': [
            'Application',
            'Water Line Layout',
            'Tank Capacity Calculation',
            'Fire Water Requirement',
          ],
        },
        {
          'group': 'Drainage NOC',
          'items': [
            'Application',
            'Architectural Drawing',
            'Drainage Layout',
            'Hamipatr',
            'STP Calculation',
            'Google Location Map',
          ],
        },
        {
          'group': 'Garden NOC',
          'items': [
            'Tree Marking Plan',
            'Site Images',
            'Plot Area as per 7/12',
          ],
        },
        {
          'group': 'Fire NOC',
          'items': [
            'Fire Layout Plan',
            'Driveway Width Marking',
            'Entry/Exit Gate Width',
            'Ramp Details',
            'Fire Water Calculations',
          ],
        },
        {
          'group': 'Elevation / Height NOC',
          'items': [
            'Elevation Drawing',
            'Section with Building Height',
            'Crane Height Marking',
            'Monarch Report',
          ],
        },
        {
          'group': 'C & D Waste NOC',
          'items': ['C&D Waste Calculation', 'Disposal Plan'],
        },
      ],
    },
    {
      'id': 5,
      'name': 'Survey Land Records',
      'status': 'NOT_STARTED',
      'subStages': [
        'Demarcation Nakal',
        'Demarcation K-Prat',
        'Tree Survey',
        'DP Abhipray',
      ],
    },
    {
      'id': 6,
      'name': 'Building Permission Scrutiny',
      'status': 'NOT_STARTED',
      'subStages': [
        'Inward Submission at CFC',
        'Online Inward Entry',
        'Site Visits (JE / DE / EE)',
        'Pre-DCR Drawing Run',
        'Drawing Scrutiny',
        'Challan Calculation & Payment',
        'Demand Sheet Entry',
        'Sanction Number Generation',
        'Sanction Copy Collection',
      ],
    },
    {
      'id': 7,
      'name': 'Setback Approval',
      'status': 'NOT_STARTED',
      'subStages': [
        'Application',
        'Sanctioned Plan Copy',
        'Commencement Certificate',
        'Total Station Survey',
      ],
    },
    {
      'id': 8,
      'name': 'Plinth Checking',
      'status': 'NOT_STARTED',
      'subStages': [
        'Application',
        'Structural Stability Certificate',
        'NA Order',
        'Water & Drainage NOCs',
        'Condition Compliance',
      ],
    },
    {
      'id': 9,
      'name': 'TDR FSI Stage',
      'status': 'NOT_STARTED',
      'isGrouped': true,
      'subStages': [
        {
          'group': 'TDR Generation',
          'items': [
            'Search & Title Report',
            'Ownership Documents',
            'Prapatra A & B',
          ],
        },
        {
          'group': 'TDR Utilization',
          'items': [
            'TDR Undertaking',
            'Development Agreement',
            'Sanctioned Plan',
          ],
        },
      ],
    },
    {
      'id': 10,
      'name': 'Construction Execution',
      'status': 'NOT_STARTED',
      'subStages': [
        'Excavation',
        'Foundation Work',
        'Superstructure',
        'Services Installation',
        'Finishing Work',
      ],
    },
    {
      'id': 11,
      'name': 'Completion Process',
      'status': 'NOT_STARTED',
      'subStages': [
        'Application for Completion',
        'Site Inspections (JE / DE / EE)',
        'Structural Stability Certificate',
        'Final NOCs',
        'Solar Certificate',
        'Rainwater Harvesting Certificate',
        'Lift NOC',
        'STP Certificate',
        'Consent to Operate / Establish',
        'Completion Certificate Approval',
        'Final Outward & Certificate Collection',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Premium Integrated Header
        _buildIntegratedHeader(),

        // Tab Bar
        Container(
          height: 50,
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tabs: _tabs
                .map(
                  (tab) => Tab(
                    child: Row(
                      children: [
                        Icon(tab['icon'], size: 16),
                        const SizedBox(width: 8),
                        Text(tab['label']),
                        if (tab['count'] != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              tab['count'].toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        // Tab Content
        Expanded(
          child: IndexedStack(
            index: _tabController.index,
            children: [
              _buildOverviewTab(),
              _buildStagesTab(),
              _buildDocumentsTab(),
              _buildTeamTab(),
              _buildSiteVisitsTab(),
              _buildPlaceholderTab("Structures"),
              _buildMeetingsTab(),
              _buildReraTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntegratedHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(width: 4),
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: _detailedSite.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _detailedSite.logoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          _detailedSite.siteName[0].toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _detailedSite.siteName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metadata Row (Chips on Left, Actions Stack on Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallChip(
                    text: _detailedSite.city.isNotEmpty
                        ? _detailedSite.city.toUpperCase()
                        : "LOCATION",
                    icon: Icons.location_on_rounded,
                    color: Colors.pink.shade50,
                    textColor: Colors.pink.shade700,
                  ),
                  if (_detailedSite.priority != null &&
                      _detailedSite.priority!.isNotEmpty)
                    _SmallChip(
                      text: "${_detailedSite.priority!.toUpperCase()} PRIORITY",
                      icon: null,
                      color: Colors.orange.shade50,
                      textColor: Colors.orange.shade800,
                    ),
                ],
              ),
              // Action Stack: [Edit] -> [Status] -> [Date]
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isManager)
                    _EditSiteButton(
                      onPressed: () => widget.onEditProject(
                      _detailedSite.projectId > 0
                          ? _detailedSite.projectId
                          : _detailedSite.id,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatusBadge(status: _detailedSite.status),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 10,
                        color: AppColors.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _detailedSite.createdAt != null
                            ? DateFormat(
                                'dd MMM yyyy',
                              ).format(_detailedSite.createdAt!)
                            : "—",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Container(
      color: const Color(0xFFF8F9F3), // Match background color from image
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildIdentityCard(),
                const SizedBox(height: 16),
                _buildTimelineCard(),
                const SizedBox(height: 16),
                _buildLocationAreaCard(),
                const SizedBox(height: 16),
                _buildSummaryStatsCard(),
              ],
            ),
    );
  }

  Widget _buildStagesTab() {
    final allStages = _detailedSite.stages;

    // Filter and de-duplicate milestones based on the 11 Standard Phases
    final Map<String, SiteStage> milestoneMap = {};

    for (var standardName in SiteStage.standardPhases) {
      // Find the first stage that matches this standard name
      // We look for stages that are likely roots (null parent) or matches our standard list
      try {
        final match = allStages.firstWhere(
          (s) => s.matchesStandard(standardName),
        );
        milestoneMap[standardName] = match;
      } catch (_) {
        // No match found for this standard phase in current dataset
      }
    }

    // Convert map to sorted list based on standard phases order
    final rootStages = SiteStage.standardPhases
        .where((name) => milestoneMap.containsKey(name))
        .map((name) => milestoneMap[name]!)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStagesSummaryCard(rootStages),
        const SizedBox(height: 24),
        // Stages List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "PROJECT MILESTONES (${rootStages.length})",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.outline,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Stage Tiles
        ...rootStages.asMap().entries.map((entry) {
          final idx = entry.key;
          final stage = entry.value;
          return _StageTile(
            stage: stage,
            index: idx + 1,
            onRefresh: _fetchFullDetails,
          );
        }).toList(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStagesSummaryCard(List<SiteStage> roots) {
    if (roots.isEmpty) return const SizedBox.shrink();

    final total = roots.length;
    final completed = roots.where((s) => s.status == 'COMPLETED').length;
    final inProgress = roots.where((s) => s.status == 'IN_PROGRESS').length;
    final notStarted = roots.where((s) => s.status == 'NOT_STARTED').length;
    final progress = (completed / total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              _StageStatItem(
                label: "Total Phases",
                value: total.toString(),
                color: AppColors.primary,
              ),
              _StageStatItem(
                label: "Completed",
                value: completed.toString(),
                color: AppColors.chipDoneFg,
              ),
              _StageStatItem(
                label: "In Progress",
                value: inProgress.toString(),
                color: AppColors.chipProgressFg,
              ),
              _StageStatItem(
                label: "Not Started",
                value: notStarted.toString(),
                color: AppColors.outline,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Overall: ${(progress * 100).toInt()}%",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryItem(
            label: "Total Stages",
            value: "11",
            color: AppColors.chipPlanningFg,
            onTap: () => _tabController.animateTo(1),
          ),
          _SummaryItem(
            label: "Employees",
            value: _detailedSite.team.length.toString(),
            color: AppColors.chipReviewFg,
            onTap: () => _tabController.animateTo(3),
          ),
          _SummaryItem(
            label: "Site Visits",
            value: _detailedSite.visits.length.toString(),
            color: AppColors.chipProgressFg,
            onTap: () => _tabController.animateTo(4),
          ),
          _SummaryItem(
            label: "Structures",
            value: _detailedSite.structures.length.toString(),
            color: AppColors.chipDoneFg,
            onTap: () => _tabController.animateTo(5),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard() {
    return _buildCard(
      title: "PROJECT IDENTITY",
      icon: Icons.business_center_rounded,
      trailing: IconButton(
        icon: const Icon(Icons.bug_report, color: Colors.blueAccent, size: 18),
        tooltip: "Inspect Raw Data",
        onPressed: () => _showRawDataDialog(),
      ),
      children: [
        _infoRow("Project ID", _detailedSite.projectId.toString(), mono: true),
        _infoRow("Project Code", _detailedSite.projectCode ?? "—", mono: true),
        _infoRow(
          "Permanent ID",
          _detailedSite.permanentProjectId ?? "—",
          mono: true,
        ),
        _infoRow("Project Name", _detailedSite.siteName),
        _infoRow("Status", _detailedSite.status, isStatus: true),
        _infoRow("Priority", _detailedSite.priority ?? "—", isPriority: true),
        _infoRow(
          "Post-Sales ID",
          _detailedSite.postSalesId != null
              ? "#${_detailedSite.postSalesId}"
              : "—",
          mono: true,
        ),
      ],
    );
  }

  void _showRawDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          "Nuclear Data Inspector",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _debugSection(
                  "Final UI Mapping",
                  _detailedSite.toJson().toString(),
                ),
                const Divider(color: Colors.white24),
                _debugSection(
                  "Raw Post-Sales API",
                  _rawPostSalesJson ?? "Not Fetched Yet",
                ),
                const Divider(color: Colors.white24),
                _debugSection(
                  "Raw Project API",
                  _rawProjectJson ?? "Not Fetched Yet",
                ),
                const Divider(color: Colors.white24),
                Text(
                  "Hint: Look for keys like 'city', 'address', or 'plot' in the blocks above.",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.blueAccent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                _debugSection(
                  "Diagnostic Instructions",
                  "If City/Address is missing but exists in the raw JSON below, please take a screenshot and tell me the key name.",
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  Widget _debugSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimelineCard() {
    return _buildCard(
      title: "TIMELINE",
      icon: Icons.timer_outlined,
      children: [
        _timelineItem("CREATED", _detailedSite.createdAt, Colors.grey),
        _timelineItem(
          "STARTED",
          _detailedSite.projectStartDateTime,
          Colors.blue,
        ),
        _timelineItem(
          "EXPECTED END",
          _detailedSite.projectExpectedEndDate,
          Colors.orange,
        ),
        _timelineItem(
          "ACTUAL END",
          _detailedSite.projectEndDateTime,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildLocationAreaCard() {
    return _buildCard(
      title: "LOCATION & AREA",
      icon: Icons.location_on_outlined,
      children: [
        _infoRow("Address", _detailedSite.address),
        _infoRow("City", _detailedSite.city),
        _infoRow("Maps", "Open in Google Maps ↗", isLink: true),
        _infoRow(
          "Plot Area",
          _detailedSite.plotArea != null && _detailedSite.plotArea! > 0
              ? "${_detailedSite.plotArea!.toInt()} sq.ft"
              : "—",
        ),
        _infoRow(
          "Built-Up Area",
          _detailedSite.builtUpArea > 0
              ? "${_detailedSite.builtUpArea.toInt()} sq.ft"
              : "—",
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: AppColors.outline),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.outline,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool mono = false,
    bool isStatus = false,
    bool isPriority = false,
    bool isLink = false,
  }) {
    Widget valueWidget;
    if (isStatus) {
      valueWidget = _StatusBadge(status: value, small: true);
    } else if (isPriority) {
      valueWidget = _PriorityPill(priority: value);
    } else if (isLink) {
      valueWidget = Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      valueWidget = Text(
        value,
        textAlign: TextAlign.right,
        style: mono
            ? TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              )
            : GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: valueWidget),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(String label, DateTime? date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.outline,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                date != null ? DateFormat('dd MMM yyyy').format(date) : "—",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    final docs = _allDocuments;
    if (docs.isEmpty) {
      return Container(
        color: const Color(0xFFF8F9FB),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [_buildDocumentTableHeader(), _buildEmptyDocumentsState()],
        ),
      );
    }

    return Container(
      color: const Color(0xFFF8F9FB),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width < 500
              ? 550
              : MediaQuery.of(context).size.width,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildDocumentTableHeader(),
              ...docs.map(
                (item) => _buildDocumentRow(
                  item['doc'] as StageDocument,
                  item['stageName'] as String,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentRow(StageDocument doc, String stageName) {
    final fileName = doc.fileName ?? "Unnamed File";
    final type = doc.documentType ?? "FILE";
    final dateStr = doc.uploadedAt != null
        ? DateFormat('dd MMM yyyy').format(doc.uploadedAt!)
        : "--";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
          left: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
          right: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // DOCUMENT
          Expanded(
            flex: 33,
            child: Row(
              children: [
                Icon(
                  _getFileIcon(type),
                  size: 16,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // STAGE
          Expanded(
            flex: 22,
            child: Text(
              stageName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          // TYPE
          Expanded(
            flex: 15,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          // STATUS
          Expanded(
            flex: 15,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "ACTIVE",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          // ACTION
          Expanded(
            flex: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _viewDocument(doc),
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? type) {
    if (type == null) return Icons.insert_drive_file_outlined;
    final t = type.toLowerCase();
    if (t.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (t.contains('image') || t.contains('jpg') || t.contains('png'))
      return Icons.image_outlined;
    if (t.contains('doc')) return Icons.description_outlined;
    if (t.contains('xls')) return Icons.table_chart_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Future<void> _viewDocument(StageDocument doc) async {
    if (doc.filePath == null || doc.filePath!.isEmpty) return;
    final url = Uri.parse(doc.filePath!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open document")),
        );
      }
    }
  }

  Widget _buildDocumentTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          _headerText("DOCUMENT", flex: 3.3, align: TextAlign.left),
          _headerText("STAGE", flex: 2.2, align: TextAlign.center),
          _headerText("TYPE", flex: 1.5, align: TextAlign.center),
          _headerText("STATUS", flex: 1.8, align: TextAlign.center),
          _headerText("ACTION", flex: 1.2, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _headerText(
    String label, {
    double flex = 1.0,
    TextAlign align = TextAlign.left,
  }) {
    int flexInt = (flex * 10).toInt();
    return Expanded(
      flex: flexInt,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppColors.outline,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyDocumentsState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
          left: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
          right: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No documents uploaded for now",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "All documents added during construction stages will appear here for easy access.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.outline,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => _tabController.animateTo(1),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Go to Stages",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTab() {
    return Container(
      color: const Color(0xFFF8F9FB),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Employees",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddEmployeeDialog,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  "Add Employee",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF705C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_detailedSite.team.isEmpty)
            _buildEmptyTeamState()
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _detailedSite.team
                  .map((emp) => _buildEmployeeCard(emp))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyTeamState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: AppColors.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              "No employees assigned to this site",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(dynamic emp) {
    final String fName = emp['firstName']?.toString() ?? '';
    final String lName = emp['lastName']?.toString() ?? '';
    final String constructedName = '$fName $lName'.trim();
    final String name =
        (emp['fullName'] ??
                emp['name'] ??
                (constructedName.isNotEmpty
                    ? constructedName
                    : 'Unknown Employee'))
            .toString();
    final String role = (emp['role'] ?? emp['designation'] ?? 'Employee')
        .toString()
        .replaceAll('_', ' ');
    final String initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join('');

    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.7),
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  role,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog() async {
    // Show loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Fetch registered employees
    final List<dynamic> allEmployees = await EmployeeService.getAllEmployees();

    // Close loading
    if (mounted) Navigator.pop(context);

    // Show selection dialog
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Team Member",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Select a registered employee to add to this site",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: allEmployees.isEmpty
                    ? Center(
                        child: Text(
                          "No registered employees found",
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                      )
                    : ListView.separated(
                        itemCount: allEmployees.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final emp = allEmployees[index];
                          final String fName =
                              emp['firstName']?.toString() ?? '';
                          final String lName =
                              emp['lastName']?.toString() ?? '';
                          final String constructedName = '$fName $lName'.trim();
                          final String name =
                              (emp['fullName'] ??
                                      emp['name'] ??
                                      (constructedName.isNotEmpty
                                          ? constructedName
                                          : 'Unknown'))
                                  .toString();
                          final String role =
                              (emp['role'] ?? emp['designation'] ?? 'Employee')
                                  .toString()
                                  .replaceAll('_', ' ');
                          final bool alreadyAdded = _detailedSite.team.any(
                            (e) => e['id'] == emp['id'],
                          );

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(role.replaceAll('_', ' ')),
                            trailing: IconButton(
                              icon: Icon(
                                alreadyAdded
                                    ? Icons.check_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: alreadyAdded
                                    ? AppColors.chipDoneFg
                                    : AppColors.primary,
                              ),
                              onPressed: alreadyAdded
                                  ? null
                                  : () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );

                                      // We need to send ALL user IDs (existing + new) based on the web app's `userIds` array logic.
                                      final existingIds = _detailedSite.team
                                          .map((e) => e['id'] as int)
                                          .toList();
                                      final newIds = [
                                        ...existingIds,
                                        emp['id'] as int,
                                      ];

                                      int idToFetch =
                                          _detailedSite.projectId > 0
                                          ? _detailedSite.projectId
                                          : _detailedSite.id;
                                      final success =
                                          await ProjectService.addUsersToProject(
                                            idToFetch,
                                            newIds,
                                          );

                                      if (mounted)
                                        Navigator.pop(
                                          context,
                                        ); // Close loading indicator

                                      if (success) {
                                        if (mounted)
                                          Navigator.pop(
                                            context,
                                          ); // Close dialog
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "$name added to site team successfully",
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: AppColors.primary,
                                          ),
                                        );
                                        _fetchFullDetails(); // Refresh from backend
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Failed to add team member",
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSiteVisitsTab() {
    return Container(
      color: const Color(0xFFF8F9FB),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Site Visits",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddSiteVisitDialog,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  "Add Site Visit",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF705C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_detailedSite.visits.isEmpty)
            _buildEmptySiteVisitsState()
          else
            ..._detailedSite.visits.asMap().entries.map((entry) {
              return _buildVisitCard(entry.value, entry.key + 1);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptySiteVisitsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 48,
              color: AppColors.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              "No site visits logged yet",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(SiteVisit visit, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Visit #$index",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    DateFormat('d MMM yyyy, h:mm a').format(visit.visitDate),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                        if (_isManager)
                    GestureDetector(
                      onTap: () => _showEditSiteVisitDialog(visit),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Edit",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVisitDetailRow("Title", visit.title),
          const SizedBox(height: 8),
          _buildVisitDetailRow("Description", visit.description),
          if (visit.photos.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              "Photos (${visit.photos.length})",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visit.photos.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (c, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    visit.photos[i].imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey.shade200,
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.broken_image, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (visit.documents.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: visit.documents
                  .map(
                    (doc) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE1BEE7)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.description,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            doc.documentName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          _buildVisitDetailRow("Location Note", visit.locationNote ?? "N/A"),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAttachmentBadge(
                Icons.camera_alt_rounded,
                "${visit.photos.length} Photo",
                const Color(0xFFF7F2E9),
              ),
              const SizedBox(width: 12),
              _buildAttachmentBadge(
                Icons.description_rounded,
                "${visit.documents.length} Document",
                const Color(0xFFEEF2FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentBadge(IconData icon, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.onSurface.withOpacity(0.7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSiteVisitDialog(SiteVisit visit) {
    int activeTabIndex = 0;
    final titleController = TextEditingController(text: visit.title);
    final descController = TextEditingController(text: visit.description);
    final noteController = TextEditingController(text: visit.locationNote);
    final dateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy HH:mm').format(visit.visitDate),
    );

    final ImagePicker _picker = ImagePicker();
    List<XFile> pickedPhotos = [];
    List<XFile> pickedDocs = [];
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget _buildLabel(String text) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.outline.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }

            Widget _buildTexfield(
              TextEditingController controller, {
              int lines = 1,
              IconData? icon,
            }) {
              return TextField(
                controller: controller,
                maxLines: lines,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  suffixIcon: icon != null
                      ? Icon(icon, size: 16, color: AppColors.onSurface)
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: const Color(0xFFFBFBF9),
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 500,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Edit Site Visit",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tabs
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.outlineVariant.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setDialogState(
                                      () => activeTabIndex = 0,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: activeTabIndex == 0
                                                ? const Color(0xFF705C00)
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.description,
                                            size: 14,
                                            color: activeTabIndex == 0
                                                ? const Color(0xFF705C00)
                                                : AppColors.outline.withOpacity(
                                                    0.4,
                                                  ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Info",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              color: activeTabIndex == 0
                                                  ? const Color(0xFF705C00)
                                                  : AppColors.outline
                                                        .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setDialogState(
                                      () => activeTabIndex = 1,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: activeTabIndex == 1
                                                ? const Color(0xFF705C00)
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.attach_file,
                                            size: 14,
                                            color: activeTabIndex == 1
                                                ? const Color(0xFF705C00)
                                                : AppColors.outline,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Documents",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              color: activeTabIndex == 1
                                                  ? const Color(0xFF705C00)
                                                  : AppColors.outline
                                                        .withOpacity(0.6),
                                            ),
                                          ),
                                          if (visit.photos.length +
                                                  visit.documents.length +
                                                  pickedPhotos.length +
                                                  pickedDocs.length >
                                              0) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFC107),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                (visit.photos.length +
                                                        visit.documents.length +
                                                        pickedPhotos.length +
                                                        pickedDocs.length)
                                                    .toString(),
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.black,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Body
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(24),
                            height: 400,
                            child: activeTabIndex == 0
                                ? ListView(
                                    children: [
                                      _buildLabel("VISIT TITLE"),
                                      _buildTexfield(titleController),
                                      const SizedBox(height: 16),
                                      _buildLabel("DESCRIPTION"),
                                      _buildTexfield(descController, lines: 4),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildLabel("LOCATION NOTE"),
                                                _buildTexfield(noteController),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildLabel(
                                                  "VISIT DATE & TIME",
                                                ),
                                                _buildTexfield(
                                                  dateController,
                                                  icon: Icons
                                                      .calendar_today_outlined,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : ListView(
                                    children: [
                                      _buildLabel("PHOTOS"),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFBFBF9),
                                          border: Border.all(
                                            color: AppColors.outlineVariant
                                                .withOpacity(0.5),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                // Existing photos from server
                                                ...visit.photos.map(
                                                  (p) => Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        child: Image.network(
                                                          p.imageUrl,
                                                          height: 70,
                                                          width: 70,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                c,
                                                                e,
                                                                s,
                                                              ) => Container(
                                                                height: 70,
                                                                width: 70,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                child:
                                                                    const Icon(
                                                                      Icons
                                                                          .image,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 2,
                                                        right: 2,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            // Immediate delete or track for deletion
                                                            final ok =
                                                                await SiteVisitService.deletePhoto(
                                                                  visit.id,
                                                                  p.id,
                                                                );
                                                            if (ok)
                                                              _fetchFullDetails();
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  2,
                                                                ),
                                                            decoration:
                                                                const BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                            child: const Icon(
                                                              Icons.close,
                                                              size: 10,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Newly picked photos
                                                ...pickedPhotos.map(
                                                  (f) => Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        child: kIsWeb
                                                            ? Image.network(
                                                                f.path,
                                                                height: 70,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Image.file(
                                                                File(f.path),
                                                                height: 70,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                      Positioned(
                                                        top: 2,
                                                        right: 2,
                                                        child: InkWell(
                                                          onTap: () =>
                                                              setDialogState(
                                                                () =>
                                                                    pickedPhotos
                                                                        .remove(
                                                                          f,
                                                                        ),
                                                              ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  2,
                                                                ),
                                                            decoration:
                                                                const BoxDecoration(
                                                                  color: Colors
                                                                      .black54,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                            child: const Icon(
                                                              Icons.close,
                                                              size: 10,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            InkWell(
                                              onTap: () async {
                                                final images = await _picker
                                                    .pickMultiImage();
                                                if (images.isNotEmpty) {
                                                  setDialogState(
                                                    () => pickedPhotos.addAll(
                                                      images,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: AppColors
                                                        .outlineVariant
                                                        .withOpacity(0.5),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.add,
                                                      size: 14,
                                                      color: AppColors.outline,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Add Photos",
                                                      style:
                                                          GoogleFonts.plusJakartaSans(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .outline,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      _buildLabel("DOCUMENTS"),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFBFBF9),
                                          border: Border.all(
                                            color: AppColors.outlineVariant
                                                .withOpacity(0.5),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Existing documents
                                            ...visit.documents.map(
                                              (d) => Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: AppColors
                                                        .outlineVariant
                                                        .withOpacity(0.4),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.description,
                                                      size: 16,
                                                      color: Color(0xFFD3C1F4),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        d.documentName,
                                                        style:
                                                            GoogleFonts.plusJakartaSans(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .onSurface,
                                                            ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        final ok =
                                                            await SiteVisitService.deleteDocument(
                                                              visit.id,
                                                              d.id,
                                                            );
                                                        if (ok)
                                                          _fetchFullDetails();
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          size: 10,
                                                          color:
                                                              AppColors.outline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Newly picked "documents" (as images for now since no file_picker)
                                            ...pickedDocs.map(
                                              (f) => Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: AppColors
                                                        .outlineVariant
                                                        .withOpacity(0.4),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.upload_file,
                                                      size: 16,
                                                      color: Colors.blue,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        f.name,
                                                        style:
                                                            GoogleFonts.plusJakartaSans(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .onSurface,
                                                            ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () =>
                                                          setDialogState(
                                                            () => pickedDocs
                                                                .remove(f),
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          size: 10,
                                                          color:
                                                              AppColors.outline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () async {
                                                final file = await _picker
                                                    .pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    );
                                                if (file != null)
                                                  setDialogState(
                                                    () => pickedDocs.add(file),
                                                  );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: AppColors
                                                        .outlineVariant
                                                        .withOpacity(0.5),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.add,
                                                      size: 14,
                                                      color: AppColors.outline,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Add Documents",
                                                      style:
                                                          GoogleFonts.plusJakartaSans(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .outline,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),

                          // Footer
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.outlineVariant.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: AppColors.outlineVariant
                                          .withOpacity(0.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          setDialogState(() => isSaving = true);

                                          // 1. Update Info
                                          final infoOk =
                                              await SiteVisitService.updateSiteVisit(
                                                id: visit.id,
                                                title: titleController.text,
                                                description:
                                                    descController.text,
                                                locationNote:
                                                    noteController.text,
                                              );

                                          if (infoOk) {
                                            // 2. Upload Photos
                                            if (pickedPhotos.isNotEmpty) {
                                              await SiteVisitService.addVisitPhotos(
                                                visit.id,
                                                pickedPhotos
                                                    .map((e) => e.path)
                                                    .toList(),
                                              );
                                            }
                                            // 3. Upload Documents
                                            if (pickedDocs.isNotEmpty) {
                                              await SiteVisitService.addVisitDocuments(
                                                visit.id,
                                                pickedDocs
                                                    .map(
                                                      (e) => {
                                                        'path': e.path,
                                                        'name': e.name,
                                                      },
                                                    )
                                                    .toList(),
                                              );
                                            }

                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Site visit updated successfully",
                                                ),
                                              ),
                                            );
                                            _fetchFullDetails();
                                          } else {
                                            setDialogState(
                                              () => isSaving = false,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Failed to update site visit",
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8C6D23),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          height: 14,
                                          width: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          "Update Visit",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSaving)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white60,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF8C6D23),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddSiteVisitDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    List<fp.PlatformFile> pickedPhotos = [];
    List<fp.PlatformFile> pickedDocs = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Site Visit",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text("Visit Title", style: _modalLabelStyle),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: _modalInputDecoration(
                          "Foundation inspection",
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text("Description", style: _modalLabelStyle),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descController,
                        maxLines: 4,
                        decoration: _modalInputDecoration(
                          "Enter visit description...",
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Location Note", style: _modalLabelStyle),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: noteController,
                                  decoration: _modalInputDecoration(
                                    "Basement / Terrace",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Visit Date", style: _modalLabelStyle),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                          selectedDate,
                                        ),
                                      );
                                      if (time != null) {
                                        setDialogState(() {
                                          selectedDate = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            time.hour,
                                            time.minute,
                                          );
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.outlineVariant,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            DateFormat(
                                              'dd-MM-yyyy HH:mm',
                                            ).format(selectedDate),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 14,
                                          color: AppColors.outline,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("Photos", style: _modalLabelStyle),
                      const SizedBox(height: 8),
                      _buildFilePickerButton(
                        label: "Choose Photos",
                        count: pickedPhotos.length,
                        onTap: () async {
                          final result = await fp.FilePicker.pickFiles(
                            type: fp.FileType.image,
                            allowMultiple: true,
                          );
                          if (result != null) {
                            setDialogState(() {
                              pickedPhotos = result.files;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text("Documents", style: _modalLabelStyle),
                      const SizedBox(height: 8),
                      _buildFilePickerButton(
                        label: "Choose Documents",
                        count: pickedDocs.length,
                        onTap: () async {
                          final result = await fp.FilePicker.pickFiles(
                            type: fp.FileType.custom,
                            allowedExtensions: [
                              'pdf',
                              'doc',
                              'docx',
                              'xls',
                              'xlsx',
                            ],
                            allowMultiple: true,
                          );
                          if (result != null) {
                            setDialogState(() {
                              pickedDocs = result.files;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Title is required"),
                                  ),
                                );
                                return;
                              }

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              final success =
                                  await SiteVisitService.createSiteVisit(
                                    projectId: _detailedSite.projectId > 0
                                        ? _detailedSite.projectId
                                        : _detailedSite.id,
                                    title: titleController.text.trim(),
                                    description: descController.text.trim(),
                                    locationNote: noteController.text.trim(),
                                    visitDateTime: selectedDate,
                                    photoPaths: pickedPhotos
                                        .map((f) => f.path!)
                                        .where((p) => p != null)
                                        .toList(),
                                    documentPaths: pickedDocs
                                        .map((f) => f.path!)
                                        .where((p) => p != null)
                                        .toList(),
                                  );

                              if (mounted)
                                Navigator.pop(
                                  context,
                                ); // Close loading indicator

                              if (success) {
                                if (mounted)
                                  Navigator.pop(context); // Close add dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "Site visit logged successfully",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                                _fetchFullDetails(); // Refresh to pull data directly from backend
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to log site visit"),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF705C00),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Create Visit",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  TextStyle get _modalLabelStyle => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface.withOpacity(0.8),
  );

  InputDecoration _modalInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      color: AppColors.outline.withOpacity(0.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    ),
  );

  Widget _buildFilePickerButton({
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.outline.withOpacity(0.2)),
              ),
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                count == 0 ? "No file chosen" : "$count files selected",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: count == 0
                      ? AppColors.onSurfaceVariant
                      : AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.check_circle, size: 16, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingsTab() {
    return Container(
      color: const Color(0xFFF8F9FB),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Meetings",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${_detailedSite.meetings.length}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showScheduleMeetingDialog,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  "Schedule Meeting",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF705C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMeetingSummaryCards(),
          const SizedBox(height: 24),
          _buildMeetingFilters(),
          const SizedBox(height: 20),
          if (_detailedSite.meetings.isEmpty)
            _buildEmptyMeetingsState()
          else
            ..._detailedSite.meetings
                .where((m) {
                  final statusMatch =
                      _selectedStatusFilter == 'All' ||
                      m.status.toUpperCase() ==
                          _selectedStatusFilter.toUpperCase();
                  final typeMatch =
                      _selectedTypeFilter == 'All' ||
                      m.type.toUpperCase() == _selectedTypeFilter.toUpperCase();
                  return statusMatch && typeMatch;
                })
                .map((m) => _buildMeetingCard(m))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildMeetingSummaryCards() {
    final scheduled = _detailedSite.meetings
        .where((m) => m.status == "SCHEDULED")
        .length;
    final ongoing = _detailedSite.meetings
        .where((m) => m.status == "ONGOING")
        .length;
    final completed = _detailedSite.meetings
        .where((m) => m.status == "COMPLETED")
        .length;
    final cancelled = _detailedSite.meetings
        .where((m) => m.status == "CANCELLED")
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryCard(
            "Total",
            _detailedSite.meetings.length,
            Colors.blue,
          ),
          _buildSummaryCard("Scheduled", scheduled, Colors.indigo),
          _buildSummaryCard("Ongoing", ongoing, Colors.orange),
          _buildSummaryCard("Completed", completed, Colors.green),
          _buildSummaryCard("Cancelled", cancelled, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$count",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _selectedStatusFilter = 'All';
  String _selectedTypeFilter = 'All';

  Widget _buildMeetingFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterRow(
            "STATUS:",
            ['All', 'Scheduled', 'Ongoing', 'Completed', 'Cancelled'],
            _selectedStatusFilter,
            (val) => setState(() => _selectedStatusFilter = val),
          ),
          const SizedBox(height: 12),
          _buildFilterRow(
            "TYPE:",
            ['All', 'CALL', 'ZOOM', 'GOOGLE MEET', 'FACE TO FACE', 'TEAMS'],
            _selectedTypeFilter,
            (val) => setState(() => _selectedTypeFilter = val),
            hasIcons: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(
    String label,
    List<String> options,
    String selected,
    Function(String) onSelect, {
    bool hasIcons = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.outline,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: options.map((opt) {
                final isSelected = selected == opt;
                return GestureDetector(
                  onTap: () => onSelect(opt),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF705C00)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (hasIcons && opt != 'All') ...[
                          Icon(
                            _getMeetingTypeIcon(opt),
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : AppColors.outline,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          opt,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getMeetingTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'CALL':
        return Icons.phone_rounded;
      case 'ZOOM':
        return Icons.videocam_rounded;
      case 'GOOGLE MEET':
        return Icons.video_camera_front_rounded;
      case 'FACE TO FACE':
        return Icons.back_hand_rounded;
      case 'TEAMS':
        return Icons.groups_rounded;
      default:
        return Icons.handshake_outlined;
    }
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _getStatusColor(meeting.status),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F2E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.handshake_rounded,
                    size: 24,
                    color: Color(0xFF705C00),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meeting.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(meeting.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meeting.agenda,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.outline,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMeetingTime(
                              Icons.schedule_rounded,
                              meeting.scheduledAt,
                            ),
                            if (meeting.startedAt != null) ...[
                              const SizedBox(width: 8),
                              _buildMeetingTime(
                                Icons.play_circle_outline_rounded,
                                meeting.startedAt!,
                              ),
                            ],
                            const SizedBox(width: 8),
                            _buildTypeChip(meeting.type),
                            if (meeting.mom != null &&
                                meeting.mom!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              _buildMomBadge(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    TextButton(
                      onPressed: () => _showMeetingDetailDialog(meeting),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ),
                      child: Text(
                        "View",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          _handleDeleteMeeting(meeting.id, meeting.title),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        backgroundColor: Colors.red.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteMeeting(int id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Meeting",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Text(
          "Are you sure you want to delete '$title'? This cannot be undone.",
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.plusJakartaSans(color: AppColors.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              final success = await MeetingService.deleteMeeting(id);
              if (mounted) Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Meeting deleted successfully")),
                );
                _fetchFullDetails();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to delete meeting"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              "Delete",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMeetingDetailDialog(Meeting meeting) {
    showDialog(
      context: context,
      builder: (context) {
        final statusCfg = _getStatusColor(meeting.status);
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Meeting Details",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow("Title", meeting.title),
                  _buildDetailRow("Status", meeting.status.toUpperCase()),
                  _buildDetailRow("Type", meeting.type.replaceAll('_', ' ')),
                  _buildDetailRow(
                    "Scheduled",
                    DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(meeting.scheduledAt),
                  ),
                  if (meeting.meetingLink != null &&
                      meeting.meetingLink!.isNotEmpty)
                    _buildDetailRow("Link", meeting.meetingLink!, isLink: true),
                  const SizedBox(height: 16),
                  Text(
                    "Agenda",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meeting.agenda,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.outline,
                      fontSize: 13,
                    ),
                  ),
                  if (meeting.mom != null && meeting.mom!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      "Minutes of Meeting (MOM)",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        meeting.mom!,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLink ? Colors.blue : AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMeetingTypeIcon(type),
            size: 12,
            color: const Color(0xFF705C00),
          ),
          const SizedBox(width: 6),
          Text(
            type,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF705C00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingTime(IconData icon, DateTime time) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.outline),
        const SizedBox(width: 4),
        Text(
          DateFormat('d MMM yyyy, h:mm a').format(time),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMomBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9DB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.description_outlined,
            size: 12,
            color: Color(0xFF705C00),
          ),
          const SizedBox(width: 4),
          Text(
            "MOM",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF705C00),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'ONGOING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyMeetingsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 56,
              color: AppColors.outline.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No meetings scheduled yet",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleMeetingDialog() {
    final titleController = TextEditingController();
    final agendaController = TextEditingController();
    final linkController = TextEditingController();
    final momController = TextEditingController();
    String selectedType = 'Face to Face';
    String selectedStatus = 'Scheduled';
    DateTime scheduledAt = DateTime.now();
    DateTime? startedAt;
    DateTime? endedAt;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF705C00), Color(0xFF2E3228)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.handshake_rounded,
                                color: Color(0xFFFCDE6C),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Schedule New Meeting",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _detailedSite.siteName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic Info Section
                            _buildModalSectionHeader(
                              "BASIC INFO",
                              Icons.description_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildModalLabel("TITLE", required: true),
                            const SizedBox(height: 8),
                            TextField(
                              controller: titleController,
                              decoration: _modalInputDecoration(
                                "e.g. Site Progress Review Q2",
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildModalLabel("AGENDA"),
                            const SizedBox(height: 8),
                            TextField(
                              controller: agendaController,
                              maxLines: 2,
                              decoration: _modalInputDecoration(
                                "What will be discussed...",
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildModalLabel("MEETING TYPE"),
                                      const SizedBox(height: 8),
                                      _buildModalDropdown(
                                        [
                                          'Face to Face',
                                          'Call',
                                          'Zoom',
                                          'Google Meet',
                                          'Teams',
                                        ],
                                        selectedType,
                                        (val) => setDialogState(
                                          () => selectedType = val!,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildModalLabel("STATUS"),
                                      const SizedBox(height: 8),
                                      _buildModalDropdown(
                                        [
                                          'Scheduled',
                                          'Ongoing',
                                          'Completed',
                                          'Cancelled',
                                        ],
                                        selectedStatus,
                                        (val) => setDialogState(
                                          () => selectedStatus = val!,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                            // Schedule & Link Section
                            _buildModalSectionHeader(
                              "SCHEDULE & LINK",
                              Icons.calendar_today_outlined,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildModalLabel(
                                        "SCHEDULED AT",
                                        required: true,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildDateTimePicker(
                                        scheduledAt,
                                        (dt) => setDialogState(
                                          () => scheduledAt = dt,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildModalLabel("MEETING LINK"),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: linkController,
                                        decoration: _modalInputDecoration(
                                          "https://meet.google.com/...",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildModalLabel("STARTED AT"),
                                      const SizedBox(height: 8),
                                      _buildDateTimePicker(
                                        startedAt ?? DateTime.now(),
                                        (dt) => setDialogState(
                                          () => startedAt = dt,
                                        ),
                                        isNull: startedAt == null,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildModalLabel("ENDED AT"),
                                      const SizedBox(height: 8),
                                      _buildDateTimePicker(
                                        endedAt ?? DateTime.now(),
                                        (dt) =>
                                            setDialogState(() => endedAt = dt),
                                        isNull: endedAt == null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                            // MOM Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildModalSectionHeader(
                                  "MINUTES OF MEETING (MOM)",
                                  Icons.history_edu_outlined,
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      _showTemplatePicker(context, (text) {
                                        momController.text = text;
                                      }),
                                  icon: const Icon(
                                    Icons.bolt_rounded,
                                    size: 16,
                                    color: Color(0xFF705C00),
                                  ),
                                  label: Text(
                                    "Use Template",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF705C00),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    backgroundColor: const Color(0xFFFFF9DB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(
                                        color: Color(0xFF705C00),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: momController,
                              maxLines: 8,
                              decoration: _modalInputDecoration(
                                "Type minutes of meeting here, or click '⚡ Use Template' above to auto-fill a structured format...",
                              ),
                            ),

                            const SizedBox(height: 32),
                            // Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (titleController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Title is required"),
                                        ),
                                      );
                                      return;
                                    }

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );

                                    // Map UI concepts to Backend Enums
                                    final String mappedType = selectedType
                                        .toUpperCase()
                                        .replaceAll(' ', '_');
                                    final String mappedStatus = selectedStatus
                                        .toUpperCase();

                                    final meetingData = {
                                      "title": titleController.text.trim(),
                                      if (agendaController.text.isNotEmpty)
                                        "agenda": agendaController.text.trim(),
                                      "meetingType": mappedType,
                                      "status": mappedStatus,
                                      "scheduledAt": scheduledAt
                                          .toIso8601String(),
                                      if (startedAt != null)
                                        "startedAt": startedAt!
                                            .toIso8601String(),
                                      if (endedAt != null)
                                        "endedAt": endedAt!.toIso8601String(),
                                      if (linkController.text.isNotEmpty)
                                        "meetingLink": linkController.text
                                            .trim(),
                                      if (momController.text.isNotEmpty)
                                        "mom": momController.text.trim(),
                                    };

                                    int idToFetch = _detailedSite.projectId > 0
                                        ? _detailedSite.projectId
                                        : _detailedSite.id;
                                    final success =
                                        await MeetingService.createMeeting(
                                          projectId: idToFetch,
                                          createdBy:
                                              1, // Fallback administrator ID
                                          meetingData: meetingData,
                                        );

                                    if (mounted)
                                      Navigator.pop(
                                        context,
                                      ); // Close loading spinner

                                    if (success) {
                                      if (mounted)
                                        Navigator.pop(context); // Close modal
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Meeting scheduled successfully",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                      _fetchFullDetails(); // Reload data from backend
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Failed to schedule meeting",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF705C00),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Save Meeting",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.outline,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildModalLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface.withOpacity(0.8),
          ),
        ),
        if (required)
          Text(
            " *",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildModalDropdown(
    List<String> items,
    String selected,
    Function(String?) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBEC).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
    DateTime dt,
    Function(DateTime) onSelect, {
    bool isNull = false,
  }) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: dt,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (d != null) {
          final t = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(dt),
          );
          if (t != null) {
            onSelect(DateTime(d.year, d.month, d.day, t.hour, t.minute));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBEC).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isNull
                  ? "dd-mm-yyyy --:--"
                  : DateFormat('dd-MM-yyyy HH:mm').format(dt),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isNull
                    ? AppColors.outline.withOpacity(0.5)
                    : AppColors.onSurface,
              ),
            ),
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: AppColors.outline.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplatePicker(BuildContext context, Function(String) onPick) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "MOM Templates",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildTemplateOption(
                      "Standard MOM",
                      Icons.assignment_outlined,
                      "Basic minutes with agenda & decisions",
                      _getStandardMomTemplate(),
                      onPick,
                    ),
                    _buildTemplateOption(
                      "Site Review MOM",
                      Icons.construction_outlined,
                      "For on-site progress review meetings",
                      _getSiteReviewMomTemplate(),
                      onPick,
                    ),
                    _buildTemplateOption(
                      "Client Call Summary",
                      Icons.phone_in_talk_outlined,
                      "Quick summary for client calls",
                      _getClientCallTemplate(),
                      onPick,
                    ),
                    _buildTemplateOption(
                      "Design Review MOM",
                      Icons.design_services_outlined,
                      "For design presentation sessions",
                      _getDesignReviewTemplate(),
                      onPick,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplateOption(
    String title,
    IconData icon,
    String subtitle,
    String template,
    Function(String) onPick,
  ) {
    return GestureDetector(
      onTap: () {
        onPick(template);
        Navigator.pop(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF705C00), size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.outline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getStandardMomTemplate() =>
      '''Standard MOM MINUTES OF MEETING
==================
Project      : ${_detailedSite.siteName}
Client       : [Client Name]
Meeting      : [Meeting Title]
Type         : FACE_TO_FACE
Scheduled    : ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}


AGENDA
------
[Agenda]

DISCUSSION POINTS
-----------------
1. 
2. 
3. 

DECISIONS TAKEN
---------------
1. 
2. 

ACTION ITEMS
------------
Task                  | Assigned To   | Due Date
----------------------|---------------|----------
                      |               |

NEXT MEETING
------------
Date   : 
Agenda : 

Prepared by : _______________
Date        : ${DateFormat('dd MMM yyyy').format(DateTime.now())}''';

  String _getSiteReviewMomTemplate() =>
      '''SITE REVIEW — MINUTES OF MEETING
==================================
Project      : ${_detailedSite.siteName}
Client       : [Client Name]
Review Type  : FACE_TO_FACE
Date & Time  : ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}


AGENDA
------
[Agenda]

SITE OBSERVATIONS
-----------------
1. 
2. 
3. 

WORK IN PROGRESS
----------------
Completed since last visit : 
Currently ongoing           : 
Pending / Blocked           : 

ISSUES & CONCERNS
-----------------
Issue      : 
Action     : 
Responsible: 

APPROVALS / SIGN-OFFS
---------------------
- 

NEXT SITE VISIT
---------------
Date              : 
Inspection Points : 

Prepared by : _______________
Date        : ${DateFormat('dd MMM yyyy').format(DateTime.now())}''';

  String _getClientCallTemplate() =>
      '''CLIENT CALL SUMMARY
====================
Project      : ${_detailedSite.siteName}
Client       : [Client Name]
Call Type    : [Call Type]
Date & Time  : ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}


PARTICIPANTS
------------
Client side : 
Our team    : 

AGENDA DISCUSSED
----------------
[Agenda]

KEY POINTS RAISED BY CLIENT
----------------------------
1. 
2. 

OUR COMMITMENTS
---------------
1. 
2. 

FOLLOW-UP ITEMS
---------------
1. Task:          Due:          Owner:
2. Task:          Due:          Owner:

Notes: 

Prepared by : _______________
Date        : ${DateFormat('dd MMM yyyy').format(DateTime.now())}''';

  String _getDesignReviewTemplate() =>
      '''DESIGN REVIEW — MINUTES OF MEETING
=====================================
Project      : ${_detailedSite.siteName}
Client       : [Client Name]
Review Type  : FACE_TO_FACE
Date & Time  : ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}


AGENDA
------
[Agenda]

DESIGNS PRESENTED
-----------------
1. 
2. 

CLIENT FEEDBACK
---------------
✅ Approved          : 
🔄 Revision Required : 
❌ Rejected          : 

REVISION INSTRUCTIONS
---------------------
1. 
2. 

TIMELINE AGREED
---------------
Revision Deadline  : 
Next Presentation  : 

REMARKS
-------


Prepared by : _______________
Date        : ${DateFormat('dd MMM yyyy').format(DateTime.now())}''';

  Widget _buildReraTab() {
    return Container(
      color: const Color(0xFFF8F9FB),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "RERA Projects",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9DB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _detailedSite.reraProjects.length.toString(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF705C00),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddReraDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add RERA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF705C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildReraSummaryCards(),
          const SizedBox(height: 24),
          if (_detailedSite.reraProjects.isEmpty)
            _buildEmptyReraState()
          else
            ..._detailedSite.reraProjects
                .map((r) => _buildReraCard(r))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildReraSummaryCards() {
    final active = _detailedSite.reraProjects
        .where((r) => r.status == "ACTIVE")
        .length;
    final inactive = _detailedSite.reraProjects
        .where((r) => r.status == "INACTIVE")
        .length;
    final totalCerts = _detailedSite.reraProjects.fold<int>(
      0,
      (sum, r) => sum + r.certificates.length,
    );
    final totalUpdates = _detailedSite.reraProjects.fold<int>(
      0,
      (sum, r) => sum + r.quarterUpdates.length,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryCard(
            "TOTAL",
            _detailedSite.reraProjects.length,
            Colors.blue,
          ),
          _buildSummaryCard("ACTIVE", active, Colors.green),
          _buildSummaryCard("INACTIVE", inactive, Colors.orange),
          _buildSummaryCard("CERTIFICATES", totalCerts, Colors.teal),
          _buildSummaryCard("QUARTER UPDATES", totalUpdates, Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildEmptyReraState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: AppColors.outline.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No RERA registrations found",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReraCard(ReraProject rera) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: rera.status.toUpperCase() == 'ACTIVE'
                    ? Colors.green
                    : Colors.grey.shade400,
                width: 4,
              ),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: Row(
                children: [
                  Text(
                    "#${rera.id}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rera.reraNumber,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReraSmallInfo(
                                Icons.assignment_outlined,
                                "Reg: ${DateFormat('d MMM yyyy').format(rera.registrationDate)}",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildReraSmallInfo(
                                Icons.hourglass_bottom_rounded,
                                "End: ${DateFormat('d MMM yyyy').format(rera.expectedCompletionDate)}",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildCompactReraStatus(rera.status),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _handleDeleteRera(rera.id, rera.reraNumber),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReraSectionTitle(
                        "REGISTRATION INFO",
                        Icons.auto_awesome_rounded,
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                        mainAxisSpacing: 20,
                        children: [
                          _buildReraDetailItem("RERA NUMBER", rera.reraNumber),
                          _buildReraDetailItem(
                            "REGISTRATION DATE",
                            DateFormat(
                              'd MMM yyyy',
                            ).format(rera.registrationDate),
                          ),
                          _buildReraDetailItem(
                            "EXPECTED COMPLETION",
                            DateFormat(
                              'd MMM yyyy',
                            ).format(rera.expectedCompletionDate),
                          ),
                          _buildReraDetailItem("RERA RECORD ID", "#${rera.id}"),
                          _buildReraDetailItem(
                            "CREATED AT",
                            DateFormat(
                              'd MMM yyyy, HH:mm',
                            ).format(rera.createdAt),
                          ),
                          _buildReraDetailItem(
                            "LAST UPDATED",
                            DateFormat(
                              'd MMM yyyy, HH:mm',
                            ).format(rera.lastUpdated),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildReraSectionTitle(
                        "CERTIFICATES",
                        Icons.article_outlined,
                      ),
                      const SizedBox(height: 16),
                      if (rera.certificates.isEmpty)
                        _buildReraEmptyBox("No certificates attached.")
                      else
                        ...rera.certificates.map(
                          (cert) => _buildReraCertCard(cert),
                        ),
                      const SizedBox(height: 32),
                      _buildReraSectionTitle(
                        "QUARTER UPDATES",
                        Icons.calendar_month_outlined,
                      ),
                      const SizedBox(height: 16),
                      if (rera.quarterUpdates.isEmpty)
                        _buildReraEmptyBox("No quarterly updates recorded.")
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: rera.quarterUpdates
                              .map((q) => _buildReraQuarterCard(q))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReraStatusBadge(String status) {
    bool isActive = status.toUpperCase() == 'ACTIVE';
    Color color = isActive ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReraSmallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.outline),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.outline,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildReraSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.outline,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildReraDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.outline.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildReraEmptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.3),
          style: BorderStyle.none,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 24,
              color: AppColors.outline.withOpacity(0.2),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.outline.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReraCertCard(ReraCertificate cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: Color(0xFF705C00),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Date: ${DateFormat('d MMM yyyy').format(cert.certificateDate)}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (cert.certificateFileUrl != null &&
                  cert.certificateFileUrl!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 12,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "File attached",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildReraDetailItem("CERTIFIED BY", cert.certifiedBy ?? "—"),
              _buildReraDetailItem(
                "ADDED ON",
                DateFormat('d MMM yyyy, HH:mm').format(cert.createdAt),
              ),
            ],
          ),
          if (cert.remarks != null && cert.remarks!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildReraDetailItem("REMARKS", cert.remarks!),
          ],
        ],
      ),
    );
  }

  Widget _buildReraQuarterCard(ReraQuarterUpdate q) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range, size: 16, color: Color(0xFF705C00)),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM yyyy').format(q.quarterDate),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReraDetailItem("CONSTRUCTION", q.constructionStatus ?? "—"),
          const SizedBox(height: 12),
          _buildReraDetailItem("SALES", q.salesStatus ?? "—"),
        ],
      ),
    );
  }

  void _showAddReraDialog() {
    final numberController = TextEditingController();
    DateTime registrationDate = DateTime.now();
    DateTime expectedDate = DateTime.now().add(const Duration(days: 365));
    bool isActive = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF705C00), Color(0xFF2E3228)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add RERA Registration",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Register a new RERA project",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildModalBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.article_outlined,
                                        size: 16,
                                        color: Color(0xFF705C00),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "REGISTRATION DETAILS",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF705C00),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _buildModalLabel(
                                    "RERA NUMBER",
                                    required: true,
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: numberController,
                                    decoration: _modalInputDecoration(
                                      "E.G. P52100012345",
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildModalLabel(
                                              "REGISTRATION DATE",
                                            ),
                                            const SizedBox(height: 10),
                                            _buildDateTimePicker(
                                              registrationDate,
                                              (dt) => setDialogState(
                                                () => registrationDate = dt,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildModalLabel(
                                              "EXPECTED COMPLETION DATE",
                                            ),
                                            const SizedBox(height: 10),
                                            _buildDateTimePicker(
                                              expectedDate,
                                              (dt) => setDialogState(
                                                () => expectedDate = dt,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _buildModalLabel("STATUS"),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Switch(
                                        value: isActive,
                                        activeThumbColor: Colors.green,
                                        onChanged: (val) => setDialogState(
                                          () => isActive = val,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        isActive ? "Active" : "Inactive",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isActive
                                              ? Colors.green
                                              : AppColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    if (numberController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "RERA Number is required",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );

                                    final payload = {
                                      "reraNumber": numberController.text
                                          .trim(),
                                      "registrationDate": DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(registrationDate),
                                      "expectedCompletionDate": DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(expectedDate),
                                      "active": isActive,
                                    };

                                    int idToFetch = _detailedSite.projectId > 0
                                        ? _detailedSite.projectId
                                        : _detailedSite.id;
                                    final success =
                                        await ReraService.createReraProject(
                                          projectId: idToFetch,
                                          data: payload,
                                        );

                                    if (mounted)
                                      Navigator.pop(
                                        context,
                                      ); // Close loading spinner

                                    if (success) {
                                      if (mounted)
                                        Navigator.pop(context); // Close modal
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "RERA registration added successfully",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                      _fetchFullDetails(); // Force refresh directly from API
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Failed to add RERA registration",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.account_balance_rounded,
                                    size: 18,
                                  ),
                                  label: const Text("Add RERA"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF705C00,
                                    ).withValues(alpha: 0.6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }

  void _handleDeleteRera(int id, String reraNum) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete RERA Project",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Text(
          "Are you sure you want to delete '$reraNum'? This will remove all associated logs and certificates.",
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.plusJakartaSans(color: AppColors.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );
              final success = await ReraService.deleteReraProject(id);
              if (mounted) Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("RERA project deleted successfully"),
                  ),
                );
                _fetchFullDetails();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to delete RERA project"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              "Delete",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactReraStatus(String status) {
    final bool isActive = status.toUpperCase() == 'ACTIVE';
    final Color color = isActive ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return const SizedBox(height: 100);
  }
}

class _SmallChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color textColor;
  const _SmallChip({
    required this.text,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditSiteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _EditSiteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade700, Colors.brown.shade900],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings_outlined, size: 14, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "Edit Site",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final String priority;
  const _PriorityPill({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color = priority.toUpperCase() == 'HIGH'
        ? Colors.red
        : (priority.toUpperCase() == 'MEDIUM' ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        priority,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool small;
  final bool onlyDot;
  final bool hasDocuments;

  const _StatusBadge({
    required this.status,
    this.small = false,
    this.onlyDot = false,
    this.hasDocuments = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status.replaceAll('_', ' ');
    switch (status.toUpperCase()) {
      case 'PLANNING':
        bg = AppColors.chipPlanningBg;
        fg = AppColors.chipPlanningFg;
        break;
      case 'IN_PROGRESS':
        bg = AppColors.chipProgressBg;
        fg = AppColors.chipProgressFg;
        break;
      case 'COMPLETED':
        bg = AppColors.chipDoneBg;
        fg = AppColors.chipDoneFg;
        break;
      case 'ON_HOLD':
        bg = AppColors.chipHoldBg;
        fg = AppColors.chipHoldFg;
        break;
      default:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurfaceVariant;
    }

    if (onlyDot) {
      // Force green if documents are present, otherwise use status color
      final dotColor = hasDocuments ? AppColors.chipDoneFg : fg;

      return Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(small ? 8 : 12),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  final SiteStage stage;
  final int index; // sequential index (1 to 11)
  final VoidCallback onRefresh;

  const _StageTile({
    required this.stage,
    required this.index,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    List<SiteStage> subStages = stage.childStages;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          title: Text(
            _formatStageName(stage.customStageName ?? stage.stageName),
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusBadge(
                status: stage.status,
                onlyDot: true,
                hasDocuments: stage.documents.isNotEmpty,
              ),
              const SizedBox(width: 8),
              // Non-functional icon for parent titles
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 20,
                color: AppColors.chipDoneFg,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded, size: 20),
            ],
          ),
          children: [
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...subStages.map(
              (sub) =>
                  _SubStageTile(stage: sub, onRefresh: onRefresh, depth: 1),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// GroupedSubStages removed as it is no longer used in the refactored backend-driven Stages tab.

class _SubStageTile extends StatelessWidget {
  final SiteStage stage;
  final VoidCallback onRefresh;
  final int depth;

  const _SubStageTile({
    required this.stage,
    required this.onRefresh,
    this.depth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = stage.childStages.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(40.0 + (depth * 20.0), 10, 16, 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.outline.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatStageName(
                        stage.customStageName ?? stage.stageName,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: depth == 1 ? 12 : 11,
                        fontWeight: depth == 1
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (depth == 1)
                      Text(
                        hasChildren ? "SUB-CATEGORY" : "TASK ITEM",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.outline,
                        ),
                      ),
                  ],
                ),
              ),
              _StatusBadge(
                status: stage.status,
                onlyDot: true,
                hasDocuments: stage.documents.isNotEmpty,
              ),
              const SizedBox(width: 4),
              _AddDocButton(stage: stage, onSuccess: onRefresh),
            ],
          ),
        ),
        if (hasChildren)
          ...stage.childStages.map(
            (child) => _SubStageTile(
              stage: child,
              onRefresh: onRefresh,
              depth: depth + 1,
            ),
          ),
      ],
    );
  }
}

String _formatStageName(String name) {
  if (name.isEmpty) return "";
  // CONCEPT_DESIGN -> Concept Design
  final words = name.toLowerCase().split('_');
  return words
      .map((word) {
        if (word.isEmpty) return "";
        return word[0].toUpperCase() + word.substring(1);
      })
      .join(' ');
}

class _StageStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StageStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddDocButton extends StatelessWidget {
  final SiteStage stage;
  final VoidCallback onSuccess;

  const _AddDocButton({required this.stage, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showAddDocumentDialog(context, stage, onSuccess),
      icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
      color: AppColors.chipDoneFg,
      tooltip: "Add Document",
    );
  }
}

void _showAddDocumentDialog(
  BuildContext context,
  SiteStage stage,
  VoidCallback onSuccess,
) {
  final nameController = TextEditingController(
    text: stage.customStageName ?? stage.stageName,
  );
  final descController = TextEditingController();
  const Map<String, String> types = {
    'APPLICATION': 'Application',
    'NOC': 'NOC',
    'CERTIFICATE': 'Certificate',
    'DRAWING': 'Drawing',
    'LEGAL_DOCUMENT': 'Legal Document',
    'REPORT': 'Report',
    'CLEARANCE': 'Clearance',
    'RECEIPT': 'Receipt',
    'OTHER': 'Other',
  };
  String selectedType = 'OTHER';
  fp.PlatformFile? pickedFile;
  bool isUploading = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Document",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),

              const _FormLabel(label: "Stage"),
              Text(
                stage.customStageName ?? stage.stageName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),

              const _FormLabel(label: "Document Name"),
              _FormInput(
                controller: nameController,
                hint: "Enter document name",
              ),
              const SizedBox(height: 16),

              const _FormLabel(label: "Document Type"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: types.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(
                              e.value,
                              style: GoogleFonts.plusJakartaSans(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedType = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const _FormLabel(label: "Description"),
              _FormInput(
                controller: descController,
                hint: "Optional description",
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              const _FormLabel(label: "Upload File"),
              InkWell(
                onTap: () async {
                  fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
                    type: fp.FileType.any,
                    // allowedExtensions is ignored when type is any, but keeping for logic
                  );
                  if (result != null) {
                    setState(() => pickedFile = result.files.first);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(
                          "Choose File",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pickedFile?.name ?? "No file chosen",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isUploading
                        ? null
                        : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: (isUploading || pickedFile == null)
                        ? null
                        : () async {
                            setState(() => isUploading = true);
                            final success = await StageService.addStageDocument(
                              stageId: stage.id,
                              file: File(pickedFile!.path!),
                              documentName: nameController.text,
                              documentType: selectedType,
                              description: descController.text,
                            );
                            if (success) {
                              onSuccess();
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Document uploaded successfully!",
                                    ),
                                    backgroundColor: AppColors.chipDoneFg,
                                  ),
                                );
                              }
                            } else {
                              setState(() => isUploading = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Upload failed. Verify server connection.",
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Upload Document",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }
}

class _FormInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _FormInput({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.outline.withOpacity(0.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
