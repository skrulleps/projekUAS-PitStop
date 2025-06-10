import 'package:pdf/widgets.dart' as pw;
import 'package:pitstop/data/model/service/service_model.dart';
import '../../../data/model/booking/booking_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pitstop/data/utils/pdf_utils.dart';

class BookingPrintService {
  Future<void> printBookings(
    List<BookingModel> bookingsToPrint,
    Map<String, String> userFullNamesById,
    Map<String, String> mechanicFullNamesById,
    Map<String, List<ServiceModel>> serviceListByUserId,
  ) async {
    // Inisialisasi data lokal untuk tanggal bahasa Indonesia
    await initializeDateFormatting('id_ID');

    final bgImageData = await rootBundle.load('assets/images/logobg.png');
    final bgImage = pw.MemoryImage(bgImageData.buffer.asUint8List());

    final pdf = pw.Document();
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          return pw.Stack(
            children: [
              // Background logo transparan
              pw.Positioned(
                right: 30,
                bottom: 30,
                child: pw.Opacity(
                  opacity: 0.2,
                  child: pw.Image(bgImage, width: 150),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'LAPORAN BOOKING PITSTOP',
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Center(
                    child: pw.Text(
                      'Dicetak pada ${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table.fromTextArray(
                    headers: [
                      'No',
                      'User',
                      'Mechanic',
                      'Service(s)',
                      'Date',
                      'Time',
                      'Status',
                      'Notes',
                      'Total',
                    ],
                    data: List<List<String>>.generate(
                      bookingsToPrint.length,
                      (index) {
                        final booking = bookingsToPrint[index];
                        final userFullName = userFullNamesById[booking.usersId] ?? '-';
                        final mechanicFullName = mechanicFullNamesById[booking.mechanicsId] ?? '-';
                        final dateStr = booking.bookingsDate != null
                            ? DateFormat('dd/MM/yyyy', 'id_ID').format(booking.bookingsDate!)
                            : '-';
                        final timeStr = booking.bookingsTime ?? '-';
                        final compositeKey = '${booking.usersId}_${booking.bookingsDate?.toIso8601String().split('T')[0] ?? ''}_${timeStr}';
                        final services = serviceListByUserId[compositeKey] ?? [];
                        final serviceNames = services.asMap().entries.map((entry) {
                          int idx = entry.key + 1;
                          String name = entry.value.serviceName ?? '-';
                          return '$idx. $name';
                        }).join('\n');
                        final notes = booking.notes ?? '-';
                        final status = booking.status ?? '-';
                        final totalPrice = formatter.format(booking.totalPrice ?? 0);

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
                    border: pw.TableBorder.all(width: 0.7),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    cellAlignment: pw.Alignment.topLeft,
                    cellAlignments: {
                      0: pw.Alignment.center,
                      8: pw.Alignment.centerRight,
                    },
                    columnWidths: {
                      0: const pw.FixedColumnWidth(25),
                      1: const pw.FixedColumnWidth(80),
                      2: const pw.FixedColumnWidth(80),
                      3: const pw.FlexColumnWidth(3),
                      4: const pw.FixedColumnWidth(60),
                      5: const pw.FixedColumnWidth(40),
                      6: const pw.FixedColumnWidth(60),
                      7: const pw.FlexColumnWidth(2),
                      8: const pw.FixedColumnWidth(70),
                    },
                  ),
                  pw.SizedBox(height: 30),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text('Mengetahui,', style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 40),
                          pw.Text('(___________________)', style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await openPdfDocument(pdf);
  }
}
