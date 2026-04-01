import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';

class MaterialsSection extends StatelessWidget {
  final AppUser user;
  final Function(String) onToast;

  const MaterialsSection({super.key, required this.user, required this.onToast});

  bool get canEdit => [UserRole.interior, UserRole.admin].contains(user.role);

  @override
  Widget build(BuildContext context) {
    final materials = [
      {'name': 'Italian Marble — Carrara White', 'vendor': 'Marble Palace', 'qty': '320 sq.ft', 'rate': '₹285/sqft', 'total': '₹91,200', 'project': 'Sunrise Villa', 'status': 'Ordered'},
      {'name': 'Teak Wood Flooring — 18mm', 'vendor': 'WoodCraft India', 'qty': '180 sq.ft', 'rate': '₹420/sqft', 'total': '₹75,600', 'project': 'Green Residency', 'status': 'Delivered'},
      {'name': 'Aluminium Window Frames', 'vendor': 'AlluMate', 'qty': '24 units', 'rate': '₹3,400/unit', 'total': '₹81,600', 'project': 'Metro Office', 'status': 'Pending'},
      {'name': 'Gypsum False Ceiling — 2"', 'vendor': 'CeilCraft', 'qty': '450 sq.ft', 'rate': '₹95/sqft', 'total': '₹42,750', 'project': 'Sunrise Villa', 'status': 'Delivered'},
      {'name': 'Anti-Skid Tiles — Bathroom', 'vendor': 'Kajaria Ceramics', 'qty': '240 sq.ft', 'rate': '₹68/sqft', 'total': '₹16,320', 'project': 'Green Residency', 'status': 'Ordered'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: SectionHeader(title: 'Materials', subtitle: '₹3,07,470 tracked')),
              if (canEdit)
                GestureDetector(
                  onTap: () => onToast('Add material form opened!'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12)),
                    child: const Row(children: [Icon(Icons.add_rounded, color: Colors.white, size: 16), SizedBox(width: 4), Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary
          Row(
            children: [
              _summaryCard('₹3.07L', 'Total Value', Icons.payments_rounded),
              const SizedBox(width: 10),
              _summaryCard('8', 'Ordered', Icons.local_shipping_rounded),
              const SizedBox(width: 10),
              _summaryCard('4', 'Pending', Icons.pending_rounded, isError: true),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          Container(
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search materials...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ...materials.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface)),
                            const SizedBox(height: 2),
                            Text(m['vendor']!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      StatusChip(status: m['status']!),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    _materialStat('Qty', m['qty']!),
                    const SizedBox(width: 8),
                    _materialStat('Rate', m['rate']!),
                    const SizedBox(width: 8),
                    _materialStatHighlight('Total', m['total']!),
                  ]),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                        child: Text(m['project']!, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ),
                      if (canEdit)
                        GestureDetector(
                          onTap: () => onToast('Material updated!'),
                          child: const Row(children: [
                            Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ]),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _summaryCard(String val, String label, IconData icon, {bool isError = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isError ? AppColors.error : AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isError ? AppColors.error : AppColors.onSurface)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _materialStat(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _materialStatHighlight(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
