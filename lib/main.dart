import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const WiFiDeviceManagerApp());
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