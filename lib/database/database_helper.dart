import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/patient.dart';
import '../models/rendez_vous.dart';
import '../models/consultation.dart';
import '../models/facture.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cabinet_medical.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Table Patients
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        telephone TEXT NOT NULL,
        numero_secu TEXT NOT NULL,
        date_naissance TEXT NOT NULL,
        antecedents TEXT,
        allergies TEXT
      )
    ''');

    // 2. Table RendezVous
    await db.execute('''
      CREATE TABLE rendez_vous (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        nom_patient TEXT NOT NULL,
        praticien_nom TEXT NOT NULL,
        date_heure TEXT NOT NULL,
        motif TEXT NOT NULL,
        statut TEXT NOT NULL
      )
    ''');

    // 3. Table Consultations
    await db.execute('''
      CREATE TABLE consultations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        nom_patient TEXT NOT NULL,
        date_heure TEXT NOT NULL,
        constantes TEXT,
        diagnostic TEXT NOT NULL,
        observations TEXT,
        ordonnance_medicaments TEXT NOT NULL
      )
    ''');

    // 4. Table Factures
    await db.execute('''
      CREATE TABLE factures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        consultation_id INTEGER NOT NULL,
        nom_patient TEXT NOT NULL,
        acte_code TEXT NOT NULL,
        montant_total REAL NOT NULL,
        part_ro REAL NOT NULL,
        part_rc REAL NOT NULL,
        reste_a_charge REAL NOT NULL,
        mode_paiement TEXT NOT NULL,
        statut TEXT NOT NULL
      )
    ''');

    // Insérer des données initiales en français pour démarrer
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Patients initiaux (Contexte Algérie / CNAS / CASNOS)
    final p1 = Patient(
      nom: 'Bouzid',
      prenom: 'Karim',
      telephone: '05 50 12 34 56',
      numeroSecu: '01 85 16 012 345 (CNAS)',
      dateNaissance: '14/04/1985',
      antecedents: 'Hypertension artérielle, appendicectomie',
      allergies: 'Pénicilline',
    );
    final p2 = Patient(
      nom: 'Khelifi',
      prenom: 'Amina',
      telephone: '06 61 78 90 12',
      numeroSecu: '02 92 31 456 789 (CASNOS)',
      dateNaissance: '22/11/1992',
      antecedents: 'Asthme modéré',
      allergies: 'Aucune allergie connue',
    );
    final p1Id = await db.insert('patients', p1.toMap());
    final p2Id = await db.insert('patients', p2.toMap());

    // Rendez-vous initiaux
    final r1 = RendezVous(
      patientId: p1Id,
      nomPatient: 'Bouzid Karim',
      praticienNom: 'Dr. Benali (Généraliste)',
      dateHeure: 'Aujourd\'hui 09:30',
      motif: 'Contrôle tension & Renouvellement Chifa',
      statut: 'EN_SALLE_D_ATTENTE',
    );
    final r2 = RendezVous(
      patientId: p2Id,
      nomPatient: 'Khelifi Amina',
      praticienNom: 'Dr. Benali (Généraliste)',
      dateHeure: 'Aujourd\'hui 10:15',
      motif: 'Syndrome grippal & consultation',
      statut: 'CONFIRME',
    );
    await db.insert('rendez_vous', r1.toMap());
    await db.insert('rendez_vous', r2.toMap());

    // Consultation initiale
    final c1 = Consultation(
      patientId: p1Id,
      nomPatient: 'Bouzid Karim',
      dateHeure: '24/11/2026 09:45',
      constantes: 'Tension: 13/8 - Pouls: 70 bpm - Température: 37.0°C',
      diagnostic: 'Stabilité de la tension artérielle. Bilan satisfaisant.',
      observations: 'Bonne observance thérapeutique. À revoir dans 3 mois.',
      ordonnanceMedicaments: 'Amlodipine 5mg : 1 comprimé le matin pendant 3 mois.',
    );
    final c1Id = await db.insert('consultations', c1.toMap());

    // Facture initiale (Tarif en Dinars Algériens DA)
    final f1 = Facture(
      consultationId: c1Id,
      nomPatient: 'Bouzid Karim',
      acteCode: 'Consultation de Médecine Générale',
      montantTotal: 2000.00,
      partRO: 1600.00, // Part CNAS Chifa (80%)
      partRC: 0.00,
      resteACharge: 400.00, // Part Assuré (20%)
      modePaiement: 'En attente',
      statut: 'EN_ATTENTE',
    );
    await db.insert('factures', f1.toMap());
  }
}
