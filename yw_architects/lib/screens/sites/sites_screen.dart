import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../models/site_model.dart';
import '../../services/site_service.dart';
import '../sections/sites/site_list_section.dart';
import '../sections/sites/site_details_section.dart';
import '../sections/sites/site_form_section.dart';

class SitesScreen extends StatefulWidget {
  final AppUser user;
  final Function(String) onToast;
  final Function(int) onEditProject;

  const SitesScreen({
    super.key,
    required this.user,
    required this.onToast,
    required this.onEditProject,
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
    final data = await SiteService.getSites();
    if (mounted) {
      setState(() {
        _sites = data;
        
        _isLoading = false;
      });
    }
  }

  List<Site> get _filteredSites {
    if (_activeFilter == 'All') return _sites;
    return _sites.where((s) => s.status.toUpperCase() == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSite != null) {
      return SiteDetailsSection(
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

    return Column(
      children: [
        SiteListSection(
          sites: _filteredSites,
          isLoading: _isLoading,
          activeFilter: _activeFilter,
          onFilterChange: (filter) => setState(() => _activeFilter = filter),
          onSiteTap: (site) => setState(() => _selectedSite = site),
          onAddSite: () => setState(() => _showForm = true),
        ),
      ],
    );
  }
}
