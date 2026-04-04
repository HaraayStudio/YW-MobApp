import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import '../../services/project_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    try {
      final data = await ProjectService.getAllProjects();
      setState(() {
        _projects = data.map((d) {
          return {
            'id': d['projectId'] ?? 0,
            'name': d['projectName'] ?? 'Unknown Project',
            'client': d['projectCode'] ?? 'No Code', // using code as placeholder for list
            'location': 'N/A', // Not in Lite DTO
            'area': 'N/A', // Not in Lite DTO
            'type': 'Architectural',
            'pct': 0.0,
            'status': d['projectStatus'] ?? 'Planning',
            'budget': 'N/A',
            'team': ['YW'],
            'start': _formatDate(d['projectStartDateTime']),
            'deadline': _formatDate(d['projectExpectedEndDate']),
            'updates': 0,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onToast("Failed to load projects");
      }
    }
  }

  String _formatDate(String? dt) {
    if (dt == null || dt.isEmpty) return 'TBA';
    try {
      final date = DateTime.parse(dt);
      return '${date.day}-${date.month}-${date.year}';
    } catch (_) {
      return 'TBA';
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
    if (_detailId != null) return _buildDetail(_detailId!);
    return _buildList();
  }

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
            const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_filtered.isEmpty)
             const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text("No projects found", style: TextStyle(color: AppColors.onSurfaceVariant))))
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
                                          Text(
                                            p['name'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              onTap: () => widget.onToast('Project creation form opened!'),
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
}

