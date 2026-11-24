import '../models/patient.dart';
import '../models/rendez_vous.dart';
import '../models/consultation.dart';
import '../models/facture.dart';

/// Contrat d'accès aux données (Architecture Repository Pattern)
/// Permet d'alterner en toute transparence entre la base locale SQLite
/// et une API REST distante selon la configuration.
abstract class CabinetRepository {
  // Patients
  Future<List<Patient>> getPatients();
  Future<int> insertPatient(Patient patient);

  // Rendez-vous
  Future<List<RendezVous>> getRendezVous();
  Future<int> insertRendezVous(RendezVous rdv);
  Future<void> updateStatutRdv(int rdvId, String statut);

  // Consultations & Ordonnances
  Future<List<Consultation>> getConsultations();
  Future<int> insertConsultation(Consultation consultation);

  // Factures & SESAM-Vitale
  Future<List<Facture>> getFactures();
  Future<int> insertFacture(Facture facture);
  Future<void> updateFactureStatut(int factureId, String statut, String modePaiement);
}
