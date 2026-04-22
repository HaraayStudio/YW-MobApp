import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoicePdfHelper {
  static Future<Uint8List> generateInvoice({
    required Map<String, dynamic> invoice,
    required bool isTax,
  }) async {
    final pdf = pw.Document();
    
    final netAmount = (invoice['netAmount'] ?? 0.0).toDouble();
    final cgstAmount = (invoice['cgstAmount'] ?? 0.0).toDouble();
    final sgstAmount = (invoice['sgstAmount'] ?? 0.0).toDouble();
    final grossAmount = (invoice['grossAmount'] ?? 0.0).toDouble();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(isTax, invoice),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 1, color: PdfColors.black),
          pw.SizedBox(height: 10),
          pw.Text('GSTIN: ...........................................................', 
            style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 20),
          _buildClientDetails(invoice),
          pw.SizedBox(height: 30),
          _buildItemsTable(netAmount, cgstAmount, sgstAmount, grossAmount),
          pw.SizedBox(height: 30),
          _buildBankDetails(),
          pw.SizedBox(height: 40),
          _buildSignature(),
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(bool isTax, Map<String, dynamic> invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('YW ARCHITECTS',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Address :- Office No.313, Fortuna Business Hub,', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('Near Shivar Chouk, Pimple Saudagar, Pune - 411018', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('020 40038445, 9623901901', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('E-mail :- yogeshrw24@gmail.com', style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(isTax ? 'TAX INVOICE' : 'PROFORMA INVOICE',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            _buildHeaderRow('Invoice No.:', invoice['invoiceNumber'] ?? '--'),
            _buildHeaderRow('Date:', invoice['issueDate'] ?? '--'),
            if (!isTax) _buildHeaderRow('Valid Till:', invoice['validTill'] ?? '--'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderRow(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(width: 60, child: pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
        pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  static pw.Widget _buildClientDetails(Map<String, dynamic> invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('DETAILS OF CLIENT',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                children: [
                  _buildClientField('NAME:', invoice['clientName']),
                  _buildClientField('Address:', invoice['clientAddress']),
                  _buildClientField('Email:', invoice['clientEmail']),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('GSTIN :-', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(invoice['clientGstin'] ?? '........................', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildClientField(String label, dynamic value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 60, child: pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value?.toString() ?? '........................', style: const pw.TextStyle(fontSize: 9))),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(double net, double cgst, double sgst, double gross) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FixedColumnWidth(100),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('AMOUNT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.SizedBox(height: 60, child: pw.Text('Professional Fees as per the stages for architectural services.', style: const pw.TextStyle(fontSize: 9)))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('', style: const pw.TextStyle(fontSize: 9))),
          ],
        ),
        _buildTotalRow('Total Net Amount', net),
        _buildTotalRow('SGST Amount (9%)', sgst),
        _buildTotalRow('CGST Amount (9%)', cgst),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('GROSS TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${gross.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right)),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildTotalRow(String label, double amount) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(amount.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)),
      ],
    );
  }

  static pw.Widget _buildBankDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('PAYMENT DETAILS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Cheque in favour of: " YW ARCHITECTS "', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
        pw.SizedBox(height: 12),
        pw.Text('OR RTGS DETAILS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        _buildBankRow('ACCOUNT NAME :', 'YW ARCHITECTS'),
        _buildBankRow('ACCOUNT NO. :', '........................'),
        _buildBankRow('IFSC CODE :', '........................'),
        _buildBankRow('BRANCH :', '........................'),
      ],
    );
  }

  static pw.Widget _buildBankRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
          pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _buildSignature() {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        children: [
          pw.Container(width: 120, height: 0.5, color: PdfColors.black),
          pw.SizedBox(height: 4),
          pw.Text('Ar. Yogesh Wakchaure', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text('Authorized Signatory', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text('THANK YOU FOR YOUR BUSINESS!', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('020 40038445 | 9623901901 | yogeshrw24@gmail.com', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
        ],
      ),
    );
  }
}
