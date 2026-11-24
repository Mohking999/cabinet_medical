import '../database/database_helper.dart';
import '../models/patient.dart';
import '../models/rendez_vous.dart';
import '../models/consultation.dart';
import '../models/facture.dart';
import 'cabinet_repository.dart';

/// Implémentation concrète locale connectée à SQLite (sqflite)
class LocalDatabaseRepository implements CabinetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Patient>> getPatients() async {
    final db = await _dbHelper.database;
    final maps = await db.query('patients', orderBy: 'nom ASC');
    return maps.map((e) => Patient.fromMap(e)).toList();
  }

  @override
  Future<int> insertPatient(Patient patient) async {
    final db = await _dbHelper.database;
    return await db.insert('patients', patient.toMap());
  }

  @override
  Future<List<RendezVous>> getRendezVous() async {
    final db = await _dbHelper.database;
    final maps = await db.query('rendez_vous', orderBy: 'id DESC');
    return maps.map((e) => RendezVous.fromMap(e)).toList();
  }

  @override
  Future<int> insertRendezVous(RendezVous rdv) async {
    final db = await _dbHelper.database;
    return await db.insert('rendez_vous', rdv.toMap());
  }

  @override
  Future<void> updateStatutRdv(int rdvId, String statut) async {
    final db = await _dbHelper.database;
    await db.update(
      'rendez_vous',
      {'statut': statut},
      where: 'id = ?',
      whereArgs: [rdvId],
    );
  }

  @override
  Future<List<Consultation>> getConsultations() async {
    final db = await _dbHelper.database;
    final maps = await db.query('consultations', orderBy: 'id DESC');
    return maps.map((e) => Consultation.fromMap(e)).toList();
  }

  @override
  Future<int> insertConsultation(Consultation consultation) async {
    final db = await _dbHelper.database;
    return await db.insert('consultations', consultation.toMap());
  }

  @override
  Future<List<Facture>> getFactures() async {
    final db = await _dbHelper.database;
    final maps = await db.query('factures', orderBy: 'id DESC');
    return maps.map((e) => Facture.fromMap(e)).toList();
  }

  @override
  Future<int> insertFacture(Facture facture) async {
    final db = await _dbHelper.database;
    return await db.insert('factures', facture.toMap());
  }

  @override
  Future<void> updateFactureStatut(int factureId, String statut, String modePaiement) async {
    final db = await _dbHelper.database;
    await db.update(
      'factures',
      {'statut': statut, 'mode_paiement': modePaiement},
      where: 'id = ?',
      whereArgs: [factureId],
    );
  }
}
