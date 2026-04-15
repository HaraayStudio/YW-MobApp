import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/site_model.dart';
import 'site_card.dart';

class SiteListSection extends StatelessWidget {
  final List<Site> sites;
  final bool isLoading;
  final Function(Site) onSiteTap;
  final String activeFilter;
  final Function(String) onFilterChange;
  final VoidCallback? onAddSite;

  const SiteListSection({
    super.key,
    required this.sites,
    required this.isLoading,
    required this.onSiteTap,
    required this.activeFilter,
    required this.onFilterChange,
    this.onAddSite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(
        0xFFF6F7F0,
      ), // Matches external React Web specific off-white green
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 32,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "All Sites",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B232A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${sites.length} sites",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (sites.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction_rounded,
                        size: 64,
                        color: AppColors.outline.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No sites found",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Grid View
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Decide whether we are displaying 2 columns (phone) or 3+ (tablet/web)
                    int crossAxisCount = constraints.maxWidth > 800
                        ? 4
                        : (constraints.maxWidth > 500 ? 3 : 2);

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio:
                            0.85, // Adjust this ratio based on card height/width visualization
                      ),
                      itemCount: sites.length,
                      itemBuilder: (context, index) {
                        return SiteCard(
                          site: sites[index],
                          onTap: () => onSiteTap(sites[index]),
                        );
                      },
                    );
                  },
                ),
              ),

            // Pagination Row
            if (!isLoading && sites.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Prev",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Page 1 of 1",
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Next",
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
