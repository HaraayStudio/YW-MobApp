import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:yw_architects/models/app_models.dart';
import '../common_widgets.dart';

class OverviewTabView extends StatelessWidget {
  final Map<String, dynamic> project;
  final AppUser user;

  const OverviewTabView({Key? key, required this.project, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Attempt to parse out the details safely
    final originalProject = project['project'] ?? project; // Depending on API depth
    
    final code = originalProject['projectCode']?.toString() ?? '—';
    final address = originalProject['address']?.toString() ?? 'N/A';
    
    // Area
    final plot = originalProject['plotArea']?.toString() ?? '';
    final built = originalProject['totalBuiltUpArea']?.toString() ?? '';
    String area = 'N/A';
    if (plot.isNotEmpty && plot != '0' && plot != 'null') {
      area = '$plot sq.ft';
    } else if (built.isNotEmpty && built != '0' && built != 'null') {
      area = '$built sq.ft';
    }

    // Dates
    String formatIso(String? isoStr) {
      if (isoStr == null || isoStr.isEmpty || isoStr == 'null') return '—';
      try {
        final d = DateTime.parse(isoStr);
        return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      } catch (_) {
        return '—';
      }
    }

    final start = formatIso(originalProject['projectStartDateTime']?.toString());
    final deadline = formatIso(originalProject['projectExpectedEndDate']?.toString());

    final remark = project['remark']?.toString() ?? 'No notes available for this project.';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: [
              ['Code', code],
              ['Area', area],
              ['Start', start],
              ['Deadline', deadline],
              ['Address', address],
              ['Updates', '0'],
            ].map((item) => Container(
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
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                  Text(
                    item[1],
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          CardContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'INTERNAL REMARK',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  remark,
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurface, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

