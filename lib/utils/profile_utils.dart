import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:go_router/go_router.dart';

Future<bool> checkProfileCompleteness(BuildContext context) async {
  final userBloc = context.read<UserBloc>().state;
  if (userBloc is UserLoadSuccess) {
    final userId = userBloc.userId;
    if (userId != null && userId.isNotEmpty) {
      final customer = await CustomerService().getCustomerByUserId(userId);
      if (customer != null) {
        final bool isProfileIncomplete = (customer.fullName == null || customer.fullName!.isEmpty) ||
            (customer.phone == null || customer.phone!.isEmpty) ||
            (customer.address == null || customer.address!.isEmpty) ||
            (customer.photos == null || customer.photos!.isEmpty);
        return isProfileIncomplete;
      }
    }
  }
  return false;
}

void showProfileIncompleteDialog(BuildContext context, VoidCallback onConfirmed) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Profile Incomplete'),
        content: const Text('Please complete your profile before continuing.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirmed();
            },
          ),
        ],
      );
    },
  );
}
