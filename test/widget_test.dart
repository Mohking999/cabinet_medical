import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cabinet_medical/main.dart';
import 'package:cabinet_medical/models/patient.dart';
import 'package:cabinet_medical/models/rendez_vous.dart';
import 'package:cabinet_medical/models/facture.dart';
import 'package:cabinet_medical/services/repository_provider.dart';

void main() {
  setUp(() {
    // Activer le mode API/Mock pour éviter l'initialisation native SQLite en test unitaire
    RepositoryProvider.useRemoteApi = true;
  });

  tearDown(() {
    RepositoryProvider.useRemoteApi = false;
  });

  test('Test unitaire des modèles Algérie (Patient, RendezVous, Facture DA)', () {
    final patient = Patient(
      id: 1,
      nom: 'Bouzid',
      prenom: 'Karim',
      telephone: '05 50 12 34 56',
      numeroSecu: '01 85 16 012 345 (CNAS)',
      dateNaissance: '14/04/1985',
      antecedents: 'Hypertension',
      allergies: 'Pénicilline',
    );

    expect(patient.nomComplet, 'Bouzid Karim');
    final map = patient.toMap();
    expect(map['nom'], 'Bouzid');

    final rdv = RendezVous(
      patientId: 1,
      nomPatient: 'Bouzid Karim',
      praticienNom: 'Dr. Benali',
      dateHeure: '24/11/2026 à 10:00',
      motif: 'Contrôle Chifa',
      statut: 'CONFIRME',
    );
    expect(rdv.statut, 'CONFIRME');

    final facture = Facture(
      consultationId: 1,
      nomPatient: 'Bouzid Karim',
      montantTotal: 2000.00,
      partRO: 1600.00, // Part CNAS Chifa
      partRC: 0.00,
      resteACharge: 400.00, // Part Assuré
    );
    expect(facture.montantTotal, 2000.00);
    expect(facture.partRO, 1600.00);
  });

  testWidgets('Test de montage de la page Login et connexion Praticien', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CabinetMedicalApp());
    await tester.pumpAndSettle();

    // Vérifier les éléments de la page Login
    expect(find.text('Cabinet Médical'), findsOneWidget);
    expect(find.text('Authentification'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Dr. Benali'), findsOneWidget);

    // Se connecter via le bouton principal Se connecter
    final loginButton = find.text('Se connecter');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Vérifier qu'on est arrivé sur l'écran d'accueil avec les onglets praticien
    expect(find.text('Rendez-vous'), findsWidgets);
    expect(find.text('Salle d\'attente'), findsWidgets);
    expect(find.text('Consultation'), findsWidgets);
    expect(find.text('Facturation'), findsWidgets);
  });

  testWidgets('Test de connexion et navigation côté Patient (Client Side)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CabinetMedicalApp());
    await tester.pumpAndSettle();

    // Sélectionner le rôle Patient (Client)
    final patientChip = find.text('Patient (Client)');
    await tester.ensureVisible(patientChip);
    await tester.tap(patientChip);
    await tester.pumpAndSettle();

    // Se connecter
    final loginButton = find.text('Se connecter');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Vérifier qu'on est arrivé sur l'Espace Patient
    expect(find.text('Espace Patient • Carte Chifa'), findsOneWidget);
    expect(find.text('Mes RDV'), findsWidgets);
    expect(find.text('Ordonnances'), findsWidgets);
    expect(find.text('Chifa / Factures'), findsWidgets);
    expect(find.text('Carte Chifa'), findsWidgets);
  });
}
