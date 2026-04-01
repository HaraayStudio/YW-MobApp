import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

class RendersSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onToast;

  const RendersSection({super.key, required this.user, required this.onToast});

  bool get canUpload => [UserRole.visualizer, UserRole.admin].contains(user.role);

  @override
  Widget build(BuildContext context) {
    final jobs = [
      {'title': 'Sunrise Villa — Living Room Exterior', 'project': 'Sunrise Villa', 'task': 'Exterior Perspective Render', 'views': 3, 'feedback': 2, 'status': 'In Progress', 'due': 'Tomorrow', 'progress': 0.60},
      {'title': 'Metro Office — Reception Lobby', 'project': 'Metro Office', 'task': 'Interior Walk-through', 'views': 1, 'feedback': 0, 'status': 'Pending', 'due': '30 Mar', 'progress': 0.20},
      {'title': 'Green Residency — Master Bedroom', 'project': 'Green Residency', 'task': 'Interior Render Set', 'views': 5, 'feedback': 1, 'status': 'Review', 'due': '27 Mar', 'progress': 0.90},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: SectionHeader(title: '3D Renders', subtitle: 'Visualization workspace')),
              if (canUpload)
                GestureDetector(
                  onTap: () => onToast('Upload dialog opened!'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12)),
                    child: const Row(children: [Icon(Icons.upload_rounded, color: Colors.white, size: 16), SizedBox(width: 4), Text('Upload', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              _statCard('42', 'Total Renders', Icons.view_in_ar_rounded),
              const SizedBox(width: 10),
              _statCard('6', 'In Progress', Icons.pending_rounded),
              const SizedBox(width: 10),
              _statCard('3', 'Revisions', Icons.feedback_rounded, isError: true),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Active Render Jobs', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 12),

          ...jobs.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.surfaceContainerHigh, AppColors.surfaceContainerHighest],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: Icon(Icons.view_in_ar_rounded, color: AppColors.primary, size: 32)),
                          ),
                        ),
                        Positioned(
                          top: 12, right: 12,
                          child: StatusChip(status: r['status'] as String),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface)),
                        const SizedBox(height: 2),
                        Text('${r['task']} · ${r['project']}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 10),
                        ProgressBar(percent: r['progress'] as double, height: 5),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Icon(Icons.image_rounded, size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text('${r['views']} renders', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                              const SizedBox(width: 10),
                              Icon(Icons.feedback_rounded, size: 14, color: (r['feedback'] as int) > 0 ? AppColors.error : AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text('${r['feedback']} feedback', style: TextStyle(fontSize: 11, color: (r['feedback'] as int) > 0 ? AppColors.error : AppColors.onSurfaceVariant)),
                            ]),
                            Text('Due ${r['due']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),

          if (canUpload) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4), style: BorderStyle.solid, width: 1.5),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 40),
                  const SizedBox(height: 8),
                  const Text('Upload New Renders', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Drag & drop or tap to select files', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => onToast('File picker opened!'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12)),
                      child: const Text('Select Files', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String val, String label, IconData icon, {bool isError = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isError ? AppColors.error : AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isError ? AppColors.error : AppColors.onSurface)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
