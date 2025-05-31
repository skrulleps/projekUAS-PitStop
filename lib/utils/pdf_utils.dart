import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Utility function to create a PDF document with a background image and page format config.
/// [backgroundImagePath] is the asset path to the background image.
/// Returns a [pw.Document] with a single page configured.
Future<pw.Document> createPdfDocumentWithBackground(String? backgroundImagePath, pw.Widget Function(pw.Context) buildContent) async {
  final pdf = pw.Document();

  if (backgroundImagePath == null || backgroundImagePath.isEmpty) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return buildContent(context);
        },
      ),
    );
  } else {
    // Load background image
    final bgImageData = await rootBundle.load(backgroundImagePath);
    final bgImage = pw.MemoryImage(bgImageData.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Stack(
            children: <pw.Widget>[
              pw.Positioned.fill(
                child: pw.Image(bgImage, fit: pw.BoxFit.cover),
              ),
              buildContent(context),
            ],
          );
        },
      ),
    );
  }

  return pdf;
}

/// Utility function to open/print a PDF document using Printing.layoutPdf.
/// [pdf] is the [pw.Document] to be printed.
Future<void> openPdfDocument(pw.Document pdf) async {
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
