import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> printInvoiceHtmlFromData(Map<String, dynamic> data) async {
  String html = ''' 
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8">
    <title>Invoice</title>
    <style>
      /* (Paste the CSS from the HTML file above here) */
      body { margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #EEE; }
      .invoice-container { width: 900px; margin: 40px auto; background: #FFF; padding: 20px; border: 1px solid #DDD; }
      .header-table { width: 100%; border-bottom: 2px solid #CCC; margin-bottom: 20px; }
      .header-table td { vertical-align: top; }
      .invoice-title { font-size: 36px; font-weight: bold; color: #333; }
      .invoice-subtitle { font-size: 16px; color: #777; }
      .invoice-info { font-size: 14px; margin-top: 5px; }
      .company-info { text-align: right; font-size: 14px; color: #333; }
      .company-logo { width: 80px; margin-bottom: 10px; }
      .details-table { width: 100%; margin-bottom: 20px; }
      .details-table td { font-size: 14px; padding: 5px; border: 1px solid #CCC; }
      .items-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
      .items-table th, .items-table td { border: 1px solid #CCC; padding: 8px; font-size: 14px; text-align: center; }
      .items-table th { background-color: #444; color: #FFF; }
      .items-table tr:nth-child(even) { background-color: #F9F9F9; }
      .total { text-align: right; font-size: 18px; font-weight: bold; margin-bottom: 20px; }
      .signature { text-align: right; border-top: 2px solid #DDD; padding-top: 20px; font-size: 14px; font-style: italic; }
      .footer { background-color: #F7F7F7; border-top: 1px solid #DDD; padding: 20px; text-align: center; font-size: 12px; color: #777; }
    </style>
  </head>
  <body>
    <div class="invoice-container">
      <table class="header-table">
        <tr>
          <td>
            <div class="invoice-title">Invoice <br /><span class="invoice-subtitle">With Credit</span></div>
            <div class="invoice-info">NO: ${data['invoiceNumber']} | Date: ${data['invoiceDate']}</div>
          </td>
          <td class="company-info">
            <img class="company-logo" src="https://via.placeholder.com/80" alt="Logo" />
            <div>
              <strong>RCJA Australia</strong><br />
              Lorem Ipsum<br />
              2 Alliance Lane VIC<br />
              info@rcja.com
            </div>
          </td>
        </tr>
      </table>
      
      <table class="details-table">
        <tr>
          <td style="width:48%;">
            <strong>Company Details</strong><br />
            Name: RCJA<br />
            Address: 1 Unknown Street VIC<br />
            Phone: (+61)404123123<br />
            Email: admin@rcja.com<br />
            Contact: John Smith
          </td>
          <td style="width:48%;">
            <strong>Customer Details</strong><br />
            Name: ${data['selectedCustomerDetails']['name']}<br />
            Address: ${data['selectedCustomerDetails']['locality']}, ${data['selectedCustomerDetails']['city']}, ${data['selectedCustomerDetails']['state']}, ${data['selectedCustomerDetails']['pin']}<br />
            Phone: ${data['selectedCustomerDetails']['phone']}<br />
            Email: ${data['selectedCustomerDetails']['email']}<br />
            Contact: Jane Doe
          </td>
        </tr>
      </table>
      
      <table class="items-table">
        <thead>
          <tr>
            <th>Item / Details</th>
            <th>Unit Cost</th>
            <th>Sum Cost</th>
            <th>Discount</th>
            <th>Tax</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
  ''';

  for (var item in data['items']) {
    html += '''
          <tr>
            <td>${item['product_name']}<br /><small>${item['description']}</small></td>
            <td>${item['unit_cost']}</td>
            <td>${item['sum_cost']}</td>
            <td>${item['discount']}</td>
            <td>${item['tax']}</td>
            <td>${item['total']}</td>
          </tr>
    ''';
  }
  html += '''
        </tbody>
        <tfoot>
          <tr>
            <th>Total:</th>
            <th colspan="2"></th>
            <th>${data['totalDiscount']}</th>
            <th>${data['totalTax']}</th>
            <th>${data['totalAmount']}</th>
          </tr>
        </tfoot>
      </table>
      
      <div class="total">Amount Due (AUD): ${data['amountDue']}</div>
      
      <div class="signature">Authorized Signature: _____________________</div>
      
      <div class="footer">
        <strong>Terms and Conditions:</strong> Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. All payments are due within 15 days. Thank you for your business!
      </div>
    </div>
  </body>
  </html>
  ''';

  final pdf = pw.Document();
  final widgets = await HTMLToPdf().convert(html);
  pdf.addPage(pw.MultiPage(build: (context) => widgets));
  final pdfBytes = await pdf.save();
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
}
