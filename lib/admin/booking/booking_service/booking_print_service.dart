import 'package:pdf/widgets.dart' as pw;
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
import '../model/booking_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';

import 'package:pitstop/utils/pdf_utils.dart';

class BookingPrintService {
  Future<void> printBookings(
    List<BookingModel> bookingsToPrint,
    Map<String, String> userFullNamesById,
    Map<String, String> mechanicFullNamesById,
    Map<String, List<ServiceModel>> serviceListByUserId,
  ) async {
    final bgImageData = await rootBundle.load('assets/images/logobg.png');
    final bgImage = pw.MemoryImage(bgImageData.buffer.asUint8List());

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('Laporan Booking', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'No',
                  'User',
                  'Mechanic',
                  'Service',
                  'Date',
                  'Time',
                  'Status',
                  'Notes',
                  'Total Price',
                ],
                data: List<List<String>>.generate(
                  bookingsToPrint.length,
                  (index) {
                    final booking = bookingsToPrint[index];
                    final userFullName = userFullNamesById[booking.usersId] ?? '-';
                    final mechanicFullName = mechanicFullNamesById[booking.mechanicsId] ?? '-';
                    final dateStr = booking.bookingsDate != null ? booking.bookingsDate!.toIso8601String().split('T')[0] : '';
                    final timeStr = booking.bookingsTime ?? '';
                    final compositeKey = '${booking.usersId}_$dateStr\_$timeStr';
                    final services = serviceListByUserId[compositeKey] ?? [];
                    final serviceNames = services.asMap().entries.map((entry) {
                      int idx = entry.key + 1;
                      String name = entry.value.serviceName ?? '-';
                      return '$idx. $name';
                    }).join('\n');
                    // final dateStr = booking.bookingsDate != null
                    //     ? '${booking.bookingsDate!.toLocal().toIso8601String().split("T")[0]}'
                    //     : '-';
                    // final timeStr = booking.bookingsTime ?? '-';
                    final status = booking.status ?? '-';
                    final notes = booking.notes ?? '-';
                    final totalPrice = (booking.totalPrice ?? 0).toStringAsFixed(2);

                    return [
                      (index + 1).toString(),
                      userFullName,
                      mechanicFullName,
                      serviceNames,
                      dateStr,
                      timeStr,
                      status,
                      notes,
                      totalPrice,
                    ];
                  },
                ),
                border: pw.TableBorder.all(width: 1),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.center,
                  8: pw.Alignment.centerRight,
                },
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.bottomCenter,
                child: pw.Image(bgImage, width: 100, height: 100, fit: pw.BoxFit.contain),
              ),
            ],
          );
        },
      ),
    );

    await openPdfDocument(pdf);
  }
}
