import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/site_model.dart';
import 'package:yw_architects/utils/responsive.dart';

class SiteCard extends StatelessWidget {
  final Site site;
  final VoidCallback onTap;

  const SiteCard({super.key, required this.site, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10.w,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image / Logo Section
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
                  border: Border(
                    bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                ),
                child: site.logoUrl != null && site.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Image.network(
                            site.logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackInitial(),
                          ),
                        ),
                      )
                    : _buildFallbackInitial(),
              ),
            ),
            // Bottom Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      site.siteName,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Site #${site.id}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackInitial() {
    return Center(
      child: Text(
        site.siteName.isNotEmpty ? site.siteName[0].toUpperCase() : "?",
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 64.sp,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
