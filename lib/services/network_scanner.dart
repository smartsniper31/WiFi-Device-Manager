import 'dart:async';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/device.dart';

final networkScannerProvider = Provider((ref) => NetworkScanner());

class NetworkScanner {
  final _networkInfo = NetworkInfo();
  final _scanner = LanScanner();

  /// Scanne le réseau local pour trouver les appareils actifs.
  /// Retourne un flux (Stream) de `Device` pour une mise à jour en temps réel de l'UI.
  Stream<Device> scanDevices() {
    // On utilise un StreamController pour gérer manuellement le flux de données.
    final controller = StreamController<Device>();

    // We wrap the logic in an async closure to handle the initial IP lookup.
    () async {
      final wifiIP = await _networkInfo.getWifiIP();
      final wifiIP = await NetworkInfo().getWifiIP();
      if (wifiIP == null) {
        // No WiFi connection, close the stream and stop.
        print("Erreur: Non connecté au WiFi.");
        controller.close();
        return;
      }

      // Extract the IP prefix (e.g., "192.168.1.")
      final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
      final futures = <Future<void>>[];

      // Scan all addresses from .1 to .254
      for (var i = 1; i < 255; i++) {
        final host = '$subnet.$i';
        final ping = Ping(host, count: 1, timeout: 2);

        // Use a Completer to know when each ping is finished.
        final completer = Completer<void>();
        futures.add(completer.future);

        ping.stream.listen((event) {
          if (event.summary != null && event.summary!.received > 0) {
            // The device responded! Add it to the stream via the controller.
            controller.add(Device(ip: host, isOnline: true));
          }
        }).onDone(completer.complete);
      // Le nouveau scanner gère tout pour nous !
      final stream = _scanner.icmpScan(
        subnet,
        progressCallback: (progress) {
          // On pourrait utiliser ça pour une barre de progression
          // print('Scan progress: $progress');
        },
      );
      
      await for (final host in stream) {
        controller.add(Device(ip: host.ip, hostname: host.hostname, mac: host.mac, isOnline: true));
      }
      // When all pings are complete...
      await Future.wait(futures);
      // ...close the stream to signal the end of the scan.
      controller.close();
    }(); // Immediately invoke the async closure.

    return controller.stream; // On retourne immédiatement le stream.
    }();
    
    return controller.stream;
  }
}