import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pitstop/data/model/booking/booking_model.dart';
import 'package:pitstop/data/api/booking/booking_service.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/data/api/mechanic/mechanic_service.dart';
import 'package:pitstop/data/model/service/service_model.dart';

class AdminUtils {
  final BookingService _bookingService = BookingService();
  final CustomerService _customerService = CustomerService();
  final MechanicService _mechanicService = MechanicService();

  Future<Map<String, dynamic>> fetchDataForToday() async {
    try {
      final bookings = await _bookingService.getBookings();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final bookingsToday = bookings?.where((b) {
            if (b.bookingsDate == null) return false;
            final bookingDateStr =
                DateFormat('yyyy-MM-dd').format(b.bookingsDate!);
            return bookingDateStr == todayStr;
          }).toList() ??
          [];

      final customers = await _customerService.getCustomers() ?? [];
      final mechanics = await _mechanicService.getMechanics() ?? [];
      final services = await _bookingService.getAllServices() ?? [];
      final servicesMap = {for (var s in services) s.id ?? '': s};

      return {
        'bookingsToday': bookingsToday,
        'customers': customers,
        'mechanics': mechanics,
        'servicesMap': servicesMap,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchDataForDate(DateTime date) async {
    try {
      final bookings = await _bookingService.getBookingsByDate(date);
      final customers = await _customerService.getCustomers() ?? [];
      final mechanics = await _mechanicService.getMechanics() ?? [];
      final services = await _bookingService.getAllServices() ?? [];
      final servicesMap = {for (var s in services) s.id ?? '': s};

      return {
        'bookings': bookings ?? [],
        'customers': customers,
        'mechanics': mechanics,
        'servicesMap': servicesMap,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, List<ServiceModel>>> fetchServicesForBookings(
      List<BookingModel> bookings,
      Map<String, ServiceModel> servicesMap) async {
    Map<String, List<ServiceModel>> servicesByBookingId = {};
    for (var booking in bookings) {
      final services = <ServiceModel>[];
      if (booking.servicesId != null) {
        final service = servicesMap[booking.servicesId];
        if (service != null) {
          services.add(service);
        }
      }
      servicesByBookingId[booking.id ?? ''] = services;
    }
    return servicesByBookingId;
  }

  String getCustomerName(List<CustomerModel> customers, String? userId) {
    final customer = customers.firstWhere((c) => c.usersId == userId,
        orElse: () => CustomerModel(fullName: 'Unknown'));
    return customer.fullName ?? 'Unknown';
  }

  String getMechanicName(List<MechanicModel> mechanics, String? mechanicId) {
    final mechanic = mechanics.firstWhere((m) => m.id == mechanicId,
        orElse: () => MechanicModel(fullName: 'Unknown'));
    return mechanic.fullName ?? 'Unknown';
  }

  List<DateTime> getNext5DaysExcludingFriday() {
    List<DateTime> days = [];
    DateTime current = DateTime.now();
    int added = 0;
    while (added < 5) {
      current = current.add(const Duration(days: 1));
      if (current.weekday != DateTime.friday) {
        days.add(current);
        added++;
      }
    }
    return days;
  }

  Widget buildBookingListForDate(
    List<BookingModel> bookings,
    List<CustomerModel> customers,
    List<MechanicModel> mechanics,
    Map<String, ServiceModel> servicesMap,
    Map<String, List<ServiceModel>> servicesByBookingId,
  ) {
    if (bookings.isEmpty) {
      return const ListTile(
        title: Text('No bookings'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final bookingServices = servicesByBookingId[booking.id] ?? [];
        final serviceNames = bookingServices.isNotEmpty
            ? bookingServices
                .map((s) => s.serviceName ?? 'Unknown Service')
                .join(', ')
            : (servicesMap[booking.servicesId]?.serviceName ??
                'Unknown Service');
        return ListTile(
          title: Row(
            children: [
              // Removed booking ID display as per user request
              Expanded(
                child: Text(getCustomerName(customers, booking.usersId)),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Customer : $serviceNames"),
              Text("with : ${getMechanicName(mechanics, booking.mechanicsId)}"),
              Text("Status: ${booking.status ?? 'Unknown'}"),
            ],
          ),
        );
      },
    );
  }

  Widget buildGroupedBookingListForDate(
    List<BookingModel> bookings,
    List<CustomerModel> customers,
    List<MechanicModel> mechanics,
    Map<String, ServiceModel> servicesMap,
    Map<String, List<ServiceModel>> servicesByBookingId,
  ) {
    if (bookings.isEmpty) {
      return const ListTile(
        title: Text('No bookings'),
      );
    }

    // Group bookings by bookingDate and bookingTime
    Map<String, List<BookingModel>> groupedBookings = {};
    for (var booking in bookings) {
      final dateStr = booking.bookingsDate != null
          ? booking.bookingsDate!.toIso8601String().split('T')[0]
          : '';
      final timeStr = booking.bookingsTime ?? '';
      final key = '${dateStr}_$timeStr';
      if (groupedBookings.containsKey(key)) {
        groupedBookings[key]!.add(booking);
      } else {
        groupedBookings[key] = [booking];
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedBookings.length,
      itemBuilder: (context, index) {
        final key = groupedBookings.keys.elementAt(index);
        final group = groupedBookings[key]!;

        // Aggregate customer names, service names, mechanic names, and statuses
        final customerNames = group
            .map((b) => getCustomerName(customers, b.usersId))
            .toSet()
            .join(', ');
        final mechanicNames = group
            .map((b) => getMechanicName(mechanics, b.mechanicsId))
            .toSet()
            .join(', ');

        // Aggregate services for the group
        final servicesSet = <String>{};
        for (var b in group) {
          final bookingServices = servicesByBookingId[b.id] ?? [];
          if (bookingServices.isNotEmpty) {
            servicesSet.addAll(
                bookingServices.map((s) => s.serviceName ?? 'Unknown Service'));
          } else {
            final serviceName =
                servicesMap[b.servicesId]?.serviceName ?? 'Unknown Service';
            servicesSet.add(serviceName);
          }
        }
        final serviceNames = servicesSet.join(', ');

        // Aggregate statuses
        final statuses =
            group.map((b) => b.status ?? 'Unknown').toSet().join(', ');

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(customerNames),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$serviceNames with $mechanicNames"),
                Text("Status: $statuses"),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildGroupedBookingListForDateByCustomerDateTime(
    List<BookingModel> bookings,
    List<CustomerModel> customers,
    List<MechanicModel> mechanics,
    Map<String, ServiceModel> servicesMap,
    Map<String, List<ServiceModel>> servicesByBookingId,
  ) {
    if (bookings.isEmpty) {
      return [
        const ListTile(
          title: Text('No bookings'),
        )
      ];
    }

    // Group bookings by customer name, bookingDate and bookingTime
    Map<String, List<BookingModel>> groupedBookings = {};
    for (var booking in bookings) {
      final customerName = getCustomerName(customers, booking.usersId);
      final dateStr = booking.bookingsDate != null
          ? booking.bookingsDate!.toIso8601String().split('T')[0]
          : '';
      final timeStr = booking.bookingsTime ?? '';
      final key = '${customerName}_$dateStr $timeStr';
      if (groupedBookings.containsKey(key)) {
        groupedBookings[key]!.add(booking);
      } else {
        groupedBookings[key] = [booking];
      }
    }

    List<Widget> cards = [];

    for (var key in groupedBookings.keys) {
      final group = groupedBookings[key]!;

      final customerName = getCustomerName(customers, group[0].usersId);
      final dateStr = group[0].bookingsDate != null
          ? DateFormat('yyyy-MM-dd').format(group[0].bookingsDate!)
          : 'Unknown Date';
      final timeStr = group[0].bookingsTime ?? 'Unknown Time';

      // Aggregate service names and mechanic names
      final servicesSet = <String>{};
      final mechanicNamesSet = <String>{};
      for (var b in group) {
        final bookingServices = servicesByBookingId[b.id] ?? [];
        if (bookingServices.isNotEmpty) {
          servicesSet.addAll(
              bookingServices.map((s) => s.serviceName ?? 'Unknown Service'));
        } else {
          final serviceName =
              servicesMap[b.servicesId]?.serviceName ?? 'Unknown Service';
          servicesSet.add(serviceName);
        }
        mechanicNamesSet.add(getMechanicName(mechanics, b.mechanicsId));
      }
      final serviceNames = servicesSet.join(', ');
      final mechanicNames = mechanicNamesSet.join(', ');

      // Aggregate statuses
      final statuses =
          group.map((b) => b.status ?? 'Unknown').toSet().join(', ');

      cards.add(Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Date: $dateStr"),
              Text("Time: $timeStr"),
              Text("Services: $serviceNames"),
              Text("Mechanics: $mechanicNames"),
              Text("Status: $statuses"),
            ],
          ),
        ),
      ));
    }

    return cards;
  }
}
