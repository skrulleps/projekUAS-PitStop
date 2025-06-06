
import 'package:flutter/material.dart';

// Model sederhana untuk data item riwayat (bisa disesuaikan dengan kebutuhan dari backend)
class HistoryEntry {
  final String id;
  final String serviceName;
  final String garageName;
  final String date;
  final String status; // Contoh: "Selesai", "Dibatalkan", "Dijadwalkan"
  final String? price;
  final IconData icon;

  const HistoryEntry({
    required this.id,
    required this.serviceName,
    required this.garageName,
    required this.date,
    required this.status,
    this.price,
    required this.icon,
  });
}


class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  // Data contoh untuk ditampilkan di UI
  final List<HistoryEntry> _dummyHistoryItems = const [
    HistoryEntry(
      id: '1',
      serviceName: 'Ganti Oli Mesin & Filter',
      garageName: 'Bengkel Cepat Sejahtera',
      date: '28 Mei 2025',
      status: 'Selesai',
      price: 'Rp 450.000',
      icon: Icons.build_circle_outlined,
    ),
    HistoryEntry(
      id: '2',
      serviceName: 'Servis Berkala 60.000 KM',
      garageName: 'Auto Jaya Service',
      date: '15 Apr 2025',
      status: 'Selesai',
      price: 'Rp 1.250.000',
      icon: Icons.car_repair_outlined,
    ),
    HistoryEntry(
      id: '3',
      serviceName: 'Pengecekan Rem Darurat',
      garageName: 'Bengkel Cepat Sejahtera',
      date: '02 Feb 2025',
      status: 'Dibatalkan',
      price: null, // Atau Rp 0 jika ada biaya pembatalan
      icon: Icons.front_hand_outlined,
    ),
    HistoryEntry(
      id: '4',
      serviceName: 'Booking Cuci Mobil Premium',
      garageName: 'Kilap Auto Detailing',
      date: '05 Jun 2025, 14:00',
      status: 'Dijadwalkan',
      price: 'Rp 150.000',
      icon: Icons.wash_outlined,
    ),
  ];

  // Helper untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green.shade700;
      case 'dibatalkan':
        return Colors.red.shade700;
      case 'dijadwalkan':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // Helper untuk mendapatkan ikon status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle_outline;
      case 'dibatalkan':
        return Icons.cancel_outlined;
      case 'dijadwalkan':
        return Icons.schedule_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Servis'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Warna AppBar sama dengan latar scaffold
        elevation: 1, // Sedikit bayangan untuk memisahkan dari konten
        foregroundColor: Colors.black87, // Warna teks dan ikon di AppBar
      ),
      body: _dummyHistoryItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat servis.',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua riwayat servis Anda akan muncul di sini.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12.0), // Padding untuk keseluruhan list
        itemCount: _dummyHistoryItems.length,
        itemBuilder: (context, index) {
          final item = _dummyHistoryItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0), // Jarak antar kartu
            elevation: 2.5, // Sedikit bayangan pada kartu
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell( // Membuat kartu bisa di-tap
              onTap: () {
                // TODO: Implementasi aksi ketika item riwayat di-tap (misal: lihat detail)
                print('History item tapped: ${item.serviceName}');
              },
              borderRadius: BorderRadius.circular(10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(item.icon, color: Theme.of(context).primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.serviceName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.garageName,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        // Indikator status di pojok kanan atas (jika diperlukan, alternatif dari chip di bawah)
                        // Icon(_getStatusIcon(item.status), color: _getStatusColor(item.status), size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              item.date,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        if (item.price != null)
                          Text(
                            item.price!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Tampilan status menggunakan Chip
                    Align(
                      alignment: Alignment.centerRight,
                      child: Chip(
                        avatar: Icon(_getStatusIcon(item.status), color: Colors.white, size: 16),
                        label: Text(item.status),
                        backgroundColor: _getStatusColor(item.status).withOpacity(0.85),
                        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
