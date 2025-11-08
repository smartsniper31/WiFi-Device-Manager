import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/device.dart';

final networkScannerProvider = Provider((ref) => NetworkScanner());

class NetworkScanner {
  /// Scans the local network for active devices by pinging all possible addresses in the subnet.
  /// Returns a stream of `Device` for real-time UI updates.
  Stream<Device> scanDevices() {
    final controller = StreamController<Device>();

    () async {
      final wifiIP = await NetworkInfo().getWifiIP();
      if (wifiIP == null) {
        print("Erreur: Non connecté au WiFi.");
        controller.close();
        return;
      }

      final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));

      // Generate all addresses from 1 to 254 for the subnet
      for (int i = 1; i < 255; i++) {
        final host = '$subnet.$i';

        // Ping each address
        final ping = Ping(host, count: 1, timeout: 1);

        // We don't await the result, we listen to the stream to do it in parallel
        ping.stream.listen((event) {
          if (event.response != null && event.error == null) {
            // If we get a response without an error, the host is online
            controller.add(Device(ip: host, hostname: 'Unknown', mac: 'Unknown', isOnline: true));
          }
        });
      }

      // Give the pings 2 seconds to complete, then close the stream.
      await Future.delayed(const Duration(seconds: 2));
      controller.close(); // This will be called after all pings have had a chance to complete.
    }();
    
    return controller.stream;
  }
}