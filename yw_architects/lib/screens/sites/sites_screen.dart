import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../models/site_model.dart';
import '../../services/site_service.dart';
import '../sections/sites/site_list_section.dart';
import '../sections/sites/site_details_section.dart';
import '../sections/sites/site_form_section.dart';
import '../../services/post_sales_service.dart';

class SitesScreen extends StatefulWidget {
  final AppUser user;
  final Function(String) onToast;
  final Function(int) onEditProject;
  final int? initialProjectId; // when set, auto-open the site for this project

  const SitesScreen({
    super.key,
    required this.user,
    required this.onToast,
    required this.onEditProject,
    this.initialProjectId,
  });

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  List<Site> _sites = [];
  bool _isLoading = true;
  String _activeFilter = 'All';
  Site? _selectedSite;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _fetchSites();
  }

  Future<void> _fetchSites() async {
    setState(() => _isLoading = true);

    List<Site> _fetchedSites = [];
    
    if (widget.user.role == UserRole.client) {
      // For clients, use the specific postsales client endpoint
      final postSales = await PostSalesService.getPostSalesByClient(widget.user.id);
      
      _fetchedSites = postSales.map((ps) {
        // The backend returns PostSales objects, each containing a nested 'project' and 'client'
        final projectData = Map<String, dynamic>.from(ps['project'] ?? {});
        projectData['postSalesId'] = ps['id'];
        projectData['client'] = ps['client']; // inject client metadata if Site model needs it
        return Site.fromJson(projectData);
      }).toList();
    } else {
      // For employees/admins, use the global projects API
      _fetchedSites = await SiteService.getSites();
    }

    if (mounted) {
      setState(() {
        _sites = _fetchedSites;
        _isLoading = false;
      });
      // If a specific project was requested, auto-open its site
      if (widget.initialProjectId != null) {
        final target = _sites.firstWhere(
          (s) => s.projectId == widget.initialProjectId,
          orElse: () => _sites.isEmpty ? _sites.first : _sites.first,
        );
        // Only auto-navigate if we found a real match
        if (_sites.any((s) => s.projectId == widget.initialProjectId)) {
          setState(() => _selectedSite = target);
        }
      }
    }
  }

  bool get _isManager => [
    UserRole.admin,
    UserRole.coFounder,
    UserRole.hr
  ].contains(widget.user.role);

  List<Site> get _filteredSites {
    List<Site> filtered = _sites;
    

    if (_activeFilter == 'All') return filtered;
    return filtered
        .where((s) => s.status.toUpperCase() == _activeFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSite != null) {
      return SiteDetailsSection(
        user: widget.user,
        site: _selectedSite!,
        onBack: () => setState(() => _selectedSite = null),
        onEditProject: widget.onEditProject,
      );
    }

    if (_showForm) {
      return SiteFormSection(
        onCancel: () => setState(() => _showForm = false),
        onSubmit: (data) async {
          final success = await SiteService.createSite(data);
          if (success) {
            widget.onToast("Site created successfully!");
            setState(() => _showForm = false);
            _fetchSites();
          } else {
            widget.onToast("Failed to create site.");
          }
        },
      );
    }

    return SiteListSection(
      sites: _filteredSites,
      isLoading: _isLoading,
      activeFilter: _activeFilter,
      onFilterChange: (filter) => setState(() => _activeFilter = filter),
      onSiteTap: (site) => setState(() => _selectedSite = site),
      onAddSite: _isManager ? () => setState(() => _showForm = true) : null,
    );
  }
}
