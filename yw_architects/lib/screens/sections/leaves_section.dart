import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

class LeavesSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onToast;

  const LeavesSection({super.key, required this.user, required this.onToast});

  bool get isApprover => [UserRole.admin, UserRole.coFounder, UserRole.hr, UserRole.srArchitect, UserRole.srEngineer, UserRole.liaisonManager].contains(user.role);

  @override
  Widget build(BuildContext context) {
    final balances = [
      {'type': 'Casual Leave', 'used': 4, 'total': 12},
      {'type': 'Sick Leave', 'used': 2, 'total': 12},
      {'type': 'Annual Leave', 'used': 8, 'total': 21},
      {'type': 'Compensatory Off', 'used': 0, 'total': 4},
    ];
    final pending = [
      {'name': 'Kavya Rao', 'role': 'Junior Architect', 'type': 'Casual Leave', 'dates': '28-30 Mar', 'days': 3, 'reason': 'Personal work', 'init': 'KR'},
      {'name': 'Varun Rao', 'role': '3D Visualizer', 'type': 'Sick Leave', 'dates': '27 Mar', 'days': 1, 'reason': 'Medical appointment', 'init': 'VR'},
    ];
    final history = [
      {'type': 'Annual Leave', 'dates': '10-14 Mar 2025', 'days': 5, 'status': 'Approved'},
      {'type': 'Casual Leave', 'dates': '24 Feb 2025', 'days': 1, 'status': 'Approved'},
      {'type': 'Sick Leave', 'dates': '18 Jan 2025', 'days': 2, 'status': 'Approved'},
      {'type': 'Casual Leave', 'dates': '5 Jan 2025', 'days': 1, 'status': 'Rejected'},
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: SectionHeader(title: 'Leaves', subtitle: 'Manage leave requests')),
                GestureDetector(
                  onTap: () => _showLeaveModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: const Row(children: [Icon(Icons.add_rounded, color: Colors.white, size: 16), SizedBox(width: 4), Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Leave Balance
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Leave Balance — FY 2024-25', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onSurface)),
                  const SizedBox(height: 16),
                  ...balances.map((l) {
                    final remaining = (l['total'] as int) - (l['used'] as int);
                    final pct = (l['used'] as int) / (l['total'] as int);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l['type'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                              Text('$remaining remaining', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ProgressBar(percent: pct, height: 6),
                          const SizedBox(height: 4),
                          Text('${l['used']} used of ${l['total']} days', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pending Approvals (for approvers)
            if (isApprover) ...[
              const Text('Pending Approvals', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 12),
              ...pending.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CardContainer(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvatarWidget(initials: l['init'] as String, size: 40, fontSize: 14),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface)),
                              Text(l['role'] as String, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            ],
                          )),
                          GoldChip(text: 'Pending', bg: AppColors.chipPlanningBg, fg: AppColors.chipPlanningFg),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(l['type'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.onSurface)),
                              Text('${l['dates']} · ${l['reason']}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            ]),
                            Text('${l['days']} day${(l['days'] as int) > 1 ? 's' : ''}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onToast('Leave approved!'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.check_rounded, color: Colors.white, size: 16), SizedBox(width: 4), Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onToast('Leave rejected.'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.close_rounded, color: AppColors.error, size: 16), SizedBox(width: 4), Text('Reject', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700))],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 8),
            ],

            const Text('My History', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            const SizedBox(height: 12),
            ...history.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CardContainer(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l['type'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.onSurface)),
                        Text('${l['dates']} · ${l['days']} day${(l['days'] as int) > 1 ? 's' : ''}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    )),
                    StatusChip(status: l['status'] as String),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showLeaveModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Apply for Leave', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ]),
            const SizedBox(height: 16),
            const Text('LEAVE TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButton<String>(
                value: 'Casual Leave',
                isExpanded: true,
                underline: const SizedBox(),
                items: ['Casual Leave', 'Sick Leave', 'Annual Leave', 'Emergency Leave', 'Compensatory Off']
                    .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _dateField('From')),
              const SizedBox(width: 12),
              Expanded(child: _dateField('To')),
            ]),
            const SizedBox(height: 12),
            const Text('REASON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
            const SizedBox(height: 6),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Brief reason for leave...',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            GoldGradientButton(
              text: 'Submit Application',
              onTap: () { Navigator.pop(context); onToast('Leave application submitted!'); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.onSurfaceVariant),
            SizedBox(width: 8),
            Text('Select date', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
          ]),
        ),
      ],
    );
  }
}
