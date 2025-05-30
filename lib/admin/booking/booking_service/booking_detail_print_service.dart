import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pitstop/admin/booking/model/booking_model.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';

class BookingDetailPrintService {
  Future<void> printBookingDetail({
    required BookingModel booking,
    required List<ServiceModel> services,
    required String userFullName,
    required String mechanicFullName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PitStop Booking Receipt',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('User: $userFullName'),
              pw.Text('Mechanic: $mechanicFullName'),
              pw.Text('Date: ${booking.bookingsDate?.toLocal().toIso8601String().split("T")[0] ?? '-'}'),
              pw.Text('Time: ${booking.bookingsTime ?? '-'}'),
              pw.Text('Status: ${booking.status ?? '-'}'),
              pw.Divider(),
              pw.Text('Services:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Column(
                children: services.map((service) {
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(service.serviceName ?? '-'),
                      pw.Text('Rp ${service.price != null ? service.price.toString() : '-'}'),
                    ],
                  );
                }).toList(),
              ),
              pw.Divider(),
              pw.Text('Total Price: Rp ${booking.totalPrice?.toStringAsFixed(2) ?? '-'}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Notes:'),
              pw.Text(booking.notes ?? '-'),
              pw.SizedBox(height: 20),
              pw.Text('Thank you for your booking!',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
