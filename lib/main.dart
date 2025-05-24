// lib/main.dart
import 'package:flutter/material.dart';
import 'package:aplikasiservicemotor/screens/splash_screen.dart'; // SplashScreen kustom kita

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Service Motor',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: 'Arial',
      ),
      home: const SplashScreen(), // Ini akan menjalankan SplashScreen.dart kustom kita
      debugShowCheckedModeBanner: false,
    );
  }
}