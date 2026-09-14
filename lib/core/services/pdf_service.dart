import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/receipt_model.dart';

class PdfService {
  /// Generate Receipt Document
  static Future<Uint8List> generateReceiptPdf(ReceiptModel receipt) async {
    final pdf = pw.Document();

    final isBengali = receipt.receiptLang == 'bn';
    final currencySymbol = isBengali ? 'BDT ' : 'BDT ';

    // Format created date
    final dateStr = DateFormat('MMMM dd, yyyy').format(receipt.createdAt);

    // Color constants for PDF
    final primaryBlue = PdfColor.fromHex('#0F4C75');
    final darkNavy = PdfColor.fromHex('#1B3A5C');
    final gold = PdfColor.fromHex('#F2A33C');
    final slateBg = PdfColor.fromHex('#F8FAFC');
    final cardBg = PdfColor.fromHex('#EFF6FF');
    final cardBorder = PdfColor.fromHex('#BFDBFE');
    final textDark = PdfColor.fromHex('#1E293B');
    final textMuted = PdfColor.fromHex('#64748B');

    // Payment method string
    String paymentMethodLabel = receipt.paymentMethod.replaceAll('_', ' ').toUpperCase();
    if (receipt.paymentMethod == 'cash') {
      paymentMethodLabel = isBengali ? 'CASH (নগদ)' : 'CASH';
    } else if (receipt.paymentMethod == 'bank_transfer') {
      paymentMethodLabel = isBengali ? 'BANK TRANSFER (ব্যাংক)' : 'BANK TRANSFER';
    } else if (receipt.paymentMethod == 'mobile_banking') {
      paymentMethodLabel = isBengali ? 'MOBILE BANKING (বিকাশ/নগদ)' : 'MOBILE BANKING (bKash/Nagad)';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: primaryBlue,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RENTEZZI',
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'SMART RENT MANAGEMENT PLATFORM',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: darkNavy,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColors.white, width: 0.5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            isBengali ? 'রসিদ নং / RECEIPT ID' : 'RECEIPT ID',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            '#${receipt.id.length > 8 ? receipt.id.substring(0, 8).toUpperCase() : receipt.id.toUpperCase()}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Gold accent bar
              pw.Container(
                height: 4,
                color: gold,
                margin: const pw.EdgeInsets.only(bottom: 18),
              ),

              // Title and Date Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        isBengali ? 'ভাড়া পরিশোধের রসিদ (RENT RECEIPT)' : 'OFFICIAL RENT RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Official Payment Acknowledgment',
                        style: pw.TextStyle(fontSize: 10, color: textMuted),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Date: $dateStr',
                    style: pw.TextStyle(fontSize: 10, color: textMuted),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Property & Unit Card
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: cardBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: cardBorder, width: 1),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'PROPERTY / ভবন',
                            style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            receipt.propertyName ?? 'Main Residence',
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: textDark),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'ADDRESS / ঠিকানা',
                            style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            receipt.propertyAddress,
                            style: pw.TextStyle(fontSize: 11, color: textDark),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'UNIT / FLAT / ফ্ল্যাট',
                            style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            receipt.unitName ?? 'Entire Property',
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: textDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // Month & Total Highlight Card
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: pw.BoxDecoration(
                  color: slateBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TOTAL AMOUNT PAID / মোট পরিশোধিত টাকা',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textMuted),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '$currencySymbol${NumberFormat('#,##,###').format(receipt.totalAmount)}',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: gold,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'FOR MONTH / মাস',
                            style: const pw.TextStyle(fontSize: 7, color: PdfColors.white),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            receipt.monthYear,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Billing Breakdown Table
              pw.Text(
                'BILLING BREAKDOWN / ভাড়ার বিস্তারিত হিসাব',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textMuted),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                  horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                ),
                children: [
                  _buildTableRow('House Rent / বাড়ি ভাড়া', receipt.rentAmount, currencySymbol),
                  if (receipt.waterBill != null && receipt.waterBill! > 0)
                    _buildTableRow('Water Bill / পানির বিল', receipt.waterBill!, currencySymbol),
                  if (receipt.gasBill != null && receipt.gasBill! > 0)
                    _buildTableRow('Gas Bill / গ্যাস বিল', receipt.gasBill!, currencySymbol),
                  if (receipt.otherBills != null && receipt.otherBills! > 0)
                    _buildTableRow('Other Utility Bills / অন্যান্য বিল', receipt.otherBills!, currencySymbol),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Net Total / সর্বমোট',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryBlue),
                  ),
                  pw.Text(
                    '$currencySymbol${NumberFormat('#,##,###').format(receipt.totalAmount)}',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryBlue),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Tenant & Landlord Information Grid
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoPair('TENANT NAME / ভাড়াটিয়া', receipt.tenantName),
                        pw.SizedBox(height: 8),
                        _buildInfoPair('TENANT PHONE', receipt.tenantPhone ?? '—'),
                        pw.SizedBox(height: 8),
                        _buildInfoPair('PAYMENT DATE', receipt.paymentDate),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoPair('LANDLORD / বাড়িওয়ালা', receipt.landlordName ?? '—'),
                        pw.SizedBox(height: 8),
                        _buildInfoPair('LANDLORD PHONE', receipt.landlordPhone ?? '—'),
                        pw.SizedBox(height: 8),
                        _buildInfoPair('PAYMENT METHOD', paymentMethodLabel),
                      ],
                    ),
                  ),
                ],
              ),

              if (receipt.notes != null && receipt.notes!.trim().isNotEmpty) ...[
                pw.SizedBox(height: 14),
                pw.Text(
                  'NOTES / মন্তব্য:',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textMuted),
                ),
                pw.SizedBox(height: 3),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: slateBg,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  ),
                  child: pw.Text(
                    receipt.notes!,
                    style: pw.TextStyle(fontSize: 9, color: textDark),
                  ),
                ),
              ],

              pw.Spacer(),

              // Signature Line
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 140,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 1)),
                        ),
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Center(
                          child: pw.Text(
                            'Authorized Signature / স্বাক্ষর',
                            style: pw.TextStyle(fontSize: 8, color: textMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // Footer Divider & text
              pw.Container(height: 1, color: gold, margin: const pw.EdgeInsets.only(bottom: 8)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'This is a computer-generated receipt and does not require a physical signature.',
                    style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                  ),
                  pw.Text(
                    'Powered by Rentezzi Mobile',
                    style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryBlue),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildTableRow(String title, num amount, String currency) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Text(
            '$currency${NumberFormat('#,##,###').format(amount)}',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoPair(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
        ),
      ],
    );
  }

  /// Preview / Print / Save PDF using standard OS dialog
  static Future<void> printOrSharePdf(ReceiptModel receipt) async {
    final pdfBytes = await generateReceiptPdf(receipt);
    final filename = 'Rent-Receipt-${receipt.tenantName.replaceAll(RegExp(r'\s+'), '-')}-${receipt.monthYear.replaceAll(RegExp(r'\s+'), '-')}.pdf';
    
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: filename,
    );
  }

  static Future<void> printOrShareReceipt(ReceiptModel receipt) => printOrSharePdf(receipt);
}
