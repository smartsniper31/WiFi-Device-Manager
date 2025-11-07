import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_device_manager/models/device.dart';
import 'package:wifi_device_manager/services/network_scanner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Stream<Device>? _scanStream;
  final List<Device> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Démarrer le scan après le premier build pour s'assurer que 'ref' est disponible.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  void _startScan() {
    // Empêche de lancer plusieurs scans en même temps
    if (_isScanning) return;

    setState(() {
      _devices.clear();
      _isScanning = true;
      // On écoute le stream pour mettre à jour notre liste locale d'appareils
      final scanner = ref.read(networkScannerProvider);
      _scanStream = scanner.scanDevices()
        ..listen((device) => setState(() => _devices.add(device)))
            .onDone(() => setState(() => _isScanning = false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Device Manager'),
        actions: [
          IconButton(
            // Affiche une icône de chargement pendant le scan
            icon: _isScanning
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            onPressed: _startScan,
            tooltip: 'Relancer le scan',
          ),
        ],
      ),
      body: _devices.isEmpty
          ? Center(
              child: _isScanning
                  ? const Text('Scan en cours, recherche des appareils...')
                  : const Text('Aucun appareil trouvé. Lancez un scan.'),
            )
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  leading: const Icon(Icons.devices),
                  title: Text(device.hostname ?? 'Appareil inconnu'),
                  subtitle: Text('${device.ip}\n${device.mac ?? 'MAC non disponible'}'),
                  trailing: Icon(
                    Icons.circle,
                    color: device.isOnline ? Colors.green : Colors.red,
                    size: 12,
                  ),
                );
              },
            ),
    );
  }
}