import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InvoiceReportView extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final bool isTax;

  const InvoiceReportView({
    Key? key,
    required this.invoice,
    required this.isTax,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isTax ? 'Tax Invoice' : 'Proforma Invoice',
            style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        actions: [
          _buildHeaderButton(Icons.print_outlined, 'Print', () {}),
          const SizedBox(width: 8),
          _buildHeaderButton(Icons.download_outlined, 'Download PDF', () {}, isPrimary: true),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Container(
            width: 850, // A4-ish width
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YW ARCHITECTS',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        _buildHeaderInfo('Address :- Office No.313, Fortuna Business Hub, Near Shivar Chouk, Pimple Saudagar, Pune - 411018'),
                        _buildHeaderInfo('020 40038445, 9623901901'),
                        _buildHeaderInfo('E-mail :- yogeshrw24@gmail.com'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(isTax ? 'TAX INVOICE' : 'PROFORMA INVOICE',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                        const SizedBox(height: 12),
                        _buildInfoRow('Invoice No.', invoice['invoiceNumber'] ?? '--'),
                        _buildInfoRow('Date', invoice['issueDate'] ?? '--'),
                        if (!isTax) _buildInfoRow('Valid Till', invoice['validTill'] ?? '--'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Colors.black),
                const SizedBox(height: 10),
                const Text('GSTIN: ...........................................................',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 30),
                
                // Details of Client
                const Text('DETAILS OF CLIENT',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildClientRow('NAME', invoice['clientName']),
                          _buildClientRow('Address', invoice['clientAddress']),
                          _buildClientRow('Email', invoice['clientEmail']),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('GSTIN :-', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(invoice['clientGstin'] ?? '...........................................................',
                                style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Description Table
                _buildTable([
                  _buildTableRow(['DESCRIPTION', 'AMOUNT'], isHeader: true),
                  _buildTableRow([
                    'Payment required as per the stages for the proposed residential & commercial at, Sr. No. Adhya Ratan',
                    ''
                  ], height: 80),
                  _buildTableRow(['Total Net Amount', '₹${(invoice['netAmount'] ?? 0.0).toStringAsFixed(2)}']),
                  _buildTableRow(['State Tax (SGST) 9%', '₹${(invoice['sgstAmount'] ?? 0.0).toStringAsFixed(2)}']),
                  _buildTableRow(['Central Tax (CGST) 9%', '₹${(invoice['cgstAmount'] ?? 0.0).toStringAsFixed(2)}']),
                  _buildTableRow(['GROSS TOTAL AMOUNT', '₹${(invoice['grossAmount'] ?? 0.0).toStringAsFixed(2)}'], isFooter: true),
                ]),
                
                const SizedBox(height: 40),
                
                // Payments Received
                const Text('PAYMENTS RECEIVED',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                _buildTable([
                  _buildTableRow(['DATE', 'MODE', 'TRANSACTION ID', 'AMOUNT', 'REMARKS'], isHeader: true),
                  _buildTableRow(['--', '--', '--', '--', '--']),
                  _buildTableRow(['Total Received', '', '', '₹0.00', ''], isFooter: true),
                ]),
                
                const SizedBox(height: 40),
                
                // Footer details
                const Text('PAYMENT DETAILS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text('Please issue the cheque in favour of\n" YW ARCHITECTS "',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                const Text('OR\nRTGS DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                _buildBankInfo('ACCOUNT NAME :', 'YW ARCHITECTS'),
                _buildBankInfo('ACCOUNT NO. :', '.......................................'),
                _buildBankInfo('IFSC CODE :', '.......................................'),
                _buildBankInfo('BRANCH :', '.......................................'),
                _buildBankInfo('BANK :', '.......................................'),
                
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      Container(width: 150, height: 1, color: Colors.black),
                      const SizedBox(height: 8),
                      const Text('Ar. Yogesh Wakchaure',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const Text('Authorized Signatory', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                const Center(
                  child: Column(
                    children: [
                      Text('THANK YOU FOR YOUR BUSINESS!',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('020 40038445 | 9623901901 | yogeshrw24@gmail.com',
                          style: TextStyle(fontSize: 10, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF78511E) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0))),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildClientRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
          Expanded(child: Text(value?.toString() ?? '.......................................', style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildTable(List<TableRow> rows) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FixedColumnWidth(150),
      },
      border: TableBorder.all(color: const Color(0xFFE2E8F0)),
      children: rows,
    );
  }

  TableRow _buildTableRow(List<String> cells,
      {bool isHeader = false, bool isFooter = false, double height = 35}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFF1F5F9) : Colors.white,
      ),
      children: cells.map((cell) {
        return Container(
          height: height,
          alignment: cell.startsWith('₹') ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            cell,
            style: TextStyle(
                fontSize: 11,
                fontWeight: (isHeader || isFooter) ? FontWeight.w900 : FontWeight.w500,
                color: const Color(0xFF1E293B)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBankInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          Text(value, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
