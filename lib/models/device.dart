import 'package:flutter/foundation.dart';

@immutable
class Device {
  final String ip;
  final String? hostname;
  final String? mac;
  final String? manufacturer;
  final bool isOnline;

  const Device({
    required this.ip,
    this.hostname,
    this.mac,
    this.manufacturer,
    this.isOnline = false,
  });
}