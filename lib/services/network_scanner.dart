import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/device.dart';

final networkScannerProvider = Provider((ref) => NetworkScanner());

class NetworkScanner {
  final _scanner = LanScanner();

  /// Scanne le réseau local pour trouver les appareils actifs.
  /// Retourne un flux (Stream) de `Device` pour une mise à jour en temps réel de l'UI.
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
      controller.close();
    }();
    
    return controller.stream;
  }
}