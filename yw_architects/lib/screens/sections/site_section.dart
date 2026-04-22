import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:yw_architects/models/app_models.dart';
import '../../widgets/common_widgets.dart';

class SiteSection extends StatefulWidget {
  final Function(String) onToast;
  final AppUser user;

  const SiteSection({super.key, required this.onToast, required this.user});

  @override
  State<SiteSection> createState() => _SiteSectionState();
}

class _SiteSectionState extends State<SiteSection> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mockLoad();
  }

  void _mockLoad() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SiteSkeleton();
    final snags = [
      {
        'title': 'Crack in south wall column — G/F',
        'area': 'Ground Floor',
        'severity': 'High',
        'status': 'Open',
      },
      {
        'title': 'Drainage slope incorrect — Toilet 2',
        'area': 'First Floor',
        'severity': 'Medium',
        'status': 'In Review',
      },
      {
        'title': 'Door frame misalignment — Room 4',
        'area': 'First Floor',
        'severity': 'Low',
        'status': 'Fixed',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Site Updates',
            subtitle: 'GPS tracking & daily logs',
          ),
          const SizedBox(height: 24),

          // GPS Check-in Card
          CardContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Grid pattern
                      CustomPaint(
                        painter: _MapGridPainter(),
                        size: Size.infinite,
                      ),
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 36,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sunrise Villa Site',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Baner, Pune — 18.560° N, 73.776° E',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Checked In',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '08:45 AM',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Check Out',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.user.role != UserRole.client)
                        GoldGradientButton(
                          text: 'GPS Check Out',
                          icon: Icons.gps_fixed_rounded,
                          verticalPadding: 14,
                          onTap: () => widget.onToast('GPS check-out recorded!'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Upload Progress Photos
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Upload Progress Photos',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: [
                    ...List.generate(
                      5,
                      (i) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_rounded,
                            color: AppColors.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    if (widget.user.role != UserRole.client)
                      GestureDetector(
                        onTap: () => widget.onToast('Gallery opened!'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.user.role != UserRole.client) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'DAILY LOG NOTE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Describe today\'s site progress, observations, issues...',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownField('Site Area', [
                          'Ground Floor',
                          'First Floor',
                          'Basement',
                          'Rooftop',
                        ]),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dropdownField('Activity Type', [
                          'Concrete Work',
                          'Masonry',
                          'Electrical',
                          'Plumbing',
                          'Finishing',
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GoldGradientButton(
                    text: 'Submit Daily Log',
                    icon: Icons.upload_rounded,
                    onTap: () => widget.onToast('Daily log submitted!'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Snag List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Open Snags',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              if (widget.user.role != UserRole.client)
                GestureDetector(
                  onTap: () => widget.onToast('Snag created!'),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      Text(
                        'Report',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...snags.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CardContainer(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            s['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GoldChip(
                          text: s['severity']!,
                          bg: s['severity'] == 'High'
                              ? AppColors.chipProgressBg
                              : s['severity'] == 'Medium'
                              ? AppColors.chipPlanningBg
                              : AppColors.chipDoneBg,
                          fg: s['severity'] == 'High'
                              ? AppColors.chipProgressFg
                              : s['severity'] == 'Medium'
                              ? AppColors.chipPlanningFg
                              : AppColors.chipDoneFg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s['area']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        StatusChip(status: s['status']!),
                      ],
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

  Widget _dropdownField(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<String>(
            value: options.first,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurface,
              fontFamily: 'PlusJakartaSans',
            ),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF755B00).withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
