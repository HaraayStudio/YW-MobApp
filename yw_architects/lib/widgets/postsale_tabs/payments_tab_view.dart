import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:yw_architects/models/app_models.dart';
import '../common_widgets.dart';
import 'invoice_forms.dart';
import '../../services/invoice_service.dart';

class PaymentsTabView extends StatefulWidget {
  final Map<String, dynamic> project;
  final AppUser user;
  final VoidCallback? onRefresh;

  const PaymentsTabView({
    Key? key,
    required this.project,
    required this.user,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<PaymentsTabView> createState() => _PaymentsTabViewState();
}

class _PaymentsTabViewState extends State<PaymentsTabView> {
  List<dynamic> _taxInvoices = [];
  List<Map<String, dynamic>> _allPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant PaymentsTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final int psId = widget.project['id'] is int 
        ? widget.project['id'] 
        : int.tryParse(widget.project['id']?.toString() ?? '0') ?? 0;

    final invoices = await InvoiceService.getTaxInvoicesByPostSales(psId);
    
    final flattened = <Map<String, dynamic>>[];
    for (var ti in invoices) {
      final payments = ti['payments'] as List?;
      if (payments != null) {
        for (var p in payments) {
          final pMap = Map<String, dynamic>.from(p);
          pMap['invoiceNumber'] = ti['invoiceNumber'] ?? 'TI-${ti['id']}';
          flattened.add(pMap);
        }
      }
    }

    // Sort newest first
    flattened.sort((a, b) {
      final da = DateTime.tryParse(a['paymentDate']?.toString() ?? '') ?? DateTime(0);
      final db = DateTime.tryParse(b['paymentDate']?.toString() ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });

    if (mounted) {
      setState(() {
        _taxInvoices = invoices;
        _allPayments = flattened;
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

    final totalReceived = _allPayments.fold<double>(0, (sum, p) => sum + (p['amountPaid'] ?? 0.0).toDouble());
    final totalGross = _taxInvoices.fold<double>(0, (sum, ti) => sum + (ti['grossAmount'] ?? 0.0).toDouble());
    final outstanding = totalGross - totalReceived;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Financial Stats cards Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard('₹${totalReceived.toStringAsFixed(0)}', 'TOTAL RECEIVED', isGreen: true),
                _buildStatCard('₹${totalGross.toStringAsFixed(0)}', 'TOTAL BILLED', isBlue: true),
                _buildStatCard('₹${outstanding.toStringAsFixed(0)}', 'OUTSTANDING', isRed: outstanding > 0),
                _buildStatCard('${_allPayments.length}', 'PAYMENTS'),
              ],
            ),
          ),
          const SizedBox(height: 24),
  
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Payment History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              if (widget.user.role != UserRole.client)
                ElevatedButton.icon(
                  onPressed: _taxInvoices.isEmpty 
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please generate a Tax Invoice first to record payments.'))
                        );
                      }
                    : () => _handleRecordPayment(),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_allPayments.isEmpty)
            CardContainer(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.credit_card_rounded, size: 48, color: AppColors.outlineVariant),
                  const SizedBox(height: 16),
                  const Text(
                    'No payments recorded yet',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _taxInvoices.isEmpty 
                      ? 'Generate a tax invoice first to record payments.' 
                      : 'Record activity by clicking the button above or in the Tax Invoices tab.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allPayments.length,
              itemBuilder: (context, index) {
                final p = _allPayments[index];
                return _buildPaymentCard(p);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {bool isGreen = false, bool isBlue = false, bool isRed = false}) {
    Color accent = const Color(0xFF1E293B);
    if (isGreen) accent = Colors.green.shade600;
    if (isBlue) accent = Colors.blue.shade600;
    if (isRed) accent = Colors.red.shade600;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text(value, 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: accent),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }



  void _handleRecordPayment() {
    // If multiple invoices exist, the dialog could be updated to allow selection.
    // In the web app, a selection is available. For now, we use the latest unpaid/active invoice
    // to ensure the button works immediately.


    showDialog(
      context: context,
      builder: (_) => PaymentEntryDialog(
        taxInvoices: _taxInvoices,
        isTax: true,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded!')));
          widget.onRefresh?.call();
          _fetchData();
        },
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> p) {
    final mode = p['paymentMode']?.toString() ?? 'CASH';
    double amount = (p['amountPaid'] ?? 0.0).toDouble();
    final date = p['paymentDate']?.toString().split('T').first ?? '—';
    final invNum = p['invoiceNumber']?.toString() ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
            child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text(mode, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ref: $invNum',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                if (p['remarks'] != null && p['remarks'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    p['remarks'],
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


