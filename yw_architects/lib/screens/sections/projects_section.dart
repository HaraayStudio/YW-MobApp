import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/responsive.dart';
import '../../services/client_service.dart';
import '../../services/post_sales_service.dart';
import '../../services/project_service.dart';
import '../../widgets/postsale_tabs/post_sale_detail_view.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/base64_utils.dart';


class ProjectsSection extends StatefulWidget {
  final AppUser user;
  final Function(String) onToast;
  final int? editProjectId;
  final Function(int projectId)? onNavigateToSite;

  const ProjectsSection({
    super.key,
    required this.user,
    required this.onToast,
    this.editProjectId,
    this.onNavigateToSite,
  });

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  String _filter = 'All';
  int? _detailId;
  int _currentPage = 0;
  static const int _itemsPerPage = 10;

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
  String? _pickedLogoBase64;
  String? _createLogoBase64;
  bool _isPickingLogo = false;

  void _initEditForm(Map<String, dynamic> p) {
    _selectedProject = p;
    _editTabIndex = 0;
    _editCtrls.clear();

    // Use the raw project object stored during list fetch for immediate pre-fill
    final raw = (p['_raw'] as Map<String, dynamic>?) ?? {};

    // Helper for fallbacks
    String getV(String camel, String snake) =>
        (raw[camel] ?? raw[snake])?.toString() ?? '';

    // Identity
    _editCtrls['projectName'] = TextEditingController(
      text: getV('projectName', 'project_name').isNotEmpty
          ? getV('projectName', 'project_name')
          : p['name'].toString(),
    );
    _editCtrls['projectCode'] = TextEditingController(
      text: getV('projectCode', 'project_code'),
    );
    _editCtrls['permanentProjectId'] = TextEditingController(
      text: getV('permanentProjectId', 'permanent_project_id'),
    );
    _editCtrls['projectDetails'] = TextEditingController(
      text: getV('projectDetails', 'project_details'),
    );
    final statusVal = getV('projectStatus', 'project_status');
    _editCtrls['projectStatus'] = TextEditingController(
      text: statusVal.isNotEmpty
          ? statusVal
          : p['status'].toString().toUpperCase().replaceAll(' ', '_'),
    );
    _editCtrls['priority'] = TextEditingController(
      text: getV('priority', 'priority').isNotEmpty
          ? getV('priority', 'priority')
          : 'MEDIUM',
    );

    // Location
    _editCtrls['address'] = TextEditingController(
      text: getV('address', 'address'),
    );
    _editCtrls['city'] = TextEditingController(text: getV('city', 'city'));
    _editCtrls['latitude'] = TextEditingController(
      text: getV('latitude', 'latitude'),
    );
    _editCtrls['longitude'] = TextEditingController(
      text: getV('longitude', 'longitude'),
    );
    _editCtrls['googlePlace'] = TextEditingController(
      text: getV('googlePlace', 'google_place'),
    );

    // Area
    _editCtrls['plotArea'] = TextEditingController(
      text: getV('plotArea', 'plot_area'),
    );
    _editCtrls['totalBuiltUpArea'] = TextEditingController(
      text: getV('totalBuiltUpArea', 'total_built_up_area'),
    );
    _editCtrls['totalCarpetArea'] = TextEditingController(
      text: getV('totalCarpetArea', 'total_carpet_area'),
    );

    // Timeline - helpers for dates
    String getD(String c, String s) =>
        raw[c]?.toString() ?? raw[s]?.toString() ?? '';

    _editCtrls['projectCreatedDateTime'] = TextEditingController(
      text:
          getD('projectCreatedDateTime', 'project_created_date_time').isNotEmpty
          ? _formatDate(
              getD('projectCreatedDateTime', 'project_created_date_time'),
            )
          : '',
    );
    _editCtrls['projectStartDateTime'] = TextEditingController(
      text: getD('projectStartDateTime', 'project_start_date_time').isNotEmpty
          ? _formatDate(getD('projectStartDateTime', 'project_start_date_time'))
          : '',
    );
    _editCtrls['projectExpectedEndDate'] = TextEditingController(
      text:
          getD('projectExpectedEndDate', 'project_expected_end_date').isNotEmpty
          ? _formatDate(
              getD('projectExpectedEndDate', 'project_expected_end_date'),
            )
          : '',
    );
    _editCtrls['projectEndDateTime'] = TextEditingController(
      text: getD('projectEndDateTime', 'project_end_date_time').isNotEmpty
          ? _formatDate(getD('projectEndDateTime', 'project_end_date_time'))
          : '',
    );

    _pickedLogoBase64 = null; // Reset for new edit session

    // Background refresh — if API works, it will update with latest data
    _fetchFullProjectDetails(p['id']);
  }

  bool _editError = false;

  /// [silent] = true skips the loading spinner (for background syncs)
  Future<void> _fetchFullProjectDetails(
    int projectId, {
    bool silent = false,
  }) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _editError = false;
      });
    }
    try {
      final res = await ProjectService.getProjectById(projectId);
      if (res != null && mounted) {
        // Extract city, address, area from the FULL project response
        final city = (res['city'] ?? res['projectCity'] ?? '')
            .toString()
            .trim();
        final address = (res['address'] ?? res['projectAddress'] ?? '')
            .toString()
            .trim();
        final plotArea = (res['plotArea'] ?? res['plot_area'] ?? '')
            .toString()
            .trim();
        final builtArea =
            (res['totalBuiltUpArea'] ?? res['total_built_up_area'] ?? '')
                .toString()
                .trim();
        final area = (() {
          if (plotArea.isNotEmpty && plotArea != '0' && plotArea != 'null')
            return '$plotArea sq.ft';
          if (builtArea.isNotEmpty && builtArea != '0' && builtArea != 'null')
            return '$builtArea sq.ft';
          return 'N/A';
        })();

        setState(() {
          // ✅ KEY FIX: Update _projects list so the card shows real city/address
          final idx = _projects.indexWhere((p) => p['id'] == projectId);
          if (idx != -1) {
            final updated = Map<String, dynamic>.from(_projects[idx]);
            if (city.isNotEmpty && city != 'null') updated['location'] = city;
            if (address.isNotEmpty && address != 'null')
              updated['address'] = address;
            if (area != 'N/A') updated['area'] = area;
            updated['_raw'] = res;
            _projects[idx] = updated;
          }

          // Also update the selected project / edit form if this is the current one
          if (_selectedProject != null) {
            final pid =
                _selectedProject?['projectId'] ??
                _selectedProject?['id'] ??
                _selectedProject?['project_id'];
            if (pid == projectId) {
              _selectedProject = res;
              _initEditFormFields(res);
            }
          }

          _isLoading = false;
        });

        debugPrint(
          "FULL DETAIL SYNCED: project $projectId → city=$city, address=$address",
        );
      } else {
        if (mounted) setState(() => _isLoading = false);
        debugPrint(
          "Warning: Full project fetch returned null for project $projectId",
        );
      }
    } catch (e) {
      debugPrint("Error fetching full project: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initEditFormFields(Map<String, dynamic> res) {
    // Helper to get value from camelCase (default) or snake_case (fallback)
    String getV(String camel, String snake) =>
        (res[camel] ?? res[snake])?.toString() ?? '';

    _editCtrls['projectName']?.text = getV('projectName', 'project_name');
    _editCtrls['projectCode']?.text = getV('projectCode', 'project_code');
    _editCtrls['permanentProjectId']?.text = getV(
      'permanentProjectId',
      'permanent_project_id',
    );
    _editCtrls['projectDetails']?.text = getV(
      'projectDetails',
      'project_details',
    );
    _editCtrls['address']?.text = getV('address', 'address');
    _editCtrls['city']?.text = getV('city', 'city');
    _editCtrls['latitude']?.text = getV('latitude', 'latitude');
    _editCtrls['longitude']?.text = getV('longitude', 'longitude');
    _editCtrls['googlePlace']?.text = getV('googlePlace', 'google_place');
    _editCtrls['plotArea']?.text = getV('plotArea', 'plot_area');
    _editCtrls['totalBuiltUpArea']?.text = getV(
      'totalBuiltUpArea',
      'total_built_up_area',
    );
    _editCtrls['totalCarpetArea']?.text = getV(
      'totalCarpetArea',
      'total_carpet_area',
    );
    _editCtrls['projectStatus']?.text =
        getV('projectStatus', 'project_status').isNotEmpty
        ? getV('projectStatus', 'project_status')
        : 'PLANNING';
    _editCtrls['priority']?.text = getV('priority', 'priority').isNotEmpty
        ? getV('priority', 'priority')
        : 'MEDIUM';

    // Dates helpers
    String getD(String c, String s) =>
        res[c]?.toString() ?? res[s]?.toString() ?? '';

    if (getD('projectCreatedDateTime', 'project_created_date_time').isNotEmpty)
      _editCtrls['projectCreatedDateTime']?.text = _formatDate(
        getD('projectCreatedDateTime', 'project_created_date_time'),
      );
    if (getD('projectStartDateTime', 'project_start_date_time').isNotEmpty)
      _editCtrls['projectStartDateTime']?.text = _formatDate(
        getD('projectStartDateTime', 'project_start_date_time'),
      );
    if (getD('projectExpectedEndDate', 'project_expected_end_date').isNotEmpty)
      _editCtrls['projectExpectedEndDate']?.text = _formatDate(
        getD('projectExpectedEndDate', 'project_expected_end_date'),
      );
    if (getD('projectEndDateTime', 'project_end_date_time').isNotEmpty)
      _editCtrls['projectEndDateTime']?.text = _formatDate(
        getD('projectEndDateTime', 'project_end_date_time'),
      );
  }

  @override
  void initState() {
    super.initState();
    _initData();
    if (widget.editProjectId != null) {
      // Initialize form with skeleton data to prepare controllers
      _initEditForm({
        'id': widget.editProjectId,
        'name': 'Loading...',
        'status': 'PLANNING',
      });
      _isEditing = true;
    }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Project Name is required")));
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
      'totalBuiltUpArea': double.tryParse(
        _editCtrls['totalBuiltUpArea']?.text ?? '',
      ),
      'totalCarpetArea': double.tryParse(
        _editCtrls['totalCarpetArea']?.text ?? '',
      ),
      'projectCreatedDateTime': _toIso(
        _editCtrls['projectCreatedDateTime']?.text,
      ),
      'projectStartDateTime': _toIso(_editCtrls['projectStartDateTime']?.text),
      'projectExpectedEndDate': _toIso(
        _editCtrls['projectExpectedEndDate']?.text,
      ),
      'projectEndDateTime': _toIso(_editCtrls['projectEndDateTime']?.text),
      'logoUrl':
          _pickedLogoBase64 ??
          _selectedProject?['logoUrl'] ??
          _selectedProject?['logo_url'],
    };

    final projectId =
        _selectedProject!['projectId'] ??
        _selectedProject!['id'] ??
        _selectedProject!['project_id'];

    List<int>? logoBytes;
    if (_pickedLogoBase64 != null) {
      try {
        logoBytes = base64Decode(_pickedLogoBase64!.split(',').last);
      } catch (e) {
        debugPrint("Error decoding logo bytes: $e");
      }
    }

    try {
      final success = await ProjectService.updateProject(
        projectId as int,
        projectData,
        logoBytes: logoBytes,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project updated successfully!")),
        );

        // OPTIMISTIC UPDATE: Update local list immediately
        setState(() {
          final idx = _projects.indexWhere((p) => p['id'] == projectId);
          if (idx != -1) {
            final p = Map<String, dynamic>.from(_projects[idx]);

            // Identity
            p['name'] = projectData['projectName'] ?? p['name'];
            p['code'] =
                projectData['projectCode']?.toString().isNotEmpty == true
                ? projectData['projectCode']
                : '—';
            p['status'] = _normalizeStatus(
              projectData['projectStatus']?.toString() ?? 'PLANNING',
            );

            // Location/Address
            final newCity = projectData['city']?.toString().trim() ?? '';
            final newAddr = projectData['address']?.toString().trim() ?? '';
            p['location'] = newCity.isNotEmpty ? newCity : 'N/A';
            p['address'] = newAddr.isNotEmpty ? newAddr : 'N/A';

            // Area mapping logic
            final plot = projectData['plotArea']?.toString() ?? '';
            final built = projectData['totalBuiltUpArea']?.toString() ?? '';
            if (plot.isNotEmpty && plot != '0' && plot != 'null') {
              p['area'] = '$plot sq.ft';
            } else if (built.isNotEmpty && built != '0' && built != 'null') {
              p['area'] = '$built sq.ft';
            } else {
              p['area'] = 'N/A';
            }

            // Dates
            if (projectData['projectStartDateTime'] != null) {
              p['start'] = _formatDate(
                projectData['projectStartDateTime'].toString(),
              );
            }
            if (projectData['projectExpectedEndDate'] != null) {
              p['deadline'] = _formatDate(
                projectData['projectExpectedEndDate'].toString(),
              );
            }

            // Update raw data
            final raw = Map<String, dynamic>.from(p['_raw'] ?? {});
            raw.addAll(projectData);
            p['_raw'] = raw;

            _projects[idx] = p;
          }
          _isEditing = false;
        });

        // Background fetch to ensure sync
        Future.delayed(
          const Duration(milliseconds: 500),
          () => _fetchProjects(),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update project.")),
        );
      }
    } catch (e) {
      debugPrint("Error saving project: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while saving")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _fetchProjects() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      var data = await PostSalesService.getAllPostSales();
      debugPrint("RAW POST-SALES COUNT: ${data.length}");

      // Filter for clients
      if (widget.user.role == UserRole.client) {
        final userId = widget.user.id;
        data = data.where((d) {
          final client = d['client'] ?? {};
          final clientId = client['id'];
          return clientId == userId;
        }).toList();
        debugPrint(
          "FILTERED POST-SALES COUNT FOR CLIENT #$userId: ${data.length}",
        );
      }

      final mappedProjects = data.map((d) {
        final project = d['project'] ?? {};
        final client = d['client'] ?? {};

        // DIAGNOSTIC: Print keys to console so we can see exactly what the server sends
        if (data.indexOf(d) == 0) {
          debugPrint("--- PROJECT DATA DEBUG ---");
          debugPrint("PROJECT KEYS: ${project.keys.toList()}");
          debugPrint("RAW CITY: ${project['city']}");
          debugPrint("RAW ADDR: ${project['address']}");
          debugPrint("-------------------------");
        }

        // 1. IDENTITY
        String pName =
            (project['projectName'] ?? project['project_name'])?.toString() ??
            '';
        if (pName.isEmpty) pName = (client['name'] ?? 'Unknown Project');

        // 2. LOCATION - EXHAUSTIVE CHECK
        // We look for every possible variation of 'city' and 'address'
        final city =
            (project['city'] ??
                    project['projectCity'] ??
                    project['project_city'] ??
                    project['location'] ??
                    d['city'] ??
                    d['project_city'] ??
                    '')
                .toString()
                .trim();

        final fullAddress =
            (project['address'] ??
                    project['projectAddress'] ??
                    project['project_address'] ??
                    project['location_address'] ??
                    d['address'] ??
                    d['project_address'] ??
                    '')
                .toString()
                .trim();

        // 3. AREA - EXHAUSTIVE CHECK
        final area = (() {
          final plot =
              (project['plotArea'] ??
                      project['plot_area'] ??
                      project['area'] ??
                      '')
                  .toString()
                  .trim();
          final built =
              (project['totalBuiltUpArea'] ??
                      project['total_built_up_area'] ??
                      '')
                  .toString()
                  .trim();

          if (plot.isNotEmpty && plot != '0' && plot != 'null' && plot != 'N/A')
            return '$plot sq.ft';
          if (built.isNotEmpty &&
              built != '0' &&
              built != 'null' &&
              built != 'N/A')
            return '$built sq.ft';
          return 'N/A';
        })();

        // 4. CODE
        final code =
            (project['projectCode'] ??
                    project['project_code'] ??
                    project['code'] ??
                    '')
                .toString()
                .trim();

        return {
          'id': project['projectId'] ?? project['project_id'] ?? 0,
          'psId': d['id'],
          'name': pName,
          'client': client['name'] ?? 'No Client',
          'location': (city.isNotEmpty && city != 'null') ? city : 'N/A',
          'address': (fullAddress.isNotEmpty && fullAddress != 'null')
              ? fullAddress
              : 'N/A',
          'area': area,
          'code': code.isNotEmpty ? code : '—',
          'pct': 0.0,
          'status': _normalizeStatus(
            (project['projectStatus'] ??
                    project['project_status'] ??
                    'PLANNING')
                .toString(),
          ),
          'team': ['YW'],
          'start': _formatDate(
            (project['projectStartDateTime'] ??
                    project['project_start_date_time'] ??
                    d['postSalesdateTime'])
                ?.toString(),
          ),
          'deadline': _formatDate(
            (project['projectExpectedEndDate'] ??
                    project['project_expected_end_date'])
                ?.toString(),
          ),
          'updates': 0,
          '_raw': project,
        };
      }).toList();

      try {
        mappedProjects.sort((a, b) {
          final idA = a['psId'] ?? a['id'] ?? 0;
          final idB = b['psId'] ?? b['id'] ?? 0;
          return (idB as int).compareTo(idA as int);
        });
      } catch (e) {
        debugPrint("SORT ERROR: $e");
      }

      debugPrint("MAPPED PROJECTS COUNT: ${mappedProjects.length}");

      if (mounted) {
        setState(() {
          _projects = mappedProjects;
          _isLoading = false;
          _currentPage = 0; // Reset to first page on new data fetch
        });

        // BACKGROUND SYNC: Fill in the "N/A" holes left by the shallow list API
        for (var p in mappedProjects) {
          if (p['location'] == 'N/A' || p['address'] == 'N/A') {
            // Slight delay between background calls to avoid overwhelming the server
            Future.delayed(
              Duration(milliseconds: 500 * mappedProjects.indexOf(p)),
              () {
                if (mounted && _detailId == null) {
                  _fetchFullProjectDetails(p['id'] as int, silent: true);
                }
              },
            );
          }
        }
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
        final date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
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

  bool get _isManager => [
    UserRole.admin,
    UserRole.coFounder,
    UserRole.hr,
  ].contains(widget.user.role);

  bool get canCreate => _isManager;

  List<Map<String, dynamic>> get _allFiltered {
    if (_filter == 'All') return _projects;
    return _projects.where((p) => p['status'] == _filter).toList();
  }

  List<Map<String, dynamic>> get _filtered {
    final all = _allFiltered;
    final start = _currentPage * _itemsPerPage;
    if (start >= all.length) return [];
    final end = (start + _itemsPerPage).clamp(0, all.length);
    return all.sublist(start, end);
  }

  int get _totalPages => (_allFiltered.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    if (_isEditing) return _buildEditScreen();
    if (_showCreateForm) return _buildCreateForm();
    if (_detailId != null) {
      return PostSaleDetailView(
        user: widget.user,
        projectId: _detailId!,
        onBack: () => setState(() => _detailId = null),
        onNavigateToSite: widget.onNavigateToSite,
        onEdit: (data) {
          setState(() {
            // Mapping the dynamic POST-SALE graph back to what the edit form expects
            final projectNode = data['project'] ?? {};
            final p = Map<String, dynamic>.from(projectNode);

            // Robustly extract the project ID to avoid int/null subtype crashes
            final rawId =
                projectNode['projectId'] ??
                projectNode['id'] ??
                projectNode['project_id'];
            p['id'] = rawId is int
                ? rawId
                : int.tryParse(rawId?.toString() ?? '0') ?? 0;
            p['client'] = data['client']?['name'] ?? 'Unknown';
            p['psId'] = data['id']; // PostSale record ID

            _selectedProject = p;
            _initEditForm(p);
            _isEditing = true;
          });
        },
      );
    }
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
            const Text(
              "Server Communication Error",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We couldn't retrieve the project details from the backend. This might be a temporary issue or an authentication timeout.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            GoldGradientButton(
              text: "Retry Connection",
              onTap: () {
                final pid =
                    _selectedProject?['projectId'] ?? _selectedProject?['id'];
                if (pid != null)
                  _fetchFullProjectDetails(
                    pid is int ? pid : int.parse(pid.toString()),
                  );
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

    final statusKey = (_editCtrls['projectStatus']?.text ?? 'PLANNING')
        .toUpperCase();
    final statusCfg =
        _STATUS_CONFIG[statusKey] ??
        _STATUS_CONFIG['PLANNING'] ??
        _STATUS_CONFIG.values.first;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
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
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _isEditing = false),
                icon: const Icon(Icons.close_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Editing Project",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _editCtrls['projectName']?.text ?? "Untitled",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (widget.user.role != UserRole.client)
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
              _statusChipSmall(
                _editCtrls['projectStatus']?.text ?? 'PLANNING',
                statusCfg,
              ),
              const SizedBox(width: 8),
              _chipSmall(
                '📍 ${_editCtrls['city']?.text}',
                AppColors.surfaceContainerLow,
              ),
              const SizedBox(width: 8),
              _chipSmall(
                'ID: ${_selectedProject?['psId'] ?? _selectedProject?['id'] ?? '—'}',
                AppColors.surfaceContainerLow,
              ),
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
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
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
                border: Border(
                  bottom: BorderSide(
                    color: active ? AppColors.primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    tabs[i]['icon'] as IconData,
                    size: 18,
                    color: active
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tabs[i]['label'] as String,
                    style: TextStyle(
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
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
        _editField(
          'PROJECT NAME',
          _editCtrls['projectName'] ?? TextEditingController(),
          "e.g. Adhya Ratan",
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _editField(
                'PROJECT CODE',
                _editCtrls['projectCode'] ?? TextEditingController(),
                "ABC-001",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _editField(
                'PERMANENT ID',
                _editCtrls['permanentProjectId'] ?? TextEditingController(),
                "P-2026-X",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _editField(
          'DESCRIPTION',
          _editCtrls['projectDetails'] ?? TextEditingController(),
          "Detailed project description...",
          lines: 3,
        ),
        const SizedBox(height: 24),
        const Text(
          "STATUS",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _buildEditStatusPicker(),
        const SizedBox(height: 24),
        const Text(
          "PRIORITY",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _buildEditPriorityPicker(),
      ],
    );
  }

  Widget _buildEditLocationTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _editField(
          'ADDRESS',
          _editCtrls['address'] ?? TextEditingController(),
          "Full project address",
          lines: 2,
        ),
        const SizedBox(height: 16),
        _editField(
          'CITY',
          _editCtrls['city'] ?? TextEditingController(),
          "e.g. Pune",
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _editField(
                'LATITUDE',
                _editCtrls['latitude'] ?? TextEditingController(),
                "18.5204",
                type: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _editField(
                'LONGITUDE',
                _editCtrls['longitude'] ?? TextEditingController(),
                "73.8567",
                type: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _editField(
          'GOOGLE MAPS LINK',
          _editCtrls['googlePlace'] ?? TextEditingController(),
          "Paste share link here",
          icon: Icons.map_outlined,
        ),
      ],
    );
  }

  Widget _buildEditAreaTab() {
    final plot = double.tryParse(_editCtrls['plotArea']?.text ?? '0') ?? 0;
    final built =
        double.tryParse(_editCtrls['totalBuiltUpArea']?.text ?? '0') ?? 0;
    final carpet =
        double.tryParse(_editCtrls['totalCarpetArea']?.text ?? '0') ?? 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: _editField(
                'PLOT AREA',
                _editCtrls['plotArea'] ?? TextEditingController(),
                "sq.ft",
                type: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _editField(
                'TOTAL BUILT-UP',
                _editCtrls['totalBuiltUpArea'] ?? TextEditingController(),
                "sq.ft",
                type: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _editField(
          'TOTAL CARPET AREA',
          _editCtrls['totalCarpetArea'] ?? TextEditingController(),
          "sq.ft",
          type: TextInputType.number,
        ),
        const SizedBox(height: 30),
        const Text(
          "AREA SUMMARY VISUALIZATION",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _buildAreaBar("Plot Area", plot, Colors.blue.shade100, Colors.blue),
        _buildAreaBar(
          "Built-up Area",
          built,
          Colors.orange.shade100,
          Colors.orange,
        ),
        _buildAreaBar(
          "Carpet Area",
          carpet,
          Colors.green.shade100,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildEditTimelineTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _editField(
          'CREATED AT',
          _editCtrls['projectCreatedDateTime'] ?? TextEditingController(),
          "Read-only",
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _editDateField(
          'PROJECT START DATE',
          _editCtrls['projectStartDateTime'] ?? TextEditingController(),
        ),
        const SizedBox(height: 16),
        _editDateField(
          'EXPECTED END DATE',
          _editCtrls['projectExpectedEndDate'] ?? TextEditingController(),
        ),
        const SizedBox(height: 16),
        _editDateField(
          'ACTUAL END DATE',
          _editCtrls['projectEndDateTime'] ?? TextEditingController(),
        ),
      ],
    );
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 512,
    );

    if (image != null) {
      setState(() => _isPickingLogo = true);
      final base64String = await Base64Utils.toDataUrl(image);
      setState(() {
        _pickedLogoBase64 = base64String;
        _isPickingLogo = false;
      });
      if (base64String != null) {
        widget.onToast("Logo prepared. Save to upload.");
      }
    }
  }

  Widget _buildEditLogoTab() {
    final currentLogo =
        _pickedLogoBase64 ??
        _selectedProject?['logoUrl'] ??
        _selectedProject?['logo_url'];

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: _pickedLogoBase64 != null ? 0.5 : 0.1,),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: _isPickingLogo
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _buildLogoPreview(
                        currentLogo,
                        name:
                            _editCtrls['projectName']?.text ??
                            _selectedProject?['name'],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Company Logo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _pickedLogoBase64 != null
                    ? "New logo selected. Click 'Save Changes' to update the database."
                    : "This logo is identifying the project across all reports and the client portal.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: Text(
                _pickedLogoBase64 != null ? "Change Selection" : "Select Logo",
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCreateLogo() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 512,
    );

    if (image != null) {
      setState(() => _isPickingLogo = true);
      final base64String = await Base64Utils.toDataUrl(image);
      setState(() {
        _createLogoBase64 = base64String;
        _isPickingLogo = false;
      });
      if (base64String != null) {
        widget.onToast("Logo added to project.");
      }
    }
  }

  Widget _buildLogoPreview(dynamic logo, {String? name}) {
    if (logo == null || logo.toString().isEmpty) {
      if (name != null && name.isNotEmpty) {
        return AvatarWidget(
          initials: name
              .split(' ')
              .map((s) => s.isNotEmpty ? s[0] : '')
              .take(2)
              .join()
              .toUpperCase(),
          size: 160, // This will be constrained by parent
          fontSize: 18,
        );
      }
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            size: 48,
            color: AppColors.outline,
          ),
          SizedBox(height: 8),
          Text(
            "Tap to Select",
            style: TextStyle(fontSize: 12, color: AppColors.outline),
          ),
        ],
      );
    }

    if (Base64Utils.isBase64(logo.toString())) {
      try {
        final base64String = logo.toString().split(',').last;
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _initialsFallback(name),
        );
      } catch (e) {
        return _initialsFallback(name);
      }
    }

    return Image.network(
      logo.toString(),
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) => _initialsFallback(name),
    );
  }

  Widget _initialsFallback(String? name) {
    return AvatarWidget(
      initials: name != null && name.isNotEmpty
          ? name
                .split(' ')
                .map((s) => s.isNotEmpty ? s[0] : '')
                .take(2)
                .join()
                .toUpperCase()
          : '?',
      size: 160,
      fontSize: 18,
    );
  }

  Widget _buildEditFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _isEditing = false),
              child: Text(
                widget.user.role == UserRole.client
                    ? "Back"
                    : "Discard Changes",
              ),
            ),
          ),
          if (widget.user.role != UserRole.client) ...[
            const SizedBox(width: 16),
            Expanded(
              child: GoldGradientButton(
                text: "Save Changes",
                onTap: _saveProjectChanges,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController ctrl,
    String hintText, {
    int lines = 1,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: lines,
          keyboardType: type,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            filled: readOnly,
            fillColor: readOnly ? AppColors.surfaceContainerLow : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _editDateField(String label, TextEditingController ctrl) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null)
          setState(() => ctrl.text = DateFormat('dd/MM/yyyy').format(date));
      },
      child: AbsorbPointer(
        child: _editField(
          label,
          ctrl,
          "Select date",
          icon: Icons.calendar_month_rounded,
        ),
      ),
    );
  }

  Widget _buildAreaBar(String label, double val, Color bg, Color bar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(
                '${val.toStringAsFixed(0)} sq.ft',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (val / 10000).clamp(0.0, 1.0),
              backgroundColor: bg,
              color: bar,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditStatusPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _STATUS_CONFIG.entries.map((e) {
        bool active = _editCtrls['projectStatus']?.text == e.key;
        return GestureDetector(
          onTap: () =>
              setState(() => _editCtrls['projectStatus']?.text = e.key),
          child: _statusChipSmall(e.key, e.value, active: active),
        );
      }).toList(),
    );
  }

  Widget _buildEditPriorityPicker() {
    final priorities = {
      'HIGH': {
        'label': 'High',
        'bg': const Color(0xFFFEF2F2),
        'fg': const Color(0xFF991B1B),
      },
      'MEDIUM': {
        'label': 'Medium',
        'bg': const Color(0xFFFEF9C3),
        'fg': const Color(0xFF854D0E),
      },
      'LOW': {
        'label': 'Low',
        'bg': const Color(0xFFEFF6FF),
        'fg': const Color(0xFF1E40AF),
      },
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
              border: Border.all(
                color: active
                    ? (e.value['fg'] as Color)
                    : AppColors.outlineVariant,
              ),
            ),
            child: Text(
              e.value['label'] as String,
              style: TextStyle(
                color: active
                    ? (e.value['fg'] as Color)
                    : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statusChipSmall(
    String key,
    Map<String, dynamic> cfg, {
    bool active = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? cfg['bg'] : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? cfg['dot'] : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: cfg['dot'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            cfg['label'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: active ? cfg['color'] : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipSmall(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  final Map<String, Map<String, dynamic>> _STATUS_CONFIG = {
    'PLANNING': {
      'label': 'Planning',
      'bg': const Color(0xFFE0F2FE),
      'color': const Color(0xFF0369A1),
      'dot': const Color(0xFF0284C7),
    },
    'IN_PROGRESS': {
      'label': 'In Progress',
      'bg': const Color(0xFFFEF9C3),
      'color': const Color(0xFF854D0E),
      'dot': const Color(0xFFCA8A04),
    },
    'COMPLETED': {
      'label': 'Completed',
      'bg': const Color(0xFFDCFCE7),
      'color': const Color(0xFF166534),
      'dot': const Color(0xFF16A34A),
    },
    'ON_HOLD': {
      'label': 'On Hold',
      'bg': const Color(0xFFF3F4F6),
      'color': const Color(0xFF374151),
      'dot': const Color(0xFF6B7280),
    },
    'REVIEW': {
      'label': 'In Review',
      'bg': const Color(0xFFF3E8FF),
      'color': const Color(0xFF6B21A8),
      'dot': const Color(0xFF9333EA),
    },
  };

  Widget _buildList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Projects',
              subtitle: '${_projects.length} active engagements',
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              Column(
                children: const [
                  ProjectCardSkeleton(),
                  ProjectCardSkeleton(),
                  ProjectCardSkeleton(),
                ],
              )
            else if (_filtered.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: Text(
                    "No projects found",
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              )
            else
              ..._filtered.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _detailId = p['id'] as int);
                      _fetchFullProjectDetails(p['id'] as int, silent: true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16.w),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.15,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16.w,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: [
                          ProgressBar(percent: p['pct'] as double, height: 5.h),
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48.w,
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(
                                          12.w,
                                        ),
                                      ),
                                      margin: EdgeInsets.only(right: 16.w),
                                      clipBehavior: Clip.hardEdge,
                                      child: _buildLogoPreview(
                                        p['_raw']?['logoUrl'] ??
                                            p['_raw']?['logo_url'],
                                        name: p['name'] as String?,
                                      ),
                                    ),
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
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                p['location'] as String,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors
                                                      .onSurfaceVariant,
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
                                SizedBox(height: 14.h),
                                Row(
                                  children: [
                                    _infoBox(
                                      'Code',
                                      p['code'] as String? ?? '—',
                                    ),
                                    SizedBox(width: 8.w),
                                    _infoBox(
                                      'Area',
                                      p['area'] as String? ?? 'N/A',
                                    ),
                                    SizedBox(width: 8.w),
                                    _infoBox('Updates', '${p['updates']}'),
                                  ],
                                ),
                                SizedBox(height: 14.h),
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  runSpacing: 8,
                                  children: [
                                    Wrap(
                                      children: (p['team'] as List<dynamic>)
                                          .map<Widget>(
                                            (m) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 4,
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
                                      mainAxisSize: MainAxisSize.min,
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
            if (!_isLoading && _allFiltered.isNotEmpty)
              _buildPagination(),
            if (canCreate)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: GoldGradientButton(
                  text: 'Create New Project',
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _showCreateForm = true),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final total = _allFiltered.length;
    final totalPages = _totalPages;
    if (totalPages <= 1) return const SizedBox.shrink();

    final startItem = (_currentPage * _itemsPerPage) + 1;
    final endItem = (startItem + _filtered.length - 1).clamp(0, total);

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing $startItem-$endItem of $total",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                "Page ${_currentPage + 1} of $totalPages",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pageNavBtn(
                icon: Icons.chevron_left_rounded,
                enabled: _currentPage > 0,
                onTap: () => setState(() => _currentPage--),
              ),
              SizedBox(width: 12.w),
              // Simplified page dots/numbers for premium feel
              ...List.generate(totalPages, (index) {
                // Show at most 5 page numbers, or ellipses
                if (totalPages > 5) {
                  if (index != 0 &&
                      index != totalPages - 1 &&
                      (index < _currentPage - 1 || index > _currentPage + 1)) {
                    if (index == 1 || index == totalPages - 2) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          "...",
                          style: TextStyle(color: AppColors.outline),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                }

                final isActive = index == _currentPage;
                return GestureDetector(
                  onTap: () => setState(() => _currentPage = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: isActive ? 36.w : 32.w,
                    height: isActive ? 36.w : 32.w,
                    decoration: BoxDecoration(
                      gradient: isActive ? goldGradient : null,
                      color: isActive ? null : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10.w),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF755B00).withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 8.w,
                                offset: Offset(0, 4.h),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w600,
                          color: isActive ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(width: 12.w),
              _pageNavBtn(
                icon: Icons.chevron_right_rounded,
                enabled: _currentPage < totalPages - 1,
                onTap: () => setState(() => _currentPage++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageNavBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : AppColors.outline,
            size: 20.w,
          ),
        ),
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
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
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
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickCreateLogo,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: _createLogoBase64 != null ? 0.5 : 0.1,),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: _isPickingLogo
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _createLogoBase64 != null
                  ? Image.memory(
                      base64Decode(_createLogoBase64!.split(',').last),
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'New Project',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (_createLogoBase64 != null)
                      IconButton(
                        onPressed: () =>
                            setState(() => _createLogoBase64 = null),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
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
                      color: AppColors.primary.withValues(alpha: 0.08),
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
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            AvatarWidget(
              initials: _selectedClient!.name.isNotEmpty
                  ? _selectedClient!.name[0].toUpperCase()
                  : '?',
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
                    '${_selectedClient!.email} · ${_selectedClient!.phone}',
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
                  c.phone.contains(textEditingValue.text);
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
                          initials: c.name.isNotEmpty
                              ? c.name[0].toUpperCase()
                              : '?',
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
                          c.email,
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          c.phone,
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
        MediaQuery.of(context).size.width < 800
            ? Column(
                children: [
                  _formField(
                    'EMAIL *',
                    _clientEmailController,
                    'Enter email address',
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _formField(
                    'PHONE *',
                    _clientPhoneController,
                    'Enter phone number',
                    type: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              )
            : Row(
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
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
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
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: placeholder,
            counterText: '',
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
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
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
                  activeThumbColor: AppColors.primary,
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
                Icons.notes_rounded,
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
      'project': {'logoUrl': _createLogoBase64},
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

    List<int>? logoBytes;
    if (_createLogoBase64 != null) {
      try {
        logoBytes = base64Decode(_createLogoBase64!.split(',').last);
      } catch (e) {
        debugPrint("Error decoding create logo bytes: $e");
      }
    }

    try {
      final res = await PostSalesService.createPostSale(
        payload: payload,
        isOldClient: !_isNewClient,
        logoBytes: logoBytes,
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
