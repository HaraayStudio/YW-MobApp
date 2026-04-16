import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:yw_architects/models/app_models.dart';
import '../common_widgets.dart';
import 'invoice_forms.dart';
import 'invoice_card.dart';
import 'invoice_report_view.dart';
import '../../services/invoice_service.dart';

class TaxTabView extends StatefulWidget {
  final Map<String, dynamic> project;
  final AppUser user;
  final VoidCallback? onRefresh;

  const TaxTabView({
    Key? key,
    required this.project,
    required this.user,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<TaxTabView> createState() => _TaxTabViewState();
}

class _TaxTabViewState extends State<TaxTabView> {
  List<dynamic> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  @override
  void didUpdateWidget(covariant TaxTabView oldWidget) {
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
    
    final data = await InvoiceService.getTaxInvoicesByPostSales(psId);
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
          
          // Header with "New Tax Invoice" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Flexible(
                      child: Text('Tax Invoices', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis)),
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
                  label: const Text('New Tax Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
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
                  isTax: true,
                  onDelete: isClient ? null : () => _handleDelete(inv['id']),
                  onView: () => _openPreview(inv),
                  onPaid: isClient ? null : () => _handleMarkPaid(inv),
                );
              },
            ),
        ],
      ),
    );
  }

  void _handleMarkPaid(Map<String, dynamic> inv) {
    showDialog(
      context: context,
      builder: (_) => PaymentEntryDialog(
        invoice: inv,
        isTax: true,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded successfully!')));
          widget.onRefresh?.call();
          _fetchInvoices();
        },
      ),
    );
  }

  Widget _buildSummaryBar() {
    double totalGross = 0;
    double totalPaid = 0;

    for (var inv in _invoices) {
      double gross = (inv['grossAmount'] ?? 0.0).toDouble();
      totalGross += gross;
      
      final payments = inv['payments'] as List?;
      if (payments != null) {
        for (var p in payments) {
          totalPaid += (p['amountPaid'] ?? 0.0).toDouble();
        }
      }
    }

    double outstanding = totalGross - totalPaid;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryItem('${_invoices.length}', 'TOTAL INV'),
          _buildSummaryItem('₹${totalGross.toStringAsFixed(0)}', 'TOTAL BILLED', isWide: true),
          _buildSummaryItem('₹${totalPaid.toStringAsFixed(0)}', 'TOTAL RECEIVED', isWide: true, isGreen: true),
          _buildSummaryItem('₹${outstanding.toStringAsFixed(0)}', 'OUTSTANDING', isWide: true, isRed: outstanding > 0),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, {bool isWide = false, bool isGreen = false, bool isRed = false}) {
    Color valColor = const Color(0xFF1E293B);
    if (isGreen) valColor = Colors.green.shade700;
    if (isRed) valColor = Colors.red.shade700;

    return Container(
      width: isWide ? 150 : 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, 
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: valColor),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CardContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.receipt_rounded, size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          const Text('No tax invoices generated yet.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => _openCreateDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Generate First Tax Invoice'),
          ),
        ],
      ),
    );
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => TaxInvoiceFormDialog(
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
      MaterialPageRoute(builder: (_) => InvoiceReportView(invoice: inv, isTax: true)),
    );
  }

  Future<void> _handleDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: const Text('Are you sure you want to permanently delete this tax invoice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), 
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await InvoiceService.deleteTaxInvoice(id);
      if (success) {
        _fetchInvoices();
      }
    }
  }
}
