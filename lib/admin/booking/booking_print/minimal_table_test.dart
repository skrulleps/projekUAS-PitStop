import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MinimalTableTest {
  Future<void> generateTestPdf() async {
    final pdf = pw.Document();

    final headers = ['No', 'Name', 'Age'];
    final data = [
      ['1', 'Alice', '30'],
      ['2', 'Bob', '25'],
      ['3', 'Charlie', '35'],
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(width: 1),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black),
              cellStyle: pw.TextStyle(fontSize: 10, color: PdfColors.black),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FixedColumnWidth(30),
                1: pw.FlexColumnWidth(3),
                2: pw.FixedColumnWidth(40),
              },
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
