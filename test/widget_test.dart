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

  test('Test unitaire des modèles Patient et RendezVous', () {
    final patient = Patient(
      id: 1,
      nom: 'Dupont',
      prenom: 'Jean',
      telephone: '06 12 34 56 78',
      numeroSecu: '1850475012345',
      dateNaissance: '14/04/1985',
      antecedents: 'Hypertension',
      allergies: 'Pénicilline',
    );

    expect(patient.nomComplet, 'Dupont Jean');
    final map = patient.toMap();
    expect(map['nom'], 'Dupont');

    final rdv = RendezVous(
      patientId: 1,
      nomPatient: 'Dupont Jean',
      praticienNom: 'Dr. Dubois',
      dateHeure: '24/11/2026 à 10:00',
      motif: 'Contrôle annuel',
      statut: 'CONFIRME',
    );
    expect(rdv.statut, 'CONFIRME');

    final facture = Facture(
      consultationId: 1,
      nomPatient: 'Dupont Jean',
      montantTotal: 26.50,
      partRO: 18.55,
      partRC: 7.95,
      resteACharge: 7.95,
    );
    expect(facture.montantTotal, 26.50);
  });

  testWidgets('Test de montage de CabinetMedicalApp', (WidgetTester tester) async {
    await tester.pumpWidget(const CabinetMedicalApp());
    await tester.pumpAndSettle();

    // Vérifier la présence du titre et de la barre de navigation
    expect(find.text('Cabinet Médical'), findsOneWidget);
    expect(find.text('Rendez-vous'), findsWidgets);
    expect(find.text('Salle d\'attente'), findsWidgets);
    expect(find.text('Consultation'), findsWidgets);
    expect(find.text('Facturation'), findsWidgets);
  });
}
