import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

class AttendanceSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onToast;

  const AttendanceSection({super.key, required this.user, required this.onToast});

  bool get isAdmin => [UserRole.admin, UserRole.hr].contains(user.role);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final todayStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

    final teamAttd = [
      {'name': 'Rahul Kapoor', 'role': 'Senior Architect', 'status': 'Present', 'time': '9:05 AM', 'init': 'RK'},
      {'name': 'Priya Singh', 'role': 'Interior Designer', 'status': 'Present', 'time': '9:22 AM', 'init': 'PS'},
      {'name': 'Amit Joshi', 'role': 'Site Engineer', 'status': 'On Site', 'time': '8:45 AM', 'init': 'AJ'},
      {'name': 'Varun Rao', 'role': '3D Visualizer', 'status': 'WFH', 'time': '9:30 AM', 'init': 'VR'},
      {'name': 'Kavya Rao', 'role': 'Junior Architect', 'status': 'Absent', 'time': '—', 'init': 'KR'},
    ];

    final recentLog = [
      {'date': '25', 'day': 'Tue', 'in': '9:15', 'out': '6:32', 'hrs': '9h 17m', 'status': 'Present'},
      {'date': '24', 'day': 'Mon', 'in': '9:05', 'out': '6:48', 'hrs': '9h 43m', 'status': 'Present'},
      {'date': '23', 'day': 'Sun', 'in': '—', 'out': '—', 'hrs': '—', 'status': 'Off'},
      {'date': '22', 'day': 'Sat', 'in': '—', 'out': '—', 'hrs': '—', 'status': 'Off'},
      {'date': '21', 'day': 'Fri', 'in': '9:40', 'out': '6:30', 'hrs': '8h 50m', 'status': 'Late'},
      {'date': '20', 'day': 'Thu', 'in': '—', 'out': '—', 'hrs': '—', 'status': 'Leave'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Attendance', subtitle: 'March 2025'),
          const SizedBox(height: 24),

          // Check In/Out Card
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                        Text(todayStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                      ],
                    ),
                    GoldChip(text: 'Office Day', bg: AppColors.chipDoneBg, fg: AppColors.chipDoneFg),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                        child: const Column(
                          children: [
                            Text('Check In', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            SizedBox(height: 4),
                            Text('09:12 AM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            Text('On time ✓', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                        child: const Column(
                          children: [
                            Text('Check Out', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            SizedBox(height: 4),
                            Text('—:— —', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant)),
                            Text('Still in office', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GoldGradientButton(
                  text: 'Check Out Now',
                  icon: Icons.logout_rounded,
                  onTap: () => onToast('Check-out recorded: 6:31 PM'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Monthly summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('March Summary', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface, fontSize: 15)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _sumStat('18', 'Present', AppColors.primary),
                    _sumStat('2', 'Absent', AppColors.error),
                    _sumStat('3', 'Late', AppColors.onSurfaceVariant),
                    _sumStat('2', 'Leave', AppColors.secondary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Admin: Team status
          if (isAdmin) ...[
            const Text("Today's Team Status", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            const SizedBox(height: 12),
            ...teamAttd.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CardContainer(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    AvatarWidget(initials: e['init']!, size: 40, fontSize: 14),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.onSurface)),
                          Text('${e['role']} · ${e['time']}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    StatusChip(status: e['status']!),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],

          const Text('Recent Log', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 12),
          ...recentLog.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CardContainer(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        Text(l['date']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                        Text(l['day']!, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l['in']} → ${l['out']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                        Text(l['hrs']!, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  StatusChip(status: l['status']!),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _sumStat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
