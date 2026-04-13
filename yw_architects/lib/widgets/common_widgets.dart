import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
        width: width ?? double.infinity,
        height: height,
        padding: height != null ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 20),
        decoration: BoxDecoration(
          gradient: goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF755B00).withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
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

  const GoldChip({super.key, required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

Color chipBg(String status) {
  switch (status.toLowerCase()) {
    case 'in progress':
    case 'progress': return AppColors.chipProgressBg;
    case 'planning':
    case 'pending': return AppColors.chipPlanningBg;
    case 'review':
    case 'in review': return AppColors.chipReviewBg;
    case 'done':
    case 'delivered':
    case 'approved':
    case 'fixed':
    case 'present':
    case 'active': return AppColors.chipDoneBg;
    default: return AppColors.chipHoldBg;
  }
}

Color chipFg(String status) {
  switch (status.toLowerCase()) {
    case 'in progress':
    case 'progress': return AppColors.chipProgressFg;
    case 'planning':
    case 'pending': return AppColors.chipPlanningFg;
    case 'review':
    case 'in review': return AppColors.chipReviewFg;
    case 'done':
    case 'delivered':
    case 'approved':
    case 'fixed':
    case 'present':
    case 'active': return AppColors.chipDoneFg;
    default: return AppColors.chipHoldFg;
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

  const AvatarWidget({
    super.key,
    required this.initials,
    this.size = 40,
    this.fontSize = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        gradient: color == null ? goldGradient : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: subtitle != null ? 48 : 32,
              decoration: BoxDecoration(
                gradient: goldGradient,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (action != null) action!,
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

  const CardContainer({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: child,
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
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)
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

