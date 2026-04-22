import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

// ─────────────────────────────────────────────────────────────
//  DashboardSharedLayout
//  Used by every role-specific dashboard section.
//  Pixel-safe: no fixed heights on text, no unbounded Row children.
// ─────────────────────────────────────────────────────────────
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
    this.showProjects = true,
    this.showTasks = true,
  });

  // ── Sample data ──────────────────────────────────────────────────────────
  static final _projects = [
    {
      'name': 'Sunrise Villa',
      'client': 'Mr. Kapoor',
      'pct': 0.68,
      'status': 'In Progress',
      'members': ['RK', 'PS', 'AJ'],
    },
    {
      'name': 'Metro Office Complex',
      'client': 'City Corp Ltd',
      'pct': 0.35,
      'status': 'Planning',
      'members': ['SA', 'VR'],
    },
    {
      'name': 'Green Residency',
      'client': 'Patel Family',
      'pct': 0.90,
      'status': 'Review',
      'members': ['MK', 'RD'],
    },
  ];

  static final _tasks = [
    {
      'title': 'Review ground floor plan — Sunrise Villa',
      'priority': 'high',
      'done': false,
      'time': '10:00 AM',
    },
    {
      'title': 'Site visit documentation — Green Residency',
      'priority': 'medium',
      'done': false,
      'time': '2:00 PM',
    },
    {
      'title': 'Client call — Metro Office brief',
      'priority': 'low',
      'done': true,
      'time': '9:00 AM',
    },
  ];

  String _todayDate() {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ────────────────────────────────────────────────────
            SectionHeader(
              title: 'Good Morning, $greetingRole 👋',
              subtitle: _todayDate(),
            ),
            const SizedBox(height: 12),

            // ── Stats (horizontal scroll) ────────────────────────────────────
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final s = stats[i];
                  return _StatCard(
                    icon: s['icon'] as IconData,
                    label: s['label'] as String,
                    value: s['val'] as String,
                    isError: s['error'] == true,
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // ── Active Projects ──────────────────────────────────────────────
            if (showProjects) ...[
              _SectionRow(
                title: 'Active Projects',
                onViewAll: () => onNavigate('projects'),
              ),
              const SizedBox(height: 12),
              ..._projects.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProjectCard(project: p),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Today's Tasks ────────────────────────────────────────────────
            if (showTasks) ...[
              _SectionRow(
                title: "Today's Tasks",
                onViewAll: () => onNavigate('tasks'),
              ),
              const SizedBox(height: 12),
              ..._tasks.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TaskRow(task: t),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Quick Actions ────────────────────────────────────────────────
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // Use GridView.builder fixed cross-axis so no overflow
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: quickActions.length,
              itemBuilder: (_, i) {
                final a = quickActions[i];
                return _QuickActionTile(
                  icon: a['icon'] as IconData,
                  label: a['label'] as String,
                  onTap: () => onNavigate(a['section'] as String),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isError;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.primary;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionRow({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View all',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final status = project['status'] as String;
    final pct = (project['pct'] as double);
    final members = project['members'] as List;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar at top — no overflow
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 3,
              backgroundColor: AppColors.primaryFixed.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project['client'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GoldChip(text: status, bg: chipBg(status), fg: chipFg(status)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Overlapping avatars
              SizedBox(
                height: 26,
                width: (members.length * 20 + 6).toDouble(),
                child: Stack(
                  children: List.generate(members.length, (i) {
                    return Positioned(
                      left: i * 18.0,
                      child: AvatarWidget(
                        initials: members[i] as String,
                        size: 26,
                        fontSize: 9,
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toInt()}% done',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final Map<String, dynamic> task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final priority = task['priority'] as String;
    final done = task['done'] as bool;

    final priorityColor = priority == 'high'
        ? AppColors.chipProgressFg
        : priority == 'medium'
        ? AppColors.chipPlanningFg
        : AppColors.chipDoneFg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: priorityColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: done ? AppColors.primary : AppColors.outlineVariant,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: done
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  task['time'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GoldChip(text: priority, bg: chipBg(priority), fg: chipFg(priority)),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
