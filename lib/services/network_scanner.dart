import 'dart:async';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/device.dart';

final networkScannerProvider = Provider((ref) => NetworkScanner());

class NetworkScanner {
  final _networkInfo = NetworkInfo();

  /// Scanne le réseau local pour trouver les appareils actifs.
  /// Retourne un flux (Stream) de `Device` pour une mise à jour en temps réel de l'UI.
  Stream<Device> scanDevices() async* {
    final wifiIP = await _networkInfo.getWifiIP();
    if (wifiIP == null) {
      // Pas de connexion WiFi, on ne peut pas scanner.
      // On pourrait lever une exception ou retourner un flux vide.
      print("Erreur: Non connecté au WiFi.");
      return;
    }

    // Extrait le préfixe de l'adresse IP (ex: "192.168.1.")
    final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));

    // Nous allons lancer tous les pings en parallèle pour la vitesse.
    final futures = <Future<void>>[];

    // On scanne toutes les adresses de .1 à .254
    for (var i = 1; i < 255; i++) {
      final host = '$subnet.$i';
      final ping = Ping(host, count: 1, timeout: 2);

      // Nous utilisons un Completer pour gérer l'asynchronisme.
      final completer = Completer<void>();
      futures.add(completer.future);

      ping.stream.listen((event) {
        if (event.summary != null && event.summary!.received > 0) {
          // L'appareil a répondu ! On le produit dans le Stream.
          yield Device(ip: host, isOnline: true);
        }
      }).onDone(() => completer.complete());
    }
    await Future.wait(futures); // Attend que tous les pings soient terminés.
  }
}