import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class NotificationsSection extends StatelessWidget {
  final Function(String) onToast;

  const NotificationsSection({super.key, required this.onToast});

  @override
  Widget build(BuildContext context) {
    final notifs = [
      {'icon': Icons.task_alt_rounded, 'title': 'Task Completed', 'body': 'Rahul K. completed "Ground floor structural drawings"', 'time': '2 mins ago', 'type': 'success', 'read': false},
      {'icon': Icons.event_available_rounded, 'title': 'Leave Request', 'body': 'Kavya Rao applied for Casual Leave (28-30 Mar)', 'time': '1 hr ago', 'type': 'info', 'read': false},
      {'icon': Icons.warning_rounded, 'title': 'Task Overdue', 'body': '"Site inspection checklist" is past due date', 'time': '3 hrs ago', 'type': 'error', 'read': false},
      {'icon': Icons.person_add_rounded, 'title': 'New Employee', 'body': 'Dev Patel joined as Site Engineer today', 'time': 'Yesterday', 'type': 'info', 'read': true},
      {'icon': Icons.payments_rounded, 'title': 'Invoice Approved', 'body': 'Proforma invoice INV-2024-042 approved by client', 'time': '2 days ago', 'type': 'success', 'read': true},
      {'icon': Icons.construction_rounded, 'title': 'Site Update', 'body': 'Amit J. submitted daily log for Sunrise Villa', 'time': '2 days ago', 'type': 'info', 'read': true},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: SectionHeader(title: 'Notifications', subtitle: '3 unread')),
              GestureDetector(
                onTap: () => onToast('All notifications marked as read'),
                child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...notifs.map((n) {
            final read = n['read'] as bool;
            final type = n['type'] as String;
            Color iconBg = type == 'success' ? AppColors.primary.withOpacity(0.1) : type == 'error' ? AppColors.error.withOpacity(0.1) : AppColors.surfaceContainerHigh;
            Color iconColor = type == 'success' ? AppColors.primary : type == 'error' ? AppColors.error : AppColors.primary;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(color: read ? Colors.transparent : AppColors.primary, width: 3),
                    right: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1), width: 0.5),
                    top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1), width: 0.5),
                    bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1), width: 0.5),
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                      child: Icon(n['icon'] as IconData, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(n['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.onSurface)),
                              if (!read)
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(n['body'] as String, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4)),
                          const SizedBox(height: 4),
                          Text(n['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
