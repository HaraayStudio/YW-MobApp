import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/site_model.dart';
import '../../../models/app_models.dart';
import '../../../theme/app_theme.dart';
import '../../../services/structure_service.dart';
import '../../../widgets/postsale_tabs/structures_tab_view.dart';

class AddStructureScreen extends StatefulWidget {
  final int projectId;
  final AppUser user;
  final VoidCallback onStructureAdded;

  const AddStructureScreen({
    super.key,
    required this.projectId,
    required this.user,
    required this.onStructureAdded,
  });

  @override
  State<AddStructureScreen> createState() => _AddStructureScreenState();
}

class _AddStructureScreenState extends State<AddStructureScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _structureFormKey = GlobalKey<FormState>();
  final _levelFormKey = GlobalKey<FormState>();

  // Structure Data
  String _structureName = "";
  String _structureType = "";
  String _usageType = "";
  double? _builtUpArea;
  int? _totalFloors;
  int? _totalBasements;

  // Levels Data
  final List<SiteLevel> _addedLevels = [];
  
  // Current Level Form State
  String _levelLabel = "";
  int _levelNumber = 0;
  String _levelType = "";
  String _levelUsageType = "MIXED";
  double? _levelBuiltUpArea;
  double? _levelCarpetArea;
  double? _levelHeight = 3.0; // Default
  String? _constructionStatus;
  double _progressPercentage = 0;

  bool _isSaving = false;

  final List<String> _structureTypes = [
    "TOWER", "WING", "BUILDING", "ROW_HOUSE", "BUNGALOW", "PODIUM_BLOCK"
  ];
  final List<String> _usageTypes = [
    "RESIDENTIAL", "COMMERCIAL", "PARKING", "SERVICES", "MIXED"
  ];
  final List<String> _levelTypes = [
    "BASEMENT", "STILT", "GROUND_FLOOR", "PODIUM", "TYPICAL_FLOOR",
    "REFUGE_FLOOR", "SERVICE_FLOOR", "AMENITY_FLOOR", "TERRACE"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveStructure() async {
    if (_structureName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a structure name")),
      );
      _tabController.animateTo(0);
      return;
    }

    if (_addedLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one level")),
      );
      _tabController.animateTo(1);
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      'structureName': _structureName,
      'structureType': _structureType,
      'usageType': _usageType,
      'totalFloors': _totalFloors,
      'totalBasements': _totalBasements,
      'builtUpArea': _builtUpArea,
      'levels': _addedLevels.map((l) => l.toJson()).toList(),
    };

    final success = await StructureService.createStructure(widget.projectId, payload);
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        widget.onStructureAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Structure created successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create structure")),
        );
      }
    }
  }

  void _addLevel() {
    if (_levelFormKey.currentState!.validate()) {
      _levelFormKey.currentState!.save();
      setState(() {
        _addedLevels.add(SiteLevel(
          id: DateTime.now().millisecondsSinceEpoch,
          levelLabel: _levelLabel,
          levelNumber: _levelNumber,
          levelType: _levelType,
          usageType: _levelUsageType,
          builtUpArea: _levelBuiltUpArea,
          carpetArea: _levelCarpetArea,
          floorHeight: _levelHeight,
          constructionStatus: _constructionStatus,
          progressPercentage: _progressPercentage,
        ));
        // Reset level form
        _levelLabel = "";
        _levelFormKey.currentState!.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Structure",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveStructure,
                icon: _isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(_isSaving ? "Saving..." : "Save Structure"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Header (as seen in screenshot)
          _buildHeroHeader(),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.info_outline, size: 18), SizedBox(width: 8), Text("Structure Info")])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.layers_outlined, size: 18), SizedBox(width: 8), Text("Add Level")])),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStructureInfoTab(),
                _buildAddLevelTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _structureName.isNotEmpty ? _structureName[0].toUpperCase() : "S",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _structureName.isNotEmpty ? _structureName : "New Structure",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${_addedLevels.length} Levels Added",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructureInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _structureFormKey,
        child: Column(
          children: [
            _buildCard(
              title: "Basic Details",
              icon: Icons.info_outline,
              child: Column(
                children: [
                  _buildTextField(
                    label: "STRUCTURE NAME",
                    placeholder: "e.g. Wing A, Tower 1",
                    onChanged: (val) => setState(() => _structureName = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: "STRUCTURE TYPE",
                          value: _structureType.isEmpty ? null : _structureType,
                          items: _structureTypes,
                          onChanged: (val) => setState(() => _structureType = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          label: "USAGE TYPE",
                          value: _usageType.isEmpty ? null : _usageType,
                          items: _usageTypes,
                          onChanged: (val) => setState(() => _usageType = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: "BUILT-UP AREA (SQ.FT)",
                    placeholder: "0.00",
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _builtUpArea = double.tryParse(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: "Floor Configuration",
              icon: Icons.grid_view,
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: "TOTAL FLOORS",
                      placeholder: "e.g. 15",
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _totalFloors = int.tryParse(val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: "TOTAL BASEMENTS",
                      placeholder: "e.g. 2",
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _totalBasements = int.tryParse(val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Continue → Add Levels",
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddLevelTab() {
    return Row(
      children: [
        // Left: Form
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCard(
                  title: "Add New Level",
                  icon: Icons.add_circle_outline,
                  child: Form(
                    key: _levelFormKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(label: "LEVEL LABEL", placeholder: "e.g. B1, Ground", onChanged: (v) => _levelLabel = v)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(label: "LEVEL NUMBER", placeholder: "0, 1, 2...", keyboardType: TextInputType.number, onChanged: (v) => _levelNumber = int.tryParse(v) ?? 0)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDropdown(label: "LEVEL TYPE", value: _levelType.isEmpty ? null : _levelType, items: _levelTypes, onChanged: (v) => setState(() => _levelType = v!))),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDropdown(label: "USAGE TYPE", value: _levelUsageType, items: _usageTypes, onChanged: (v) => _levelUsageType = v!)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(label: "BUILT-UP AREA", placeholder: "0.00", keyboardType: TextInputType.number, onChanged: (v) => _levelBuiltUpArea = double.tryParse(v))),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(label: "CARPET AREA", placeholder: "0.00", keyboardType: TextInputType.number, onChanged: (v) => _levelCarpetArea = double.tryParse(v))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(label: "FLOOR HEIGHT (M)", placeholder: "3.00", keyboardType: TextInputType.number, onChanged: (v) => _levelHeight = double.tryParse(v))),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(label: "STATUS", placeholder: "In Progress", onChanged: (v) => _constructionStatus = v)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("PROGRESS — ${_progressPercentage.toInt()}%", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[600])),
                            Slider(
                              value: _progressPercentage,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _progressPercentage = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addLevel,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text("+ Add Level to Building", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_addedLevels.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Added Levels",
                    icon: Icons.list,
                    child: Column(
                      children: _addedLevels.reversed.map((lv) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(lv.levelLabel[0], style: TextStyle(fontSize: 12, color: AppColors.primary))),
                        title: Text(lv.levelLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text(lv.levelType),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => setState(() => _addedLevels.remove(lv))),
                      )).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Right: Visualization Preview (adapted for creating state)
        if (MediaQuery.of(context).size.width > 600)
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: _addedLevels.isEmpty 
                ? Center(child: Text("Levels will appear here", style: TextStyle(color: Colors.grey[400])))
                : StructuresTabView(
                    projectId: widget.projectId,
                    structures: [
                      SiteStructure(
                        id: 0,
                        structureName: _structureName.isEmpty ? "Preview" : _structureName,
                        structureType: _structureType,
                        usageType: _usageType,
                        levels: _addedLevels,
                      ),
                    ],
                    user: widget.user,
                  ),
            ),
          ),
      ],
    );
  }

  // --- UI Helpers ---

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String placeholder, ValueChanged<String>? onChanged, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[300], fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text("Select", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              isExpanded: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
              onChanged: onChanged,
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val.replaceAll('_', ' ')),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

