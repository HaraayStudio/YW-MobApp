import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

class DashboardSharedLayout extends StatelessWidget {
  final AppUser user;
  final String greetingRole;
  final Function(String) onNavigate;
  final List<Map<String, dynamic>> stats;
  final List<Map<String, dynamic>> quickActions;
  final bool showProjects;
  final bool showTasks;

  const DashboardSharedLayout({
    super.key,
    required this.user,
    required this.greetingRole,
    required this.onNavigate,
    required this.stats,
    required this.quickActions,
    this.showProjects = false,
    this.showTasks = true,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final projects = [
      {'name': 'Sunrise Villa', 'client': 'Mr. Kapoor', 'pct': 0.68, 'status': 'In Progress', 'members': ['RK', 'PS', 'AJ']},
      {'name': 'Metro Office Complex', 'client': 'City Corp Ltd', 'pct': 0.35, 'status': 'Planning', 'members': ['SA', 'VR']},
      {'name': 'Green Residency', 'client': 'Patel Family', 'pct': 0.90, 'status': 'Review', 'members': ['MK', 'RD', 'SP']},
    ];
    final tasks = [
      {'title': 'Review ground floor plan for Sunrise Villa', 'priority': 'high', 'done': false, 'time': '10:00 AM'},
      {'title': 'Site visit documentation \u2014 Green Residency', 'priority': 'medium', 'done': false, 'time': '2:00 PM'},
      {'title': 'Client call \u2014 Metro Office brief', 'priority': 'low', 'done': true, 'time': '9:00 AM'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Good Morning, $greetingRole \uD83D\uDC4B',
            subtitle: _todayDate(),
          ),
          const SizedBox(height: 24),

          // Stats
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final s = stats[i];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(s['icon'] as IconData, color: s['error'] == true ? AppColors.error : AppColors.primary, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        s['label'] as String,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['val'] as String,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: s['error'] == true ? AppColors.error : AppColors.primary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          if (showProjects) ...[
            _SectionTitle(title: 'Active Projects', btnText: 'View all', onTap: () => onNavigate('projects')),
            const SizedBox(height: 12),
            ...projects.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CardContainer(
                    onTap: () => onNavigate('projects'),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface)),
                                  Text(p['client'] as String, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            StatusChip(status: p['status'] as String),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ProgressBar(percent: p['pct'] as double),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: (p['members'] as List<String>)
                                  .map((m) => Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: AvatarWidget(initials: m, size: 28, fontSize: 9),
                                      ))
                                  .toList(),
                            ),
                            Text('${((p['pct'] as double) * 100).toInt()}% done', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],

          if (showTasks) ...[
            _SectionTitle(title: "Today's Tasks", btnText: 'View all', onTap: () => onNavigate('tasks')),
            const SizedBox(height: 12),
            ...tasks.map((t) {
              final priority = t['priority'] as String;
              final done = t['done'] as bool;
              Color leftColor = priority == 'high' ? AppColors.error : priority == 'medium' ? AppColors.chipProgressFg : AppColors.chipDoneFg;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: leftColor, width: 3)),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? AppColors.primary : Colors.transparent,
                        border: Border.all(color: done ? AppColors.primary : AppColors.outlineVariant, width: 2),
                      ),
                      child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 12) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['title'] as String,
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface,
                              decoration: done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(t['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    GoldChip(
                      text: priority.toUpperCase(),
                      bg: priority == 'high' ? AppColors.chipProgressBg : priority == 'medium' ? AppColors.chipPlanningBg : AppColors.chipDoneBg,
                      fg: priority == 'high' ? AppColors.chipProgressFg : priority == 'medium' ? AppColors.chipPlanningFg : AppColors.chipDoneFg,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Quick Actions
          const Text('Quick Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 12),
          Row(
            children: quickActions.map((a) => Expanded(
                  child: GestureDetector(
                    onTap: () => onNavigate(a['section'] as String),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
                      ),
                      child: Column(
                        children: [
                          Icon(a['icon'] as IconData, color: AppColors.primary, size: 24),
                          const SizedBox(height: 8),
                          Text(
                            a['label'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String btnText;
  final VoidCallback onTap;
  const _SectionTitle({required this.title, required this.btnText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(btnText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
