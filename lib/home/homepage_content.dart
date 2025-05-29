import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';

class HomepageContent extends StatelessWidget {
  const HomepageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color blackColor = Colors.black;
    final Color amberColor = Colors.amber.shade600;

    return Container(
      color: blackColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              String username = 'User';
              if (state is UserLoadSuccess) {
                username = state.username ?? 'User';
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to the homepage!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
