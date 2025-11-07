import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(
    child: WiFiDeviceManagerApp(),
  ));
}

class WiFiDeviceManagerApp extends StatelessWidget {
  const WiFiDeviceManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Device Manager',
      theme: ThemeData.dark(),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}