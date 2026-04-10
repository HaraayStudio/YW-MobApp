import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InvoiceCard extends StatefulWidget {
  final Map<String, dynamic> invoice;
final bool isTax;
  final VoidCallback? onDelete;
  final VoidCallback? onView;
  final VoidCallback? onConvert;
  final VoidCallback? onPaid;

  const InvoiceCard({
    Key? key,
    required this.invoice,
    this.isTax = false,
    this.onDelete,
    this.onView,
    this.onConvert,
    this.onPaid,
  }) : super(key: key);

  @override
  State<InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final String status = inv['status'] ?? 'DRAFT';
    final bool isPaid = inv['paid'] ?? false;
    final double gross = (inv['grossAmount'] ?? 0.0).toDouble();
    final double net = (inv['netAmount'] ?? 0.0).toDouble();
    final double cgst = (inv['cgstAmount'] ?? 0.0).toDouble();
    final double sgst = (inv['sgstAmount'] ?? 0.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Collapsed Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('#${inv['id']}',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(inv['invoiceNumber'] ?? 'NO-NUMBER',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 12),
                      _buildStatusBadge(status),
                      const SizedBox(width: 8),
                      if (isPaid) _buildPaidBadge(),
                      const SizedBox(width: 8),
                      if (inv['convertedFromProformaId'] != null)
                        _buildConvertedBadge(inv['convertedFromProformaId']),
                      const Spacer(),
                      Text('₹${gross.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniInfo(Icons.calendar_today_outlined, inv['issueDate'] ?? '--'),
                      const SizedBox(width: 16),
                      if (!widget.isTax)
                        _buildMiniInfo(Icons.hourglass_bottom, 'Valid till ${inv['validTill'] ?? '--'}'),
                      const SizedBox(width: 16),
                      _buildMiniInfo(Icons.person_outline, inv['clientName'] ?? 'N/A'),
                      const Spacer(),
                      Text('Net: ₹${net.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            const Divider(height: 1),
            // Calculation Bar
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  Expanded(child: _buildAmountBox('NET AMOUNT', net)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('+', style: TextStyle(color: Colors.black26, fontSize: 20)),
                  ),
                  Expanded(child: _buildAmountBox('CGST', cgst)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('+', style: TextStyle(color: Colors.black26, fontSize: 20)),
                  ),
                  Expanded(child: _buildAmountBox('SGST', sgst)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('=', style: TextStyle(color: Colors.black26, fontSize: 20)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Text('GROSS TOTAL',
                              style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('₹${gross.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Grid
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Color(0xFF6366F1)),
                            SizedBox(width: 4),
                            Text('CLIENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('NAME', inv['clientName']),
                        _buildDetailRow('EMAIL', inv['clientEmail']),
                        _buildDetailRow('PHONE', inv['clientPhone']),
                        _buildDetailRow('GSTIN', inv['clientGstin']),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.description, size: 14, color: Color(0xFFF59E0B)),
                            SizedBox(width: 4),
                            Text('INVOICE INFO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('ISSUE DATE', inv['issueDate']),
                        if (!widget.isTax) _buildDetailRow('VALID TILL', inv['validTill']),
                        _buildDetailRow('STATUS', status),
                        _buildDetailRow('NOTIFIED', (inv['notified'] ?? false) ? 'Yes' : 'No'),
                        _buildDetailRow('PAID', isPaid ? '✓ Yes' : 'No', isGreen: isPaid),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Actions Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (!isPaid)
                    _buildActionButton('Paid', Icons.check_circle_outline, Colors.green, widget.onPaid),
                  if (!widget.isTax && status != 'CONVERTED')
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildActionButton(
                        'Convert to Tax',
                        Icons.transform,
                        Colors.indigo,
                        isPaid ? widget.onConvert : null,
                        enabled: isPaid,
                        tooltip: isPaid ? null : 'Invoice must be paid before conversion',
                      ),
                    ),
                  const Spacer(),
                  _buildActionButton('View Invoice', Icons.visibility_outlined, Colors.indigo, widget.onView),
                  const SizedBox(width: 8),
                  _buildActionButton('Delete', Icons.delete_outline, Colors.red, widget.onDelete, isOutline: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.blue;
    if (status == 'PAID') color = Colors.green;
    if (status == 'DRAFT') color = Colors.orange;
    if (status == 'SENT') color = Colors.purple;
    if (status == 'CONVERTED') color = Colors.teal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildConvertedBadge(dynamic id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swap_horiz_rounded, size: 10, color: Colors.teal),
          const SizedBox(width: 4),
          Text('From PI #$id', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
        ],
      ),
    );
  }

  Widget _buildPaidBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 10, color: Colors.green),
          SizedBox(width: 4),
          Text('Paid', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildAmountBox(String label, double amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
          Text(value?.toString() ?? '--',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isGreen ? Colors.green : const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback? onTap, {bool isOutline = false, bool enabled = true, String? tooltip}) {
    final Color finalColor = enabled ? color : Colors.grey;
    final Widget button = isOutline
      ? OutlinedButton.icon(
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 14, color: finalColor),
          label: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: finalColor)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide(color: finalColor.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        )
      : TextButton.icon(
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 14, color: finalColor),
          label: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: finalColor)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: finalColor.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}
