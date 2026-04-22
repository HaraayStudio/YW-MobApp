import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../utils/base64_utils.dart';
import '../api/constants.dart';
import '../utils/responsive.dart';

class GoldGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final double? width;
  final double? height;
  final double verticalPadding;

  const GoldGradientButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.width,
    this.height,
    this.verticalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width?.w ?? double.infinity,
        height: height?.h,
        padding: height != null
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(
                vertical: verticalPadding.h,
                horizontal: 20.w,
              ),
        decoration: BoxDecoration(
          gradient: goldGradient,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF755B00).withValues(alpha: 0.3),
              blurRadius: 24.w,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: (height == null ? 0 : 8.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20.w),
                  SizedBox(width: 8.w),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoldChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const GoldChip({
    super.key,
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

Color chipBg(String status) {
  switch (status.toLowerCase()) {
    case 'in progress':
    case 'progress':
      return AppColors.chipProgressBg;
    case 'planning':
    case 'pending':
      return AppColors.chipPlanningBg;
    case 'review':
    case 'in review':
      return AppColors.chipReviewBg;
    case 'done':
    case 'delivered':
    case 'approved':
    case 'fixed':
    case 'present':
    case 'active':
      return AppColors.chipDoneBg;
    default:
      return AppColors.chipHoldBg;
  }
}

Color chipFg(String status) {
  switch (status.toLowerCase()) {
    case 'in progress':
    case 'progress':
      return AppColors.chipProgressFg;
    case 'planning':
    case 'pending':
      return AppColors.chipPlanningFg;
    case 'review':
    case 'in review':
      return AppColors.chipReviewFg;
    case 'done':
    case 'delivered':
    case 'approved':
    case 'fixed':
    case 'present':
    case 'active':
      return AppColors.chipDoneFg;
    default:
      return AppColors.chipHoldFg;
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return GoldChip(text: status, bg: chipBg(status), fg: chipFg(status));
  }
}

class AvatarWidget extends StatelessWidget {
  final String initials;
  final double size;
  final double fontSize;
  final Color? color;
  final String? imageUrl;

  const AvatarWidget({
    super.key,
    required this.initials,
    this.size = 40,
    this.fontSize = 14,
    this.color,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String? effectiveUrl = _getEffectiveUrl();
    final bool isBase64 =
        effectiveUrl != null && Base64Utils.isBase64(effectiveUrl);

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerHigh,
        gradient: (color == null && (effectiveUrl == null || effectiveUrl.isEmpty)) 
            ? goldGradient 
            : null,
        borderRadius: BorderRadius.circular(size.w / 2),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: effectiveUrl != null && effectiveUrl.isNotEmpty
          ? Image(
              image: isBase64
                  ? MemoryImage(base64Decode(effectiveUrl.split(',').last))
                        as ImageProvider
                  : NetworkImage(effectiveUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildInitials(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                  child: Container(color: Colors.white),
                );
              },
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color == null ? Colors.white : AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: fontSize.sp,
        ),
      ),
    );
  }

  String? _getEffectiveUrl() {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (Base64Utils.isBase64(imageUrl)) return imageUrl;
    if (imageUrl!.startsWith('http')) return imageUrl;

    // Relative path handling
    return "${ApiConstants.serverUrl}${imageUrl!.startsWith('/') ? '' : '/'}$imageUrl";
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: subtitle != null ? 48.h : 32.h,
                decoration: BoxDecoration(
                  gradient: goldGradient,
                  borderRadius: BorderRadius.circular(99.w),
                ),
              ),
              SizedBox(width: 16.w),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                      softWrap: true,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...[SizedBox(width: 8.w), action!],
      ],
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double percent;
  final double height;

  const ProgressBar({super.key, required this.percent, this.height = 6});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: AppColors.primaryFixed,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: percent.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: goldGradient,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final String? title;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.04),
              blurRadius: 16.w,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inverseSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.inverseOnSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), () => entry.remove());
}

class SearchField extends StatelessWidget {
  final String hint;
  final Function(String) onChanged;

  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: AppTheme.inputDecoration(
        hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
      ),
    );
  }
}

class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const Skeleton({super.key, this.width, this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width?.w,
        height: height?.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius.w),
        ),
      ),
    );
  }
}

class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Skeleton(width: 48, height: 48, radius: 12),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 150, height: 16),
                    SizedBox(height: 8.h),
                    Skeleton(width: 100, height: 12),
                  ],
                ),
              ),
              Skeleton(width: 60, height: 24, radius: 20),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: Skeleton(height: 40)),
              SizedBox(width: 8.w),
              Expanded(child: Skeleton(height: 40)),
              SizedBox(width: 8.w),
              Expanded(child: Skeleton(height: 40)),
            ],
          ),
        ],
      ),
    );
  }
}

class ProjectDetailSkeleton extends StatelessWidget {
  const ProjectDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(width: 120, height: 32),
                Skeleton(width: 40, height: 40, radius: 20),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Skeleton(width: 54, height: 54, radius: 14),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: 180, height: 24),
                        SizedBox(height: 8.h),
                        Skeleton(width: 120, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Skeleton(width: double.infinity, height: 45, radius: 24),
            SizedBox(height: 20.h),
            Column(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Skeleton(width: double.infinity, height: 80),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeCardSkeleton extends StatelessWidget {
  const EmployeeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Skeleton(width: 48, height: 48, radius: 24),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Skeleton(width: 120, height: 16),
                SizedBox(height: 8.h),
                Skeleton(width: 80, height: 12),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skeleton(width: 50, height: 20, radius: 10),
              SizedBox(height: 4.h),
              Skeleton(width: 40, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Skeleton(width: 50, height: 50, radius: 25),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 140, height: 16),
                SizedBox(height: 8.h),
                Skeleton(width: 100, height: 12),
              ],
            ),
          ),
          Skeleton(width: 32, height: 32, radius: 8),
        ],
      ),
    );
  }
}
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: [
                  Skeleton(width: double.infinity, height: 90, radius: 0),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -28),
                              child: Skeleton(width: 64, height: 64, radius: 18),
                            ),
                            Skeleton(width: 100, height: 36, radius: 10),
                          ],
                        ),
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeleton(width: 180, height: 24),
                              SizedBox(height: 8.h),
                              Skeleton(width: 120, height: 16),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Skeleton(width: 60, height: 24, radius: 20),
                                  SizedBox(width: 8.w),
                                  Skeleton(width: 80, height: 24, radius: 20),
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
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 150, height: 20),
                  SizedBox(height: 16.h),
                  ...List.generate(
                    4,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        children: [
                          Skeleton(width: 40, height: 40, radius: 12),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeleton(width: 60, height: 12),
                              SizedBox(height: 4.h),
                              Skeleton(width: 140, height: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SiteSkeleton extends StatelessWidget {
  const SiteSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 150, height: 32),
            SizedBox(height: 24.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Skeleton(width: double.infinity, height: 130, radius: 16),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Skeleton(height: 50, radius: 12)),
                            SizedBox(width: 10.w),
                            Expanded(child: Skeleton(height: 50, radius: 12)),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Skeleton(width: double.infinity, height: 45, radius: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 180, height: 20),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(child: Skeleton(height: 80, radius: 12)),
                      SizedBox(width: 8.w),
                      Expanded(child: Skeleton(height: 80, radius: 12)),
                      SizedBox(width: 8.w),
                      Expanded(child: Skeleton(height: 80, radius: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 200, height: 32),
            SizedBox(height: 8.h),
            Skeleton(width: 150, height: 16),
            SizedBox(height: 24.h),
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: List.generate(4, (i) => Skeleton(width: double.infinity, height: 120, radius: 16)),
            ),
            SizedBox(height: 28.h),
            
            // Chart placeholder
            Skeleton(width: double.infinity, height: 200, radius: 16),
            SizedBox(height: 28.h),
            
            // Recent Projects Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(width: 140, height: 24),
                Skeleton(width: 60, height: 16),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Recent project tiles
            ...List.generate(3, (i) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Skeleton(width: double.infinity, height: 80, radius: 16),
            )),
          ],
        ),
      ),
    );
  }
}
