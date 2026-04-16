import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:yw_architects/models/app_models.dart';
import '../common_widgets.dart';
import 'invoice_forms.dart';
import 'invoice_card.dart';
import 'invoice_report_view.dart';
import '../../services/invoice_service.dart';

class ProformaTabView extends StatefulWidget {
  final Map<String, dynamic> project;
  final AppUser user;
  final VoidCallback? onRefresh;
  final Function(int)? onTabRequest;

  const ProformaTabView({
    Key? key,
    required this.project,
    required this.user,
    this.onRefresh,
    this.onTabRequest,
  }) : super(key: key);

  @override
  State<ProformaTabView> createState() => _ProformaTabViewState();
}

class _ProformaTabViewState extends State<ProformaTabView> {
  List<dynamic> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  @override
  void didUpdateWidget(covariant ProformaTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project) {
      _fetchInvoices();
    }
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);
    final int psId = widget.project['id'] is int 
        ? widget.project['id'] 
        : int.tryParse(widget.project['id']?.toString() ?? '0') ?? 0;
    
    final data = await InvoiceService.getProformasByPostSales(psId);
    if (mounted) {
      setState(() {
        _invoices = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: AppColors.primary),
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Bar
          _buildSummaryBar(),
          const SizedBox(height: 20),
          
          // Header with "New Proforma" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Flexible(
                      child: Text('Proforma Invoices', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFACC15), borderRadius: BorderRadius.circular(12)),
                      child: Text('${_invoices.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (widget.user.role != UserRole.client)
                ElevatedButton.icon(
                  onPressed: () => _openCreateDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Proforma', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF78511E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
  
          if (_invoices.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final inv = _invoices[index];
                final bool isClient = widget.user.role == UserRole.client;
                return InvoiceCard(
                  invoice: inv,
                  isTax: false,
                  onDelete: isClient ? null : () => _handleDelete(inv['id']),
                  onView: () => _openPreview(inv),
                  onConvert: isClient ? null : () => _handleConvert(inv['id']),
                  onPaid: isClient ? null : () => _handleMarkPaid(inv),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _handleConvert(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Convert to Tax Invoice?'),
        content: const Text('This will create a Tax record and close this Proforma. This action is irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Convert', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await InvoiceService.convertToTax(id);
      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Converted to Tax Invoice successfully!')));
        widget.onRefresh?.call();
        widget.onTabRequest?.call(4); // Switch to Tax Invoices tab
        _fetchInvoices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Conversion failed')));
      }
    }
  }

  Future<void> _handleMarkPaid(Map<String, dynamic> inv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Paid?'),
        content: Text('Mark proforma ${inv['invoiceNumber']} as paid? This will enable conversion to a Tax Invoice.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mark Paid', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final int invId = inv['id'] is int ? inv['id'] : int.tryParse(inv['id']?.toString() ?? '0') ?? 0;
      final success = await InvoiceService.markProformaPaid(invId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proforma marked as Paid successfully!')));
        widget.onRefresh?.call();
        _fetchInvoices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update payment status')));
      }
    }
  }

  Widget _buildSummaryBar() {
    double totalValue = 0;
    int convertedCount = 0;
    double convertedValue = 0;

    for (var inv in _invoices) {
      double gross = (inv['grossAmount'] ?? 0.0).toDouble();
      totalValue += gross;
      if (inv['status'] == 'CONVERTED') {
        convertedCount++;
        convertedValue += gross;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryItem('${_invoices.length}', 'TOTAL'),
          _buildSummaryItem('$convertedCount', 'CONVERTED'),
          _buildSummaryItem('${_invoices.length - convertedCount}', 'DRAFT/SENT'),
          _buildSummaryItem('₹${totalValue.toStringAsFixed(2)}', 'TOTAL VALUE', isWide: true),
          _buildSummaryItem('₹${convertedValue.toStringAsFixed(2)}', 'CONVERTED VAL', isWide: true),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, {bool isWide = false}) {
    return Container(
      width: isWide ? 180 : 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CardContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          const Text('No proforma invoices generated yet.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => _openCreateDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Generate First Proforma'),
          ),
        ],
      ),
    );
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => ProformaInvoiceFormDialog(
        client: widget.project['client'] ?? {},
        postSalesId: widget.project['id'] is int 
            ? widget.project['id'] 
            : int.tryParse(widget.project['id']?.toString() ?? '0') ?? 0,
        onSuccess: () => _fetchInvoices(),
      ),
    );
  }

  void _openPreview(Map<String, dynamic> inv) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoiceReportView(invoice: inv, isTax: false)),
    );
  }

  Future<void> _handleDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: const Text('Are you sure you want to permanently delete this invoice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), 
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await InvoiceService.deleteProforma(id);
      if (success) {
        _fetchInvoices();
      }
    }
  }
}
