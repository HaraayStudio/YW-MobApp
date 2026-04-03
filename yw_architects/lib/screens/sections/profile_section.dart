import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

class ProfileSection extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;
  final Function(String) onToast;

  const ProfileSection({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onToast,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  bool _notificationsOn = true;
  bool _darkModeOn = false;

  @override
  Widget build(BuildContext context) {
    final settings = [
      {
        'icon': Icons.notifications_rounded,
        'label': 'Notifications',
        'sub': 'Push & email alerts',
        'toggle': true,
        'key': 'notif',
      },
      {
        'icon': Icons.dark_mode_rounded,
        'label': 'Dark Mode',
        'sub': 'Appearance',
        'toggle': true,
        'key': 'dark',
      },
      {
        'icon': Icons.language_rounded,
        'label': 'Language',
        'sub': 'English (India)',
        'toggle': false,
        'key': '',
      },
      {
        'icon': Icons.security_rounded,
        'label': 'Change Password',
        'sub': 'Security settings',
        'toggle': false,
        'key': '',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Hero
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.15),
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                // Gold banner
                Container(
                  height: 90,
                  decoration: BoxDecoration(gradient: goldGradient),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -28),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                gradient: goldGradient,
                              ),
                              child: Center(
                                child: Text(
                                  widget.user.info.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: GestureDetector(
                              onTap: () => widget.onToast(
                                'Profile edit mode activated!',
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: AppColors.onSurface,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: const Offset(0, -12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.info.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              widget.user.info.label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: const [
                                GoldChip(
                                  text: 'Active',
                                  bg: AppColors.chipDoneBg,
                                  fg: AppColors.chipDoneFg,
                                ),
                                SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    'YW-2024-007',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  backgroundColor: Color(0x26B8952A),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick stats
          Row(
            children: [
              _stat('4', 'Projects'),
              const SizedBox(width: 10),
              _stat('38', 'Tasks'),
              const SizedBox(width: 10),
              _stat('8', 'Days Left'),
            ],
          ),
          const SizedBox(height: 16),

          // Account info
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                ...([
                  {
                    'icon': Icons.mail_rounded,
                    'label': 'Email',
                    'val': widget.user.info.email,
                  },
                  {
                    'icon': Icons.phone_rounded,
                    'label': 'Phone',
                    'val': '+91 98765 43210',
                  },
                  {
                    'icon': Icons.home_work_rounded,
                    'label': 'Office',
                    'val': 'YW Architects HQ, Pune',
                  },
                  {
                    'icon': Icons.badge_rounded,
                    'label': 'Employee ID',
                    'val': 'YW-2024-007',
                  },
                  {
                    'icon': Icons.calendar_today_rounded,
                    'label': 'Date of Joining',
                    'val': '15 March 2024',
                  },
                ]).map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            i['icon'] as IconData,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i['label'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              i['val'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                ...settings.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  final isToggle = s['toggle'] as bool;
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            s['icon'] as IconData,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          s['label'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          s['sub'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        trailing: isToggle
                            ? Switch(
                                value: s['key'] == 'notif'
                                    ? _notificationsOn
                                    : _darkModeOn,
                                onChanged: (v) => setState(() {
                                  if (s['key'] == 'notif')
                                    _notificationsOn = v;
                                  else
                                    _darkModeOn = v;
                                }),
                                activeThumbColor: AppColors.primary,
                              )
                            : const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.onSurfaceVariant,
                              ),
                        onTap: isToggle
                            ? null
                            : () => widget.onToast('Settings opened!'),
                      ),
                      if (i < settings.length - 1)
                        const Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: Color(0x1AD0C5B0),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sign Out
          GestureDetector(
            onTap: widget.onLogout,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
