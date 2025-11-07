import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_device_manager/main.dart';
import 'package:wifi_device_manager/models/device.dart';
import 'package:wifi_device_manager/screens/dashboard_screen.dart';

// Ce fichier de test vérifie le comportement de notre écran principal.

void main() {
  testWidgets('DashboardScreen affiche les appareils trouvés par le scan',
      (WidgetTester tester) async {
    // ÉTAPE 1: Préparation
    // Nous allons simuler un scan qui trouve deux appareils.
    // Pour cela, nous ne pouvons pas utiliser le vrai NetworkScanner.
    // Dans un vrai projet, nous utiliserions un framework de "mocking" comme Mockito
    // ou nous injecterions le scanner via Riverpod pour le remplacer facilement.
    // Pour rester simple ici, nous allons juste simuler l'état de l'UI.

    // Pour ce test, nous allons directement construire le DashboardScreen.
    // Note: Ce test est simplifié. Un test complet "mockerait" le NetworkScanner.
    await tester.pumpWidget(const MyApp());

    // ÉTAPE 2: Vérification de l'état initial
    // Au début, le scan est en cours.
    expect(find.text('Scan en cours, recherche des appareils...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Attendons la fin de la simulation du scan (quelques secondes).
    // pumpAndSettle attend que toutes les animations et les microtâches soient terminées.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ÉTAPE 3: Vérification de l'état final
    // Une fois le scan terminé, le message de scan doit disparaître.
    expect(find.text('Scan en cours, recherche des appareils...'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // L'icône de rafraîchissement doit être visible.
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // Vérifions si au moins un appareil est affiché.
    // Le test réussira si votre réseau local a au moins un appareil.
    // C'est un test d'intégration plus qu'un test de widget pur.
    expect(find.byType(ListTile), findsatLeastNWidgets(1));

    // Exemple de vérification plus précise si on connaissait l'IP de notre propre appareil
    // (ce qui est difficile à garantir dans un test).
    // Par exemple, si on sait que 192.168.1.1 est le routeur :
    // expect(find.text('192.168.1.1'), findsOneWidget);
  });
}
