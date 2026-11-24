import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/rendez_vous.dart';
import '../models/consultation.dart';
import '../models/facture.dart';
import 'cabinet_repository.dart';

/// Implémentation alternative connectée à une API REST distante.
/// Prévue pour brancher un serveur Node.js, Spring Boot, Laravel ou Python.
/// Répond à la demande : "make place for api or to connect from database".
class ApiCabinetRepository implements CabinetRepository {
  // URL de base de votre API distante
  final String baseUrl;
  final http.Client client;

  ApiCabinetRepository({
    this.baseUrl = 'https://api.votre-cabinet-medical.fr/v1',
    http.Client? httpClient,
  }) : client = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Authorization': 'Bearer VOTRE_TOKEN_JWT',
      };

  @override
  Future<List<Patient>> getPatients() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/patients'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Patient.fromMap(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      // Fallback ou journalisation
      return [];
    }
  }

  @override
  Future<int> insertPatient(Patient patient) async {
    final response = await client.post(
      Uri.parse('$baseUrl/patients'),
      headers: _headers,
      body: jsonEncode(patient.toMap()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as int? ?? 1;
    }
    return 1;
  }

  @override
  Future<List<RendezVous>> getRendezVous() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/rendez-vous'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => RendezVous.fromMap(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> insertRendezVous(RendezVous rdv) async {
    final response = await client.post(
      Uri.parse('$baseUrl/rendez-vous'),
      headers: _headers,
      body: jsonEncode(rdv.toMap()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as int? ?? 1;
    }
    return 1;
  }

  @override
  Future<void> updateStatutRdv(int rdvId, String statut) async {
    await client.patch(
      Uri.parse('$baseUrl/rendez-vous/$rdvId'),
      headers: _headers,
      body: jsonEncode({'statut': statut}),
    );
  }

  @override
  Future<List<Consultation>> getConsultations() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/consultations'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Consultation.fromMap(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> insertConsultation(Consultation consultation) async {
    final response = await client.post(
      Uri.parse('$baseUrl/consultations'),
      headers: _headers,
      body: jsonEncode(consultation.toMap()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as int? ?? 1;
    }
    return 1;
  }

  @override
  Future<List<Facture>> getFactures() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/factures'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Facture.fromMap(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> insertFacture(Facture facture) async {
    final response = await client.post(
      Uri.parse('$baseUrl/factures'),
      headers: _headers,
      body: jsonEncode(facture.toMap()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as int? ?? 1;
    }
    return 1;
  }

  @override
  Future<void> updateFactureStatut(int factureId, String statut, String modePaiement) async {
    await client.patch(
      Uri.parse('$baseUrl/factures/$factureId'),
      headers: _headers,
      body: jsonEncode({
        'statut': statut,
        'mode_paiement': modePaiement,
      }),
    );
  }
}
