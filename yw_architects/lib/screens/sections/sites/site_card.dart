import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/site_model.dart';

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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border(
                    bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
                  ),
                ),
                child: site.logoUrl != null && site.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Site #${site.id}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
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
          fontSize: 64,
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
    );
  }
}
