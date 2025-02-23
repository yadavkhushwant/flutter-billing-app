import 'dart:io';
import 'dart:typed_data';
import 'package:billing_application/data/db_crud.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateInvoicePdf(Map<String, dynamic> data) async {
  // Fetch business settings from the database.
  final settings = await SettingsRepository().getSettings() ?? {};
  final businessName = settings['business_name'] ?? 'Codemantri';
  final businessAddress = settings['address'] ?? 'Basdila Bujurg, Salemgarh, Kushinagar, 274409';
  final businessEmail = settings['email'] ?? 'codemantriofficial@gmail.com';
  final businessPhone = settings['contact_number'] ?? '8858013899';
  final logoPath = settings['logo'] ?? '';

  // Load the logo image bytes if a valid path is provided.
  Uint8List? logoBytes;
  if (logoPath.isNotEmpty) {
    final file = File(logoPath);
    if (await file.exists()) {
      logoBytes = await file.readAsBytes();
    }
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        // 1. Title "Invoice"
        pw.Center(
          child: pw.Text(
            "Invoice",
            style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        // 2. Company logo, name, address, contact details
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Company Logo: show image if available; otherwise, a placeholder.
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              child: logoBytes != null
                  ? pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain)
                  : pw.Center(
                child: pw.Text("Logo", style: pw.TextStyle(fontSize: 12)),
              ),
            ),
            pw.SizedBox(width: 20),
            // Company Details: fetched from settings.
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(businessName,
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(businessAddress, style: pw.TextStyle(fontSize: 12)),
                pw.Text("Contact: $businessEmail",
                    style: pw.TextStyle(fontSize: 12)),
                pw.Text("Phone: $businessPhone",
                    style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        // 3. Invoice number and date
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Invoice No: ${data['invoiceNumber']}",
                style: pw.TextStyle(fontSize: 14)),
            pw.Text("Date: ${data['invoiceDate']}",
                style: pw.TextStyle(fontSize: 14)),
          ],
        ),
        pw.SizedBox(height: 20),
        // 4. Customer details
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Customer Details",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Name: ${data['selectedCustomerDetails']['name'] ?? ''}",
                  style: pw.TextStyle(fontSize: 12)),
              pw.Text(
                  "Address: ${data['selectedCustomerDetails']['locality'] ?? ''}, ${data['selectedCustomerDetails']['city'] ?? ''}, ${data['selectedCustomerDetails']['state'] ?? ''}, ${data['selectedCustomerDetails']['pin'] ?? ''}",
                  style: pw.TextStyle(fontSize: 12)),
              pw.Text(
                  "Phone: ${data['selectedCustomerDetails']['phone'] ?? ''}",
                  style: pw.TextStyle(fontSize: 12)),
              pw.Text(
                  "Email: ${data['selectedCustomerDetails']['email'] ?? ''}",
                  style: pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        // 5. Items table
        pw.Table.fromTextArray(
          headers: [
            'Item / Details',
            'Unit Cost',
            'Sum Cost',
            'Discount',
            'Tax',
            'Total'
          ],
          data: (data['items'] as List<dynamic>).map<List<String>>((item) {
            final Map<String, dynamic> mapItem = item as Map<String, dynamic>;
            return [
              mapItem['product_name'] ?? '',
              mapItem['unit_cost'].toString(),
              mapItem['sum_cost'].toString(),
              mapItem['discount'].toString(),
              mapItem['tax'].toString(),
              mapItem['total'].toString(),
            ];
          }).toList(),
          headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          cellStyle: pw.TextStyle(fontSize: 10, color: PdfColors.black),
          cellAlignment: pw.Alignment.center,
          columnWidths: {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1),
            4: pw.FlexColumnWidth(1),
            5: pw.FlexColumnWidth(1),
          },
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
        ),
        pw.SizedBox(height: 20),
        // 6. Total amount
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text("Total Amount: \$${data['totalAmount']}",
              style:
              pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 20),
        // 7. Signature section
        pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: pw.EdgeInsets.only(top: 20),
          decoration: pw.BoxDecoration(
            border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: 1)),
          ),
          child: pw.Text("Authorized Signature: _____________________",
              style: pw.TextStyle(
                  fontSize: 14, fontStyle: pw.FontStyle.italic)),
        ),
        pw.SizedBox(height: 20),
        // 8. Terms and conditions
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            "Terms and Conditions: \nLorem ipsum dolor sit amet, consectetur adipiscing elit. All payments are due within 15 days. Thank you for your business!",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
  );

  final pdfBytes = await pdf.save();
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes);
}
