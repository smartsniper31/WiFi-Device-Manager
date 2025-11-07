import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi_device_manager/models/device.dart';
import 'package:wifi_device_manager/screens/dashboard_screen.dart';
import 'package:wifi_device_manager/services/network_scanner.dart';

// Importe le fichier qui sera généré par mockito
import 'widget_test.mocks.dart';

// Annotation pour dire à mockito de créer une classe MockNetworkScanner
@GenerateMocks([NetworkScanner])
void main() {
  testWidgets('DashboardScreen affiche les appareils trouvés par le scan',
      (WidgetTester tester) async {
    // ÉTAPE 1: Préparation du Mock
    // Crée une instance de notre faux scanner
    final mockScanner = MockNetworkScanner();

    // Définit le comportement du faux scanner : quand on appelle scanDevices(),
    // il retourne instantanément un Stream avec deux appareils.
    when(mockScanner.scanDevices()).thenAnswer(
      (_) => Stream.fromIterable([
        const Device(ip: '192.168.1.10', hostname: 'PC-Bureau', isOnline: true),
        const Device(ip: '192.168.1.25', hostname: 'Smart-TV', isOnline: true),
      ]),
    );

    // ÉTAPE 2: Construction de l'UI avec le Mock
    // On "pompe" notre widget, mais en l'enveloppant dans un ProviderScope
    // qui remplace le vrai scanner par notre faux scanner.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkScannerProvider.overrideWithValue(mockScanner),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    // ÉTAPE 3: Vérifications
    // Le scan est si rapide qu'on passe directement à l'état final.
    // On attend que l'UI se mette à jour.
    await tester.pumpAndSettle();

    // L'icône de rafraîchissement doit être visible.
    expect(find.byIcon(Icons.refresh), findsOneWidget,
        reason: "L'icône de refresh doit être visible après le scan");

    // On vérifie que nos deux appareils sont bien affichés.
    expect(find.byType(ListTile), findsNWidgets(2),
        reason: "Doit afficher 2 appareils");
    expect(find.text('PC-Bureau'), findsOneWidget);
    expect(find.text('192.168.1.10'), findsOneWidget);
    expect(find.text('Smart-TV'), findsOneWidget);
    expect(find.text('192.168.1.25'), findsOneWidget);
  });
}
