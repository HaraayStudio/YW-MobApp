import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ReportsSection extends StatelessWidget {
  final Function(String) onToast;

  const ReportsSection({super.key, required this.onToast});

  @override
  Widget build(BuildContext context) {
    final kpis = [
      {'label': 'Total Revenue', 'val': '₹4.2 Cr', 'change': '+12%', 'up': true, 'icon': Icons.payments_rounded},
      {'label': 'Active Projects', 'val': '8', 'change': '+2', 'up': true, 'icon': Icons.architecture_rounded},
      {'label': 'Avg Project Delay', 'val': '6.2 days', 'change': '-1.5d', 'up': false, 'icon': Icons.schedule_rounded},
      {'label': 'Client Satisfaction', 'val': '4.7/5', 'change': '+0.3', 'up': true, 'icon': Icons.star_rounded},
    ];
    final projects = [
      {'name': 'Sunrise Villa', 'pct': 0.68, 'budget': '₹82L'},
      {'name': 'Metro Office Complex', 'pct': 0.35, 'budget': '₹3.2Cr'},
      {'name': 'Green Residency', 'pct': 0.90, 'budget': '₹1.1Cr'},
      {'name': 'Harmony Heights', 'pct': 0.15, 'budget': '₹7.5Cr'},
    ];
    final team = [
      {'name': 'Rahul Kapoor', 'role': 'Senior Architect', 'tasks': 28, 'attend': '96%', 'rating': '4.8', 'init': 'RK'},
      {'name': 'Priya Singh', 'role': 'Interior Designer', 'tasks': 22, 'attend': '98%', 'rating': '4.9', 'init': 'PS'},
      {'name': 'Amit Joshi', 'role': 'Site Engineer', 'tasks': 34, 'attend': '94%', 'rating': '4.7', 'init': 'AJ'},
      {'name': 'Varun Rao', 'role': '3D Visualizer', 'tasks': 19, 'attend': '88%', 'rating': '4.5', 'init': 'VR'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Reports', subtitle: 'Business Intelligence Overview'),
          const SizedBox(height: 20),

          // Period selector
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final labels = ['This Month', 'Q4 2025', 'FY 2025'];
                final active = i == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(labels[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.outline)),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // KPIs
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: kpis.map((k) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(k['icon'] as IconData, color: AppColors.primary, size: 20),
                  const SizedBox(height: 4),
                  Text(k['label'] as String, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  Text(k['val'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                  Text(
                    '${k['change']} vs last period',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: k['up'] == true ? AppColors.primary : AppColors.error),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),

          // Project Progress Chart
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Project Progress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface)),
                const Text('Completion status across all active projects', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                ...projects.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                          Text('${((p['pct'] as double) * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ProgressBar(percent: p['pct'] as double, height: 8),
                      const SizedBox(height: 4),
                      Text(p['budget'] as String, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Team Performance
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Team Performance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface)),
                const SizedBox(height: 14),
                ...team.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        AvatarWidget(initials: e['init'] as String, size: 40, fontSize: 14),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.onSurface)),
                              Row(children: [
                                Text('${e['tasks']} tasks', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                const SizedBox(width: 10),
                                Text('${e['attend']} attend.', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                              ]),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(e['rating'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                            const Text('rating', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Export
          Row(children: [
            Expanded(
              child: GoldGradientButton(
                text: 'Export PDF',
                icon: Icons.picture_as_pdf_rounded,
                onTap: () => onToast('PDF report generated!'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => onToast('Excel report downloaded!'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_chart_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Export Excel', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
