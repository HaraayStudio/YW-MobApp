import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import '../../services/client_service.dart';
import '../../services/post_sales_service.dart';
import '../../services/project_service.dart';
import 'package:intl/intl.dart';

class ProjectsSection extends StatefulWidget {
  final AppUser user;
  final Function(String) onToast;

  const ProjectsSection({super.key, required this.user, required this.onToast});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  String _filter = 'All';
  int? _detailId;

  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Form State
  bool _showCreateForm = false;
  bool _isNewClient = false;
  Client? _selectedClient;
  String _selectedStatus = 'CREATED';
  bool _isNotified = false;

  // Controllers
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _clientPasswordController = TextEditingController();
  final _remarkController = TextEditingController();

  List<Client> _allClients = [];
  Map<String, dynamic>? _selectedProject;

  // Edit State
  bool _isEditing = false;
  int _editTabIndex = 0;
  final Map<String, TextEditingController> _editCtrls = {};

  void _initEditForm(Map<String, dynamic> p) {
    _editTabIndex = 0;
    _editCtrls.clear();
    
    // Identity
    _editCtrls['projectName'] = TextEditingController(text: p['name'].toString().replaceFirst('Project - ', ''));
    _editCtrls['projectCode'] = TextEditingController(text: '');
    _editCtrls['permanentProjectId'] = TextEditingController(text: '');
    _editCtrls['projectDetails'] = TextEditingController(text: '');
    _editCtrls['projectStatus'] = TextEditingController(text: p['status'].toString().toUpperCase().replaceAll(' ', '_'));
    _editCtrls['priority'] = TextEditingController(text: 'MEDIUM');
    
    // Location
    _editCtrls['address'] = TextEditingController(text: '');
    _editCtrls['city'] = TextEditingController(text: p['location']);
    _editCtrls['latitude'] = TextEditingController(text: '');
    _editCtrls['longitude'] = TextEditingController(text: '');
    _editCtrls['googlePlace'] = TextEditingController(text: '');
    
    // Area
    _editCtrls['plotArea'] = TextEditingController(text: '');
    _editCtrls['totalBuiltUpArea'] = TextEditingController(text: p['area'] == 'N/A' ? '' : p['area']);
    _editCtrls['totalCarpetArea'] = TextEditingController(text: '');
    
    // Timeline
    _editCtrls['projectCreatedDateTime'] = TextEditingController(text: '');
    _editCtrls['projectStartDateTime'] = TextEditingController(text: '');
    _editCtrls['projectExpectedEndDate'] = TextEditingController(text: '');
    _editCtrls['projectEndDateTime'] = TextEditingController(text: '');

    _fetchFullProjectDetails(p['id']);
  }

  bool _editError = false;

  Future<void> _fetchFullProjectDetails(int projectId) async {
    setState(() {
      _isLoading = true;
      _editError = false;
    });
    try {
      final res = await ProjectService.getProjectById(projectId);
      if (res != null && mounted) {
        setState(() {
          _selectedProject = res;
          _initEditFormFields(res);
          _isLoading = false;
        });
      } else {
        // Stay in editing mode even if full fetch fails, just show warning if needed
        setState(() => _isLoading = false);
        debugPrint("Warning: Full project fetch returned null, using cached list data.");
      }
    } catch (e) {
      debugPrint("Error fetching full project: $e");
      setState(() => _isLoading = false);
    }
  }

  void _initEditFormFields(Map<String, dynamic> res) {
    _editCtrls['projectName']?.text = res['projectName'] ?? '';
    _editCtrls['projectCode']?.text = res['projectCode'] ?? '';
    _editCtrls['permanentProjectId']?.text = res['permanentProjectId'] ?? '';
    _editCtrls['projectDetails']?.text = res['projectDetails'] ?? '';
    _editCtrls['address']?.text = res['address'] ?? '';
    _editCtrls['city']?.text = res['city'] ?? '';
    _editCtrls['latitude']?.text = res['latitude']?.toString() ?? '';
    _editCtrls['longitude']?.text = res['longitude']?.toString() ?? '';
    _editCtrls['googlePlace']?.text = res['googlePlace'] ?? '';
    _editCtrls['plotArea']?.text = res['plotArea']?.toString() ?? '';
    _editCtrls['totalBuiltUpArea']?.text = res['totalBuiltUpArea']?.toString() ?? '';
    _editCtrls['totalCarpetArea']?.text = res['totalCarpetArea']?.toString() ?? '';
    _editCtrls['projectStatus']?.text = res['projectStatus'] ?? 'PLANNING';
    _editCtrls['priority']?.text = res['priority'] ?? 'MEDIUM';
    
    if (res['projectCreatedDateTime'] != null) _editCtrls['projectCreatedDateTime']?.text = _formatDate(res['projectCreatedDateTime'].toString());
    if (res['projectStartDateTime'] != null) _editCtrls['projectStartDateTime']?.text = _formatDate(res['projectStartDateTime'].toString());
    if (res['projectExpectedEndDate'] != null) _editCtrls['projectExpectedEndDate']?.text = _formatDate(res['projectExpectedEndDate'].toString());
    if (res['projectEndDateTime'] != null) _editCtrls['projectEndDateTime']?.text = _formatDate(res['projectEndDateTime'].toString());
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // 1. Brief delay to let the UI finish initial paint
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // 2. Fetch clients first (usually smaller/priority for dropdowns)
    await _fetchClients();
    if (!mounted) return;
    await _fetchProjects();
  }

  Future<void> _saveProjectChanges() async {
    if (_editCtrls['projectName']?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Project Name is required")));
      return;
    }

    setState(() => _isSaving = true);

    final projectData = {
      'projectName': _editCtrls['projectName']?.text,
      'projectCode': _editCtrls['projectCode']?.text,
      'permanentProjectId': _editCtrls['permanentProjectId']?.text,
      'projectStatus': _editCtrls['projectStatus']?.text,
      'priority': _editCtrls['priority']?.text,
      'projectDetails': _editCtrls['projectDetails']?.text,
      'address': _editCtrls['address']?.text,
      'city': _editCtrls['city']?.text,
      'latitude': double.tryParse(_editCtrls['latitude']?.text ?? ''),
      'longitude': double.tryParse(_editCtrls['longitude']?.text ?? ''),
      'googlePlace': _editCtrls['googlePlace']?.text,
      'plotArea': double.tryParse(_editCtrls['plotArea']?.text ?? ''),
      'totalBuiltUpArea': double.tryParse(_editCtrls['totalBuiltUpArea']?.text ?? ''),
      'totalCarpetArea': double.tryParse(_editCtrls['totalCarpetArea']?.text ?? ''),
      'projectCreatedDateTime': _toIso(_editCtrls['projectCreatedDateTime']?.text),
      'projectStartDateTime': _toIso(_editCtrls['projectStartDateTime']?.text),
      'projectExpectedEndDate': _toIso(_editCtrls['projectExpectedEndDate']?.text),
      'projectEndDateTime': _toIso(_editCtrls['projectEndDateTime']?.text),
    };

    final success = await ProjectService.updateProject(
      _selectedProject!['id'],
      projectData,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Project updated successfully!")));
      _fetchProjects();
      setState(() => _isEditing = false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update project.")));
    }

    setState(() => _isSaving = false);
  }

  Future<void> _fetchProjects() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await PostSalesService.getAllPostSales();
      debugPrint("RAW POST-SALES COUNT: ${data.length}");

      final mappedProjects = data.map((d) {
        final project = d['project'] ?? {};
        final client = d['client'] ?? {};

        String pName =
            (project['projectName'] != null &&
                project['projectName'].toString().isNotEmpty)
            ? project['projectName']
            : (client['name'] ?? 'Unknown Project');

        if (!pName.toLowerCase().startsWith('project')) {
          pName = "Project - $pName";
        }

        return {
          'id': project['projectId'] ?? 0,
          'psId': d['id'],
          'name': pName,
          'client': client['name'] ?? 'No Client',
          'location': project['city'] ?? 'N/A',
          'area': project['totalBuiltUpArea']?.toString() ?? 'N/A',
          'type': 'Architectural',
          'pct': 0.0,
          'status': _normalizeStatus(project['projectStatus'] ?? 'PLANNING'),
          'budget': 'N/A',
          'team': ['YW'],
          'start': _formatDate(d['postSalesdateTime']),
          'deadline': _formatDate(project['projectExpectedEndDate']),
          'updates': 0,
        };
      }).toList();

      mappedProjects.sort(
        (a, b) => (b['psId'] as int).compareTo(a['psId'] as int),
      );

      debugPrint("MAPPED PROJECTS COUNT: ${mappedProjects.length}");

      if (mounted) {
        setState(() {
          _projects = mappedProjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("FETCH PROJECTS ERROR: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onToast("Failed to load projects");
      }
    }
  }

  Future<void> _fetchClients() async {
    try {
      final data = await ClientService.getAllClients();
      if (mounted) {
        setState(() {
          _allClients = data.map((d) => Client.fromJson(d)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error fetching clients: $e");
      }
    }
  }

  String _formatDate(String? dt) {
    if (dt == null || dt.isEmpty) return 'TBA';
    try {
      final date = DateTime.parse(dt);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return 'TBA';
    }
  }

  String? _toIso(String? ddMMyyyy) {
    if (ddMMyyyy == null || ddMMyyyy.isEmpty || ddMMyyyy == 'TBA') return null;
    try {
      final parts = ddMMyyyy.split('/');
      if (parts.length == 3) {
        final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        return date.toIso8601String();
      }
      return DateTime.parse(ddMMyyyy).toIso8601String();
    } catch (_) {
      return null;
    }
  }

  String _normalizeStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PLANNING':
        return 'Planning';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'REVIEW':
        return 'Review';
      default:
        return 'Planning';
    }
  }

  bool get canCreate => [
    UserRole.admin,
    UserRole.coFounder,
    UserRole.srArchitect,
    UserRole.srEngineer,
    UserRole.liaisonManager,
  ].contains(widget.user.role);

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _projects;
    return _projects.where((p) => p['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) return _buildEditScreen();
    if (_showCreateForm) return _buildCreateForm();
    if (_detailId != null) return _buildDetail(_detailId!);
    return _buildList();
  }

  Widget _buildEditScreen() {
    if (_editError) {
      return Container(
        padding: const EdgeInsets.all(32),
        color: AppColors.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 20),
            const Text("Server Communication Error", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            const SizedBox(height: 8),
            const Text("We couldn't retrieve the project details from the backend. This might be a temporary issue or an authentication timeout.", 
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 32),
            GoldGradientButton(
              text: "Retry Connection",
              onTap: () {
                 final pid = _selectedProject?['projectId'] ?? _selectedProject?['id'];
                 if (pid != null) _fetchFullProjectDetails(pid is int ? pid : int.parse(pid.toString()));
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text("Go Back to List"),
            ),
          ],
        ),
      );
    }

    final statusKey = (_editCtrls['projectStatus']?.text ?? 'PLANNING').toUpperCase();
    final statusCfg = _STATUS_CONFIG[statusKey] ?? _STATUS_CONFIG['PLANNING']!;
    
    // Use absolute screen dimensions to bypass "infinite width" errors from parent scrollviews
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Container(
      width: screenWidth,
      height: screenHeight * 0.85, // Fixed height to satisfy the dashboard's constraints
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          // Header
          _buildEditHeader(statusCfg),
          // Tab bar
          _buildEditTabBar(),
          // Content Area
          Expanded(
            child: IndexedStack(
              index: _editTabIndex,
              children: [
                _buildEditIdentityTab(),
                _buildEditLocationTab(),
                _buildEditAreaTab(),
                _buildEditTimelineTab(),
                _buildEditLogoTab(),
              ],
            ),
          ),
          // Actions
          _buildEditFooter(),
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  Widget _buildEditHeader(Map<String, dynamic> statusCfg) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: () => setState(() => _isEditing = false), icon: const Icon(Icons.close_rounded)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Editing Project", style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    Text(_editCtrls['projectName']?.text ?? "Untitled", 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GoldGradientButton(
                text: _isSaving ? '...' : 'Save',
                icon: _isSaving ? null : Icons.save_rounded,
                onTap: _isSaving ? null : _saveProjectChanges,
                width: 95, 
                verticalPadding: 8,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statusChipSmall(_editCtrls['projectStatus']?.text ?? 'PLANNING', statusCfg),
              const SizedBox(width: 8),
              _chipSmall('📍 ${_editCtrls['city']?.text}', AppColors.surfaceContainerLow),
              const SizedBox(width: 8),
              _chipSmall('ID: ${_selectedProject!['psId']}', AppColors.surfaceContainerLow),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditTabBar() {
    final tabs = [
      {'icon': Icons.badge_rounded, 'label': 'Identity'},
      {'icon': Icons.location_on_rounded, 'label': 'Location'},
      {'icon': Icons.square_foot_rounded, 'label': 'Areas'},
      {'icon': Icons.event_rounded, 'label': 'Timeline'},
      {'icon': Icons.image_rounded, 'label': 'Logo'},
    ];

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (ctx, i) {
          bool active = _editTabIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _editTabIndex = i),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: active ? AppColors.primary : Colors.transparent, width: 2.5)),
              ),
              child: Row(
                children: [
                  Icon(tabs[i]['icon'] as IconData, size: 18, color: active ? AppColors.primary : AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(tabs[i]['label'] as String, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditIdentityTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _editField('PROJECT NAME', _editCtrls['projectName'] ?? TextEditingController(), "e.g. Adhya Ratan"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _editField('PROJECT CODE', _editCtrls['projectCode'] ?? TextEditingController(), "ABC-001")),
            const SizedBox(width: 16),
            Expanded(child: _editField('PERMANENT ID', _editCtrls['permanentProjectId'] ?? TextEditingController(), "P-2026-X")),
          ],
        ),
        const SizedBox(height: 16),
        _editField('DESCRIPTION', _editCtrls['projectDetails'] ?? TextEditingController(), "Detailed project description...", lines: 3),
        const SizedBox(height: 24),
        const Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 12),
        _buildEditStatusPicker(),
        const SizedBox(height: 24),
        const Text("PRIORITY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 12),
        _buildEditPriorityPicker(),
      ],
    );
  }

  Widget _buildEditLocationTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _editField('ADDRESS', _editCtrls['address'] ?? TextEditingController(), "Full project address", lines: 2),
        const SizedBox(height: 16),
        _editField('CITY', _editCtrls['city'] ?? TextEditingController(), "e.g. Pune"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _editField('LATITUDE', _editCtrls['latitude'] ?? TextEditingController(), "18.5204", type: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _editField('LONGITUDE', _editCtrls['longitude'] ?? TextEditingController(), "73.8567", type: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _editField('GOOGLE MAPS LINK', _editCtrls['googlePlace'] ?? TextEditingController(), "Paste share link here", icon: Icons.map_outlined),
      ],
    );
  }

  Widget _buildEditAreaTab() {
    final plot = double.tryParse(_editCtrls['plotArea']?.text ?? '0') ?? 0;
    final built = double.tryParse(_editCtrls['totalBuiltUpArea']?.text ?? '0') ?? 0;
    final carpet = double.tryParse(_editCtrls['totalCarpetArea']?.text ?? '0') ?? 0;
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: _editField('PLOT AREA', _editCtrls['plotArea'] ?? TextEditingController(), "sq.ft", type: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _editField('TOTAL BUILT-UP', _editCtrls['totalBuiltUpArea'] ?? TextEditingController(), "sq.ft", type: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _editField('TOTAL CARPET AREA', _editCtrls['totalCarpetArea'] ?? TextEditingController(), "sq.ft", type: TextInputType.number),
        const SizedBox(height: 30),
        const Text("AREA SUMMARY VISUALIZATION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 20),
        _buildAreaBar("Plot Area", plot, Colors.blue.shade100, Colors.blue),
        _buildAreaBar("Built-up Area", built, Colors.orange.shade100, Colors.orange),
        _buildAreaBar("Carpet Area", carpet, Colors.green.shade100, Colors.green),
      ],
    );
  }

  Widget _buildEditTimelineTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _editField('CREATED AT', _editCtrls['projectCreatedDateTime'] ?? TextEditingController(), "Read-only", readOnly: true),
        const SizedBox(height: 16),
        _editDateField('PROJECT START DATE', _editCtrls['projectStartDateTime'] ?? TextEditingController(),),
        const SizedBox(height: 16),
        _editDateField('EXPECTED END DATE', _editCtrls['projectExpectedEndDate'] ?? TextEditingController(),),
        const SizedBox(height: 16),
        _editDateField('ACTUAL END DATE', _editCtrls['projectEndDateTime'] ?? TextEditingController(),),
      ],
    );
  }

  Widget _buildEditLogoTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.add_photo_alternate_rounded, size: 40, color: AppColors.outline),
          ),
          const SizedBox(height: 16),
          const Text("Project Logo Management", style: TextStyle(fontWeight: FontWeight.bold)),
          const Text("Coming soon: Logo upload and preview", style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildEditFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)))),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () => setState(() => _isEditing = false), child: const Text("Discard Changes"))),
          const SizedBox(width: 16),
          Expanded(child: GoldGradientButton(text: "Save Changes", onTap: _saveProjectChanges)),
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController ctrl, String hintText, {int lines = 1, TextInputType type = TextInputType.text, bool readOnly = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl, maxLines: lines, keyboardType: type, readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText, prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            filled: readOnly, fillColor: readOnly ? AppColors.surfaceContainerLow : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.outlineVariant)),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _editDateField(String label, TextEditingController ctrl) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (date != null) setState(() => ctrl.text = DateFormat('dd/MM/yyyy').format(date));
      },
      child: AbsorbPointer(child: _editField(label, ctrl, "Select date", icon: Icons.calendar_month_rounded)),
    );
  }

  Widget _buildAreaBar(String label, double val, Color bg, Color bar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 12)), Text('${val.toStringAsFixed(0)} sq.ft', style: const TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (val / 10000).clamp(0.0, 1.0), backgroundColor: bg, color: bar, minHeight: 8)),
        ],
      ),
    );
  }

  Widget _buildEditStatusPicker() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _STATUS_CONFIG.entries.map((e) {
        bool active = _editCtrls['projectStatus']?.text == e.key;
        return GestureDetector(
          onTap: () => setState(() => _editCtrls['projectStatus']?.text = e.key),
          child: _statusChipSmall(e.key, e.value, active: active),
        );
      }).toList(),
    );
  }

  Widget _buildEditPriorityPicker() {
    final priorities = {
      'HIGH': {'label': 'High', 'bg': const Color(0xFFFEF2F2), 'fg': const Color(0xFF991B1B)},
      'MEDIUM': {'label': 'Medium', 'bg': const Color(0xFFFEF9C3), 'fg': const Color(0xFF854D0E)},
      'LOW': {'label': 'Low', 'bg': const Color(0xFFEFF6FF), 'fg': const Color(0xFF1E40AF)},
    };
    return Wrap(
      spacing: 8,
      children: priorities.entries.map((e) {
        bool active = _editCtrls['priority']?.text == e.key;
        return GestureDetector(
          onTap: () => setState(() => _editCtrls['priority']?.text = e.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? (e.value['bg'] as Color) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? (e.value['fg'] as Color) : AppColors.outlineVariant),
            ),
            child: Text(e.value['label'] as String, style: TextStyle(color: active ? (e.value['fg'] as Color) : AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  Widget _statusChipSmall(String key, Map<String, dynamic> cfg, {bool active = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? cfg['bg'] : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? cfg['dot'] : AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: cfg['dot'] as Color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(cfg['label'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? cfg['color'] : AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _chipSmall(String label, Color bg) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)));
  }

  final Map<String, Map<String, dynamic>> _STATUS_CONFIG = {
    'PLANNING': {'label': 'Planning', 'bg': const Color(0xFFE0F2FE), 'color': const Color(0xFF0369A1), 'dot': const Color(0xFF0284C7)},
    'IN_PROGRESS': {'label': 'In Progress', 'bg': const Color(0xFFFEF9C3), 'color': const Color(0xFF854D0E), 'dot': const Color(0xFFCA8A04)},
    'COMPLETED': {'label': 'Completed', 'bg': const Color(0xFFDCFCE7), 'color': const Color(0xFF166534), 'dot': const Color(0xFF16A34A)},
    'ON_HOLD': {'label': 'On Hold', 'bg': const Color(0xFFF3F4F6), 'color': const Color(0xFF374151), 'dot': const Color(0xFF6B7280)},
    'REVIEW': {'label': 'In Review', 'bg': const Color(0xFFF3E8FF), 'color': const Color(0xFF6B21A8), 'dot': const Color(0xFF9333EA)},
  };

  Widget _buildList() {
    final tabs = ['All', 'In Progress', 'Planning', 'Review', 'Completed'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Projects',
            subtitle: '${_projects.length} active engagements',
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t = tabs[i];
                final active = _filter == t;
                return GestureDetector(
                  onTap: () => setState(() => _filter = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.outline,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  "No projects found",
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            )
          else
            ..._filtered.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => setState(() => _detailId = p['id'] as int),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.outlineVariant.withOpacity(0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        ProgressBar(percent: p['pct'] as double, height: 5),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                p['name'] as String,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: AppColors.onSurface,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                p['type'] as String,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          p['client'] as String,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_rounded,
                                              size: 12,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              p['location'] as String,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip(status: p['status'] as String),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _infoBox('Budget', p['budget'] as String),
                                  const SizedBox(width: 8),
                                  _infoBox('Area', p['area'] as String),
                                  const SizedBox(width: 8),
                                  _infoBox('Updates', '${p['updates']}'),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: (p['team'] as List<dynamic>)
                                        .map<Widget>(
                                          (m) => Padding(
                                            padding: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: AvatarWidget(
                                              initials: m as String,
                                              size: 28,
                                              fontSize: 9,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 14,
                                        color: AppColors.primaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Due: ${p['deadline']}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
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
              ),
            ),
          if (canCreate)
            GoldGradientButton(
              text: 'Create New Project',
              icon: Icons.add_rounded,
              onTap: () => setState(() => _showCreateForm = true),
            ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(),
          const SizedBox(height: 24),
          _buildClientInfoSection(),
          const SizedBox(height: 16),
          _buildProjectDetailsSection(),
          const SizedBox(height: 16),
          _buildRemarkSection(),
          const SizedBox(height: 16),
          _buildInfoBox(),
          const SizedBox(height: 24),
          _buildFormActions(),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'PS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Project',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Direct Entry · ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statusBadge(_selectedStatus),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isNotified
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isNotified
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 14,
                            color: _isNotified
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isNotified ? 'Client Notified' : 'Not Notified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _isNotified
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF991B1B),
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
          IconButton(
            onPressed: () => setState(() => _showCreateForm = false),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.onSurfaceVariant,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoSection() {
    return CardContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                'Client Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _modeBtn(true, 'Existing Client', Icons.person_search_rounded),
              const SizedBox(width: 12),
              _modeBtn(false, 'New Client', Icons.person_add_rounded),
            ],
          ),
          const SizedBox(height: 24),
          if (!_isNewClient)
            _buildExistingClientSearch()
          else
            _buildNewClientForm(),
        ],
      ),
    );
  }

  Widget _modeBtn(bool existing, String label, IconData icon) {
    bool active = _isNewClient != existing;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isNewClient = !existing),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.outlineVariant,
              width: active ? 1.5 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingClientSearch() {
    if (_selectedClient != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            AvatarWidget(
              initials: _selectedClient!.name[0],
              size: 48,
              fontSize: 18,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedClient!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${_selectedClient!.email ?? ''} · ${_selectedClient!.phone ?? ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _selectedClient = null),
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SEARCH CLIENT *',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<Client>(
          displayStringForOption: (c) => c.name,
          optionsBuilder: (textEditingValue) {
            // Show all (trimmed to 20 for performance) if empty, else filter
            if (textEditingValue.text == '') {
              return _allClients.take(20);
            }
            return _allClients.where((c) {
              return c.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ) ||
                  (c.phone?.contains(textEditingValue.text) ?? false);
            });
          },
          onSelected: (c) => setState(() => _selectedClient = c),
          fieldViewBuilder: (ctx, ctrl, focus, onFieldSubmitted) {
            return TextField(
              controller: ctrl,
              focusNode: focus,
              onTap: () {
                // Clicking the field will now trigger the dropdown if empty
                if (ctrl.text.isEmpty) {
                  // Small hack to trigger Autocomplete's optionsBuilder
                  ctrl.text = '';
                }
              },
              decoration: InputDecoration(
                hintText: 'Search client name or phone...',
                hintStyle: const TextStyle(color: AppColors.outline),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.outline,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.outline,
                  ),
                  onPressed: () {
                    focus.requestFocus();
                    // Trigger the dropdown by "changing" the value
                    if (ctrl.text.isEmpty) {
                      ctrl.text = '';
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            );
          },
          optionsViewBuilder: (ctx, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: MediaQuery.of(ctx).size.width - 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final c = options.elementAt(i);
                      return ListTile(
                        leading: AvatarWidget(
                          initials: c.name[0],
                          size: 32,
                          fontSize: 12,
                        ),
                        title: Text(
                          c.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          c.email ?? 'No Email',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          c.phone ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => onSelected(c),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNewClientForm() {
    return Column(
      children: [
        _formField('CLIENT NAME *', _clientNameController, 'Enter client name'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _formField(
                'EMAIL *',
                _clientEmailController,
                'Enter email address',
                type: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _formField(
                'PHONE *',
                _clientPhoneController,
                'Enter phone number',
                type: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _formField(
          'ADDRESS',
          _clientAddressController,
          'Enter address (optional)',
        ),
        const SizedBox(height: 16),
        _formField(
          'PASSWORD *',
          _clientPasswordController,
          'Min. 6 characters',
          obscure: true,
          hint: 'Client will use this password to log in to the client portal',
        ),
      ],
    );
  }

  Widget _formField(
    String label,
    TextEditingController ctrl,
    String placeholder, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.outline),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProjectDetailsSection() {
    final statuses = [
      {
        'val': 'CREATED',
        'bg': const Color(0xFFE0F2FE),
        'fg': const Color(0xFF0369A1),
        'dot': const Color(0xFF0284C7),
      },
      {
        'val': 'IN_PROGRESS',
        'bg': const Color(0xFFFEF9C3),
        'fg': const Color(0xFF854D0E),
        'dot': const Color(0xFFCA8A04),
      },
      {
        'val': 'COMPLETED',
        'bg': const Color(0xFFDCFCE7),
        'fg': const Color(0xFF166534),
        'dot': const Color(0xFF16A34A),
      },
      {
        'val': 'CANCELLED',
        'bg': const Color(0xFFFEE2E2),
        'fg': const Color(0xFF991B1B),
        'dot': const Color(0xFFDC2626),
      },
      {
        'val': 'PENDING',
        'bg': const Color(0xFFF3E8FF),
        'fg': const Color(0xFF6B21A8),
        'dot': const Color(0xFF9333EA),
      },
    ];

    return CardContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_copy_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                'Project Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'STATUS *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: statuses.map((s) {
              bool active = _selectedStatus == s['val'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedStatus = s['val'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? s['bg'] as Color
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active
                          ? s['dot'] as Color
                          : AppColors.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: s['dot'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (s['val'] as String).replaceFirst('_', ' '),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? s['fg'] as Color
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Client Notified',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Has the client been informed about this Project?',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isNotified,
                  onChanged: (v) => setState(() => _isNotified = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkSection() {
    return CardContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Text(
                'Remark',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'INTERNAL NOTE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _remarkController,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText:
                  'e.g. Client confirmed via call. Project kickoff next week...',
              hintStyle: const TextStyle(color: AppColors.outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (v) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF0284C7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Auto-generated on save',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF0369A1),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Date & time and a linked project will be created automatically by the server. Invoices and payments can be added after creation.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF0369A1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _showCreateForm = false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: AppColors.outlineVariant),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: GoldGradientButton(
            text: _isSaving ? 'Creating...' : 'Create Project',
            onTap: _isSaving ? null : _submitProject,
          ),
        ),
      ],
    );
  }

  Future<void> _submitProject() async {
    // Validation
    if (!_isNewClient && _selectedClient == null) {
      widget.onToast("Please select a client");
      return;
    }
    if (_isNewClient) {
      if (_clientNameController.text.isEmpty ||
          _clientEmailController.text.isEmpty ||
          _clientPhoneController.text.isEmpty ||
          _clientPasswordController.text.isEmpty) {
        widget.onToast("Please fill all required client fields");
        return;
      }
    }

    setState(() => _isSaving = true);

    final payload = {
      'postSalesStatus': _selectedStatus,
      'notified': _isNotified,
      'remark': _remarkController.text,
    };

    if (!_isNewClient) {
      payload['client'] = {'id': _selectedClient!.id};
    } else {
      payload['client'] = {
        'name': _clientNameController.text,
        'email': _clientEmailController.text,
        'phone': int.tryParse(_clientPhoneController.text) ?? 0,
        'address': _clientAddressController.text,
        'password': _clientPasswordController.text,
      };
    }

    try {
      final res = await PostSalesService.createPostSale(
        payload: payload,
        isOldClient: !_isNewClient,
      );

      if (res['success'] == true) {
        widget.onToast("Project created successfully!");
        setState(() {
          _showCreateForm = false;
          _isSaving = false;
          _filter = 'All'; // Reset filter to show all including new one
        });

        // Small delay to let backend persist completely
        Future.delayed(
          const Duration(milliseconds: 600),
          () => _fetchProjects(),
        );
      } else {
        widget.onToast(res['message'] ?? "Failed to create project");
        setState(() => _isSaving = false);
      }
    } catch (e) {
      widget.onToast("An error occurred. Please try again.");
      setState(() => _isSaving = false);
    }
  }

  Widget _buildDetail(int id) {
    final p = _projects.firstWhere((x) => x['id'] == id);
    final teamMembers = [
      {'name': 'Rahul Kapoor', 'role': 'Senior Architect', 'init': 'RK'},
      {'name': 'Priya Singh', 'role': 'Interior Designer', 'init': 'PS'},
      {'name': 'Amit Joshi', 'role': 'Site Engineer', 'init': 'AJ'},
      {'name': 'Varun Rao', 'role': '3D Visualizer', 'init': 'VR'},
    ];
    final activity = [
      {
        'icon': Icons.photo_camera_rounded,
        'text': 'Amit uploaded 8 site progress photos',
        'time': '2 hrs ago',
      },
      {
        'icon': Icons.task_alt_rounded,
        'text': 'Floor plan drawings marked complete',
        'time': 'Yesterday',
      },
      {
        'icon': Icons.comment_rounded,
        'text': 'Client approved plumbing layout',
        'time': '3 days ago',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _detailId = null),
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
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    _selectedProject = p;
                    _initEditForm(p);
                    _isEditing = true;
                  });
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'] as String,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '${p['client']} · ${p['type']}',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                p['location'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    StatusChip(status: p['status'] as String),
                  ],
                ),
                const SizedBox(height: 14),
                ProgressBar(percent: p['pct'] as double, height: 8),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${((p['pct'] as double) * 100).toInt()}% Complete',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
            children:
                [
                      ['Budget', p['budget'] as String],
                      ['Area', p['area'] as String],
                      ['Start', p['start'] as String],
                      ['Deadline', p['deadline'] as String],
                      ['Phase', 'Construction'],
                      ['Updates', '${p['updates']}'],
                    ]
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item[0],
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              item[1],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Project Team',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...teamMembers.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CardContainer(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    AvatarWidget(initials: m['init']!, size: 40, fontSize: 14),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          m['role']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...activity.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      a['icon'] as IconData,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a['text'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            a['time'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg = const Color(0xFFE0F2FE);
    Color fg = const Color(0xFF0369A1);
    Color dot = const Color(0xFF0284C7);

    if (status == 'IN_PROGRESS') {
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
    } else if (status == 'PENDING') {
      bg = const Color(0xFFF3E8FF);
      fg = const Color(0xFF6B21A8);
      dot = const Color(0xFF9333EA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
