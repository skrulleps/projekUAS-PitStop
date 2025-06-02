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
              pw.Center(
                child: pw.Text(
                  'PITSTOP SERVICE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'BOOKING RECEIPT',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 10),
              _buildRow('User', userFullName),
              _buildRow('Mechanic', mechanicFullName),
              _buildRow(
                  'Date',
                  booking.bookingsDate != null
                      ? booking.bookingsDate!.toLocal().toString().split(' ')[0]
                      : '-'),
              _buildRow('Time', booking.bookingsTime ?? '-'),
              _buildRow('Status', booking.status ?? '-'),
              pw.Divider(thickness: 1),
              pw.Text('Services:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              ...services.map((service) {
                return _buildRow(
                  service.serviceName ?? '-',
                  'Rp ${service.price?.toString() ?? '-'}',
                );
              }).toList(),
              pw.Divider(thickness: 1),
              _buildRow(
                'Total',
                'Rp ${booking.totalPrice?.toStringAsFixed(0) ?? '-'}',
                isBold: true,
              ),
              pw.SizedBox(height: 10),
              pw.Text('Notes:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(booking.notes?.trim().isNotEmpty == true
                  ? booking.notes!
                  : '-'),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Thank you for your booking!',
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _buildRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
