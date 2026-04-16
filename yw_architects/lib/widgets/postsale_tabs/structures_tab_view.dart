import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yw_architects/models/site_model.dart';
import 'package:yw_architects/models/app_models.dart';
import 'package:yw_architects/theme/app_theme.dart';
import 'package:yw_architects/screens/sections/sites/add_structure_screen.dart';

class StructuresTabView extends StatefulWidget {
  final int projectId;
  final List<SiteStructure> structures;
  final AppUser user;
  final VoidCallback? onRefresh;

  const StructuresTabView({
    super.key,
    required this.projectId,
    required this.structures,
    required this.user,
    this.onRefresh,
  });

  @override
  State<StructuresTabView> createState() => _StructuresTabViewState();
}

class _StructuresTabViewState extends State<StructuresTabView> {
  int _selectedStructIdx = 0;
  int? _hoveredLevelIdx;
  int? _activeLevelIdx;

  SiteStructure? get _selectedStructure =>
      widget.structures.isNotEmpty ? widget.structures[_selectedStructIdx] : null;

  @override
  Widget build(BuildContext context) {
    bool canAdd = [UserRole.admin, UserRole.coFounder, UserRole.liaisonManager].contains(widget.user.role);

    if (widget.structures.isEmpty) {
      return _buildEmptyState(canAdd);
    }

    final struct = _selectedStructure!;
    final levels = struct.levels;

    // Sort levels exactly like web app
    final sortedLevels = [...levels]..sort((a, b) => _getLevelOrder(a.levelType).compareTo(_getLevelOrder(b.levelType)));
    final reversedLevels = sortedLevels.reversed.toList();

    return Column(
      children: [
        // 0. Header with Add Button
        _buildHeader(canAdd),

        // 1. Structure Selector (if > 1)
        if (widget.structures.length > 1) _buildStructureSelector(),

        // 2. Main Content
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              
              if (isSmall) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Viz at top
                      Container(
                        height: 300,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: _buildBuildingViz(reversedLevels, sortedLevels),
                      ),
                      // Details below
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildDetailPanel(sortedLevels),
                      ),
                    ],
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Building Viz
                  Expanded(
                    flex: 4,
                    child: _buildBuildingViz(reversedLevels, sortedLevels),
                  ),

                  // Sidebar Divider
                  Container(width: 1, color: Colors.grey[200]),

                  // Right: Detail Panel
                  Expanded(
                    flex: 5,
                    child: _buildDetailPanel(sortedLevels),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStructureSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.structures.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = widget.structures[index];
          final isSelected = _selectedStructIdx == index;
          return ChoiceChip(
            label: Text(s.structureName),
            selected: isSelected,
            onSelected: (val) {
              if (val) setState(() {
                _selectedStructIdx = index;
                _activeLevelIdx = null;
              });
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.1),
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            backgroundColor: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBuildingViz(List<SiteLevel> reversedLevels, List<SiteLevel> sortedLevels) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Icon(Icons.architecture_rounded, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "CROSS-SECTION",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        // Building List
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: reversedLevels.length + 1, // + Foundation
              itemBuilder: (context, index) {
                if (index == reversedLevels.length) {
                  return _buildFoundation();
                }

                final lv = reversedLevels[index];
                final originalIdx = sortedLevels.indexOf(lv);
                final isHov = _hoveredLevelIdx == originalIdx;
                final isAct = _activeLevelIdx == originalIdx;

                return _buildFloorWidget(lv, originalIdx, isHov, isAct);
              },
            ),
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  Widget _buildFloorWidget(SiteLevel lv, int idx, bool isHov, bool isAct) {
    final meta = _getLevelMeta(lv.levelType);
    final isBase = lv.levelType == 'BASEMENT';
    final isTerrace = lv.levelType == 'TERRACE';

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredLevelIdx = idx),
      onExit: (_) => setState(() => _hoveredLevelIdx = null),
      child: GestureDetector(
        onTap: () => setState(() => _activeLevelIdx = idx),
        child: Container(
          height: isTerrace ? 40 : 50,
          margin: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              // Left Label
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lv.levelLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: (isHov || isAct) ? FontWeight.w800 : FontWeight.w600,
                        color: (isHov || isAct) ? meta.color : Colors.grey[600],
                      ),
                    ),
                    if (lv.floorHeight != null)
                      Text(
                        "${lv.floorHeight}m",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          color: Colors.grey[400],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // THE BUILDING PART (3D-ish Face)
              Expanded(
                flex: 5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: (isHov || isAct) ? meta.bg : Colors.white,
                    border: Border.all(
                      color: (isHov || isAct) ? meta.color : Colors.grey[300]!,
                      width: (isHov || isAct) ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      // Top slab
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 4,
                        child: Container(color: meta.color),
                      ),

                      // Windows (if typical)
                      if (!isBase && !isTerrace)
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int i = 0; i < 3; i++)
                                Container(
                                  width: 10,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: (isHov || isAct) ? meta.color.withValues(alpha: 0.2) : Colors.blue[50],
                                    border: Border.all(color: (isHov || isAct) ? meta.color.withValues(alpha: 0.5) : Colors.blue[100]!),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Progress fill at bottom
                      if (lv.progressPercentage > 0)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 3,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: lv.progressPercentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: meta.color,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(2)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Right Legend/Indicator
              if (isHov || isAct)
                const Icon(Icons.arrow_left_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoundation() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
           Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            top: 16,
            child: Text(
              "FOUNDATION SLAB",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.grey[500],
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(List<SiteLevel> sortedLevels) {
    if (_activeLevelIdx == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "Select a level to view details",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final lv = sortedLevels[_activeLevelIdx!];
    final meta = _getLevelMeta(lv.levelType);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: meta.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: meta.color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: meta.color.withValues(alpha: 0.2), blurRadius: 10)
                    ],
                  ),
                  child: Text(
                    meta.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lv.levelLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        lv.levelType.replaceAll('_', ' '),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: meta.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats Grid
          Builder(
            builder: (context) {
              final isNarrow = MediaQuery.of(context).size.width < 400;
              return GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isNarrow ? 1 : 2,
                  childAspectRatio: isNarrow ? 4 : 2.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                children: [
                  _buildInfoTile("Usage Type", lv.usageType, Icons.category_outlined),
                  _buildInfoTile("Built-up Area", lv.builtUpArea != null ? "${lv.builtUpArea} sq.ft" : "N/A", Icons.architecture),
                  _buildInfoTile("Carpet Area", lv.carpetArea != null ? "${lv.carpetArea} sq.ft" : "N/A", Icons.layers_outlined),
                  _buildInfoTile("Floor Height", lv.floorHeight != null ? "${lv.floorHeight} m" : "N/A", Icons.vertical_align_center),
                ],
              );
            }
          ),

          const SizedBox(height: 24),

          // Progress
          Text(
            "CONSTRUCTION PROGRESS",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: lv.progressPercentage / 100,
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation(meta.color),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${lv.progressPercentage.toInt()}%",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: meta.color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Status: ${lv.constructionStatus ?? 'Planning'}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[100]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey[500]),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool canAdd) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Project Structures",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          if (canAdd)
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddStructureScreen(
                    projectId: widget.projectId,
                    user: widget.user,
                    onStructureAdded: () => widget.onRefresh?.call(),
                  ),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Add Structure"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool canAdd) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            "No Structure data available",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          if (canAdd) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddStructureScreen(
                    projectId: widget.projectId,
                    user: widget.user,
                    onStructureAdded: () => widget.onRefresh?.call(),
                  ),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text("Add First Structure"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // HELPER HELPERS
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildLegendItem("BASEMENT", const Color(0xFF6366f1)),
          _buildLegendItem("GROUND", const Color(0xFF10b981)),
          _buildLegendItem("TYPICAL", const Color(0xFF3b82f6)),
          _buildLegendItem("TERRACE", const Color(0xFF7c5e0b)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _getLevelOrder(String type) {
    const order = [
      "BASEMENT",
      "STILT",
      "GROUND_FLOOR",
      "PODIUM",
      "TYPICAL_FLOOR",
      "REFUGE_FLOOR",
      "SERVICE_FLOOR",
      "AMENITY_FLOOR",
      "TERRACE",
    ];
    final idx = order.indexOf(type);
    return idx == -1 ? 4 : idx; // Default to typical floor
  }

  _LevelMeta _getLevelMeta(String type) {
    switch (type) {
      case 'BASEMENT':
        return _LevelMeta(color: const Color(0xFF6366f1), bg: const Color(0xFFF0F1FF), icon: "🅱");
      case 'STILT':
        return _LevelMeta(color: const Color(0xFF8b5cf6), bg: const Color(0xFFF5F3FF), icon: "⊟");
      case 'GROUND_FLOOR':
        return _LevelMeta(color: const Color(0xFF10b981), bg: const Color(0xFFECFDF5), icon: "G");
      case 'PODIUM':
        return _LevelMeta(color: const Color(0xFFf59e0b), bg: const Color(0xFFFFFBEB), icon: "P");
      case 'REFUGE_FLOOR':
        return _LevelMeta(color: const Color(0xFFef4444), bg: const Color(0xFFFEF2F2), icon: "R");
      case 'SERVICE_FLOOR':
        return _LevelMeta(color: const Color(0xFFec4899), bg: const Color(0xFFFDF2F8), icon: "S");
      case 'AMENITY_FLOOR':
        return _LevelMeta(color: const Color(0xFF14b8a6), bg: const Color(0xFFF0FDFA), icon: "A");
      case 'TERRACE':
        return _LevelMeta(color: const Color(0xFF7c5e0b), bg: const Color(0xFFFEFCE8), icon: "T");
      default:
        return _LevelMeta(color: const Color(0xFF3b82f6), bg: const Color(0xFFEFF6FF), icon: "⊞");
    }
  }
}

class _LevelMeta {
  final Color color;
  final Color bg;
  final String icon;
  _LevelMeta({required this.color, required this.bg, required this.icon});
}
