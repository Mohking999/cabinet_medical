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

  testWidgets('Test de montage de la page Login et connexion', (WidgetTester tester) async {
    await tester.pumpWidget(const CabinetMedicalApp());
    await tester.pumpAndSettle();

    // Vérifier les éléments de la page Login
    expect(find.text('Cabinet Médical'), findsOneWidget);
    expect(find.text('Authentification'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Dr. Benali'), findsOneWidget);

    // Se connecter via le bouton principal Se connecter
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    // Vérifier qu'on est arrivé sur l'écran d'accueil avec les onglets
    expect(find.text('Rendez-vous'), findsWidgets);
    expect(find.text('Salle d\'attente'), findsWidgets);
    expect(find.text('Consultation'), findsWidgets);
    expect(find.text('Facturation'), findsWidgets);
  });
}
