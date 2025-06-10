import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pitstop/data/model/booking/booking_model.dart';
import 'package:pitstop/data/api/booking/booking_service.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/admin/data_master/mechanic/service/mechanic_service.dart';
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

  Future<Map<String, List<ServiceModel>>> fetchServicesForBookings(List<BookingModel> bookings) async {
    Map<String, List<ServiceModel>> servicesByDateTimeKey = {};
    for (var booking in bookings) {
      final dateStr = booking.bookingsDate != null ? booking.bookingsDate!.toIso8601String().split('T')[0] : '';
      final timeStr = booking.bookingsTime ?? '';
      final compositeKey = '${dateStr}_$timeStr';

      // Since getServicesByUserIdAndDateTime is not defined, we simulate fetching services by serviceId
      // This is a placeholder and should be replaced with actual service fetching logic
      final services = <ServiceModel>[];
      if (booking.servicesId != null) {
        services.add(ServiceModel(id: booking.servicesId, serviceName: 'Service Name Placeholder'));
      }

      if (servicesByDateTimeKey.containsKey(compositeKey)) {
        servicesByDateTimeKey[compositeKey] = [...servicesByDateTimeKey[compositeKey]!, ...services];
      } else {
        servicesByDateTimeKey[compositeKey] = services;
      }
    }
    return servicesByDateTimeKey;
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

  List<DateTime> getNext6DaysExcludingFriday() {
    List<DateTime> days = [];
    DateTime current = DateTime.now();
    int added = 0;
    while (added < 6) {
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
            ? bookingServices.map((s) => s.serviceName ?? 'Unknown Service').join(', ')
            : (servicesMap[booking.servicesId]?.serviceName ?? 'Unknown Service');
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
              Text("$serviceNames with ${getMechanicName(mechanics, booking.mechanicsId)}"),
              Text("Status: ${booking.status ?? 'Unknown'}"),
            ],
          ),
        );
      },
    );
  }
}
