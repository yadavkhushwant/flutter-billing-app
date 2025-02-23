import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> savePdfFile(List<int> pdfBytes, String invoiceNumber) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$invoiceNumber.pdf';
  final file = File(filePath);
  await file.writeAsBytes(pdfBytes);
  return file;
}
