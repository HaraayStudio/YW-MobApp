import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/invoice_service.dart';

class TaxInvoiceFormDialog extends StatefulWidget {
  final Map<String, dynamic> client;
  final int postSalesId;
  final VoidCallback onSuccess;

  const TaxInvoiceFormDialog({Key? key, required this.client, required this.postSalesId, required this.onSuccess}) : super(key: key);

  @override
  State<TaxInvoiceFormDialog> createState() => _TaxInvoiceFormDialogState();
}

class _TaxInvoiceFormDialogState extends State<TaxInvoiceFormDialog> {
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _gstinController = TextEditingController();
  final _addressController = TextEditingController();

  final _netAmountController = TextEditingController();
  final _cgstController = TextEditingController();
  final _sgstController = TextEditingController();
  final _grossAmountController = TextEditingController();
  final _amountWordsController = TextEditingController();

  double _cgstAmtValue = 0.0;
  double _sgstAmtValue = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _clientNameController.text = widget.client['name']?.toString() ?? '';
    _clientEmailController.text = widget.client['email']?.toString() ?? '';
    _clientPhoneController.text = widget.client['phone']?.toString() ?? '';
    _gstinController.text = widget.client['gstNumber']?.toString() ?? widget.client['gstin']?.toString() ?? '';
    _addressController.text = widget.client['address']?.toString() ?? '';

    _netAmountController.addListener(_calculateGross);
    _cgstController.addListener(_calculateGross);
    _sgstController.addListener(_calculateGross);
  }

  void _calculateGross() {
    final net = double.tryParse(_netAmountController.text) ?? 0.0;
    final cgst = double.tryParse(_cgstController.text) ?? 0.0;
    final sgst = double.tryParse(_sgstController.text) ?? 0.0;
    if (net > 0) {
      _cgstAmtValue = net * (cgst / 100);
      _sgstAmtValue = net * (sgst / 100);
      final gross = net + _cgstAmtValue + _sgstAmtValue;
      _grossAmountController.text = gross.toStringAsFixed(2);
    } else {
      _cgstAmtValue = 0.0;
      _sgstAmtValue = 0.0;
      _grossAmountController.text = '';
    }
    setState(() {});
  }

  Future<void> _submitRecord() async {
    if (_netAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Net Amount is required')));
      return;
    }

    setState(() => _isSubmitting = true);
    final payload = {
      "clientName": _clientNameController.text,
      "clientEmail": _clientEmailController.text,
      "clientPhone": _clientPhoneController.text,
      "clientAddress": _addressController.text,
      "clientGstin": _gstinController.text,
      "netAmount": double.tryParse(_netAmountController.text) ?? 0.0,
      "cgstAmount": _cgstAmtValue,
      "sgstAmount": _sgstAmtValue,
      "grossAmount": double.tryParse(_grossAmountController.text) ?? 0.0,
      "amountInWords": _amountWordsController.text,
    };

    final res = await InvoiceService.createTaxInvoice(widget.postSalesId, payload);
    setState(() => _isSubmitting = false);

    if (res['success']) {
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed to submit')));
      }
    }
  }

  Widget _buildCalculatedAmount(double amount) {
    if (amount <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFBFDBFE))),
            child: Text('= ₹${amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    final net = double.tryParse(_netAmountController.text) ?? 0.0;
    final gross = double.tryParse(_grossAmountController.text) ?? 0.0;
    final cgst = double.tryParse(_cgstController.text) ?? 0;
    final sgst = double.tryParse(_sgstController.text) ?? 0;
    
    if (net == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          _buildSummaryItem('NET', '₹${net.toStringAsFixed(0)}'),
          const Text('+', style: TextStyle(color: AppColors.outlineVariant)),
          _buildSummaryItem('CGST ${cgst.toStringAsFixed(0)}%', '₹${_cgstAmtValue.toStringAsFixed(2)}'),
          const Text('+', style: TextStyle(color: AppColors.outlineVariant)),
          _buildSummaryItem('SGST ${sgst.toStringAsFixed(0)}%', '₹${_sgstAmtValue.toStringAsFixed(2)}'),
          const Text('='),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              border: Border.all(color: const Color(0xFFFCD34D)),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Column(
              children: [
                const Text('GROSS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                Text('₹${gross.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
              ],
            )
          )
        ],
      )
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: const Color(0xFF1E293B), // Dark blue slate
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 16, color: Color(0xFF334155)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Tax Invoice', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Invoice number will be auto-generated', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Client Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Color(0xFF6366F1)),
                              SizedBox(width: 8),
                              Text('CLIENT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildField('CLIENT NAME', _clientNameController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('CLIENT EMAIL', _clientEmailController)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildField('CLIENT PHONE', _clientPhoneController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('GSTIN', _gstinController, hint: 'E.G. 27AAAAA0000A1Z5')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildField('ADDRESS', _addressController, hint: 'Full billing address', maxLines: 3),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Amount Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.monetization_on, size: 16, color: Color(0xFFD97706)),
                                  SizedBox(width: 8),
                                  Text('AMOUNT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
                                child: const Text('CGST & SGST amounts auto-calculated from %', style: TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildField('NET AMOUNT (₹) *', _netAmountController, hint: '0.00')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('CGST (%)', _cgstController, hint: 'e.g. 9', suffix: _buildCalculatedAmount(_cgstAmtValue))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildField('SGST (%)', _sgstController, hint: 'e.g. 9', suffix: _buildCalculatedAmount(_sgstAmtValue))),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('GROSS AMOUNT (₹) *', _grossAmountController, hint: 'Auto-calculated', readOnly: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildField('AMOUNT IN WORDS', _amountWordsController, hint: 'e.g. Rupees Fifty Thousand Only'),
                          _buildSummaryBar(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitRecord,
                    icon: _isSubmitting 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.request_quote_rounded, size: 18),
                    label: const Text('Create Tax Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildField(String label, TextEditingController controller, {String hint = '', bool readOnly = false, int maxLines = 1, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14, color: readOnly ? AppColors.onSurfaceVariant : AppColors.onSurface, fontWeight: readOnly ? FontWeight.bold : FontWeight.normal),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            hintStyle: TextStyle(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
          ),
        ),
      ],
    );
  }
}

class ProformaInvoiceFormDialog extends StatefulWidget {
  final Map<String, dynamic> client;
  final int postSalesId;
  final VoidCallback onSuccess;

  const ProformaInvoiceFormDialog({Key? key, required this.client, required this.postSalesId, required this.onSuccess}) : super(key: key);

  @override
  State<ProformaInvoiceFormDialog> createState() => _ProformaInvoiceFormDialogState();
}

class _ProformaInvoiceFormDialogState extends State<ProformaInvoiceFormDialog> {
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _gstinController = TextEditingController();
  final _addressController = TextEditingController();

  final _netAmountController = TextEditingController();
  final _cgstController = TextEditingController();
  final _sgstController = TextEditingController();
  final _grossAmountController = TextEditingController();
  final _amountWordsController = TextEditingController();
  DateTime? _validTill;

  double _cgstAmtValue = 0.0;
  double _sgstAmtValue = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _clientNameController.text = widget.client['name']?.toString() ?? '';
    _clientEmailController.text = widget.client['email']?.toString() ?? '';
    _clientPhoneController.text = widget.client['phone']?.toString() ?? '';
    _gstinController.text = widget.client['gstNumber']?.toString() ?? widget.client['gstin']?.toString() ?? '';
    _addressController.text = widget.client['address']?.toString() ?? '';

    _netAmountController.addListener(_calculateGross);
    _cgstController.addListener(_calculateGross);
    _sgstController.addListener(_calculateGross);
  }

  void _calculateGross() {
    final net = double.tryParse(_netAmountController.text) ?? 0.0;
    final cgst = double.tryParse(_cgstController.text) ?? 0.0;
    final sgst = double.tryParse(_sgstController.text) ?? 0.0;
    if (net > 0) {
      _cgstAmtValue = net * (cgst / 100);
      _sgstAmtValue = net * (sgst / 100);
      final gross = net + _cgstAmtValue + _sgstAmtValue;
      _grossAmountController.text = gross.toStringAsFixed(2);
    } else {
      _cgstAmtValue = 0.0;
      _sgstAmtValue = 0.0;
      _grossAmountController.text = '';
    }
    setState(() {});
  }

  Future<void> _submitRecord() async {
    if (_netAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Net Amount is required')));
      return;
    }

    setState(() => _isSubmitting = true);
    final payload = {
      "clientName": _clientNameController.text,
      "clientEmail": _clientEmailController.text,
      "clientPhone": _clientPhoneController.text,
      "clientAddress": _addressController.text,
      "clientGstin": _gstinController.text,
      "netAmount": double.tryParse(_netAmountController.text) ?? 0.0,
      "cgstAmount": _cgstAmtValue,
      "sgstAmount": _sgstAmtValue,
      "grossAmount": double.tryParse(_grossAmountController.text) ?? 0.0,
      "amountInWords": _amountWordsController.text,
      "validTill": _validTill?.toIso8601String().split('T')[0], // YYYY-MM-DD
    };

    final res = await InvoiceService.createProformaInvoice(widget.postSalesId, payload);
    setState(() => _isSubmitting = false);

    if (res['success']) {
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed to submit')));
      }
    }
  }

  Widget _buildCalculatedAmount(double amount) {
    if (amount <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFBFDBFE))),
            child: Text('= ₹${amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    final net = double.tryParse(_netAmountController.text) ?? 0.0;
    final gross = double.tryParse(_grossAmountController.text) ?? 0.0;
    final cgst = double.tryParse(_cgstController.text) ?? 0;
    final sgst = double.tryParse(_sgstController.text) ?? 0;
    
    if (net == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          _buildSummaryItem('NET', '₹${net.toStringAsFixed(0)}'),
          const Text('+', style: TextStyle(color: AppColors.outlineVariant)),
          _buildSummaryItem('CGST ${cgst.toStringAsFixed(0)}%', '₹${_cgstAmtValue.toStringAsFixed(2)}'),
          const Text('+', style: TextStyle(color: AppColors.outlineVariant)),
          _buildSummaryItem('SGST ${sgst.toStringAsFixed(0)}%', '₹${_sgstAmtValue.toStringAsFixed(2)}'),
          const Text('='),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              border: Border.all(color: const Color(0xFFFCD34D)),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Column(
              children: [
                const Text('GROSS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                Text('₹${gross.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
              ],
            )
          )
        ],
      )
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: const Color(0xFF6B4210), // Bronze/Gold color matching the screenshot
              child: Row(
                children: [
                  const Icon(Icons.circle_rounded, size: 16, color: Color(0xFF8B5E34)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Proforma Invoice', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Invoice number will be auto-generated', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Client Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Color(0xFF6366F1)),
                              SizedBox(width: 8),
                              Text('CLIENT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildField('CLIENT NAME', _clientNameController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('CLIENT EMAIL', _clientEmailController)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildField('CLIENT PHONE', _clientPhoneController)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('GSTIN', _gstinController, hint: 'E.G. 27AAAAA0000A1Z5')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildField('ADDRESS', _addressController, hint: 'Full billing address', maxLines: 3),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Amount Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.monetization_on, size: 16, color: Color(0xFFD97706)),
                                  SizedBox(width: 8),
                                  Text('AMOUNT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
                                child: const Text('CGST & SGST amounts auto-calculated from %', style: TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildField('NET AMOUNT (₹) *', _netAmountController, hint: '0.00')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('CGST (%)', _cgstController, hint: 'e.g. 9', suffix: _buildCalculatedAmount(_cgstAmtValue))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildField('SGST (%)', _sgstController, hint: 'e.g. 9', suffix: _buildCalculatedAmount(_sgstAmtValue))),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('GROSS AMOUNT (₹) *', _grossAmountController, hint: 'Auto-calculated', readOnly: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildField('AMOUNT IN WORDS', _amountWordsController, hint: 'e.g. Rupees Fifty Thousand Only'),
                          _buildSummaryBar(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Validity Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_month, size: 18, color: Color(0xFF6366F1)),
                              SizedBox(width: 8),
                              Text('VALIDITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('VALID TILL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 30)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2040),
                                  );
                                  if (d != null) {
                                    setState(() => _validTill = d);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _validTill != null ? '${_validTill!.day.toString().padLeft(2, '0')}-${_validTill!.month.toString().padLeft(2, '0')}-${_validTill!.year}' : 'dd-mm-yyyy',
                                        style: TextStyle(color: _validTill != null ? AppColors.onSurface : AppColors.onSurfaceVariant),
                                      ),
                                      const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF64748B)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitRecord,
                    icon: _isSubmitting 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.assignment_rounded, size: 18),
                    label: const Text('Create Proforma', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF78511E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildField(String label, TextEditingController controller, {String hint = '', bool readOnly = false, int maxLines = 1, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14, color: readOnly ? AppColors.onSurfaceVariant : AppColors.onSurface, fontWeight: readOnly ? FontWeight.bold : FontWeight.normal),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            hintStyle: TextStyle(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
          ),
        ),
      ],
    );
  }
}

class PaymentEntryDialog extends StatefulWidget {
  final Map<String, dynamic>? invoice; // Optional if taxInvoices is provided
  final List<dynamic>? taxInvoices;    // Optional list for selection
  final bool isTax;
  final VoidCallback onSuccess;

  const PaymentEntryDialog({
    Key? key,
    this.invoice,
    this.taxInvoices,
    required this.isTax,
    required this.onSuccess,
  }) : assert(invoice != null || taxInvoices != null), super(key: key);

  @override
  State<PaymentEntryDialog> createState() => _PaymentEntryDialogState();
}

class _PaymentEntryDialogState extends State<PaymentEntryDialog> {
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _remarksController = TextEditingController();
  String _paymentMode = 'CASH';
  DateTime _paymentDate = DateTime.now();
  bool _isSubmitting = false;
  
  Map<String, dynamic>? _selectedInvoice;
  double _alreadyPaid = 0;
  double _outstanding = 0;

  @override
  void initState() {
    super.initState();
    _selectedInvoice = widget.invoice ?? (widget.taxInvoices?.isNotEmpty == true ? (widget.taxInvoices!.first as Map<String, dynamic>) : null);
    _calculateBalances();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _calculateBalances() {
    if (_selectedInvoice == null) return;
    
    final double gross = (_selectedInvoice!['grossAmount'] ?? 0.0).toDouble();
    double paid = 0;
    final payments = _selectedInvoice!['payments'] as List?;
    if (payments != null) {
      for (var p in payments) {
        paid += (p['amountPaid'] ?? 0.0).toDouble();
      }
    }
    
    _alreadyPaid = paid;
    _outstanding = gross - paid;
    if (_outstanding < 0) _outstanding = 0;
    
    _amountController.text = _outstanding.toStringAsFixed(2);
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      "amountPaid": amount,
      "paymentDate": _paymentDate.toIso8601String().split('T')[0],
      "paymentMode": _paymentMode,
      "transactionId": _transactionIdController.text.isEmpty ? null : _transactionIdController.text,
      "remarks": _remarksController.text.isEmpty ? null : _remarksController.text,
    };

    final invoiceNumber = _selectedInvoice?['invoiceNumber']?.toString() ?? _selectedInvoice?['id']?.toString();
    if (invoiceNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Invoice not selected or missing identifier')));
      setState(() => _isSubmitting = false);
      return;
    }

    final success = await InvoiceService.makeInvoicePaid(invoiceNumber, payload);
    setState(() => _isSubmitting = false);

    if (success) {
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        // Fallback or more info if needed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to record payment. Please check if the invoice exists and is unpaid.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.green.shade700,
              child: const Row(
                children: [
                  Icon(Icons.payments_outlined, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Record Payment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.taxInvoices != null && widget.taxInvoices!.isNotEmpty)
                    _buildInvoiceSelectionDropdown()
                  else
                    Text('Invoice: ${_selectedInvoice?['invoiceNumber'] ?? 'N/A'}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                  
                  if (_selectedInvoice != null) ...[
                    const SizedBox(height: 12),
                    _buildSummaryStrip(),
                  ],
                  const SizedBox(height: 20),
                  _buildField('AMOUNT PAID (₹)', _amountController),
                  const SizedBox(height: 16),
                  _buildPaymentModeDropdown(),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 16),
                  _buildField('TRANSACTION ID / REF', _transactionIdController, hint: 'Optional'),
                  const SizedBox(height: 16),
                  _buildField('REMARKS', _remarksController, hint: 'Optional'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isSubmitting 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
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

  Widget _buildField(String label, TextEditingController controller, {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.green.shade700, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PAYMENT MODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _paymentMode,
              isExpanded: true,
              items: ['CASH', 'RTGS', 'CHEQUE', 'NEFT', 'IMPS', 'UPI', 'BANK_TRANSFER']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _paymentMode = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PAYMENT DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _paymentDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (d != null) setState(() => _paymentDate = d);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_paymentDate.day}-${_paymentDate.month}-${_paymentDate.year}'),
                const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSelectionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SELECT INVOICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedInvoice,
              isExpanded: true,
              hint: const Text('Select target invoice'),
              items: widget.taxInvoices!.map((ti) {
                final Map<String, dynamic> tiMap = ti as Map<String, dynamic>;
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: tiMap,
                  child: Text('${tiMap['invoiceNumber'] ?? 'Inv #${tiMap['id']}'}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedInvoice = val;
                    _calculateBalances();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStrip() {
    if (_selectedInvoice == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('Gross', _selectedInvoice!['grossAmount']),
          _buildSummaryItem('Paid', _alreadyPaid, color: Colors.green.shade700),
          _buildSummaryItem('Outstanding', _outstanding, color: _outstanding > 0 ? Colors.red.shade700 : Colors.green.shade700),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic val, {Color? color}) {
    double amount = (val ?? 0.0).toDouble();
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 2),
        Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}
