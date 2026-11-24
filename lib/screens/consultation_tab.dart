import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/rendez_vous.dart';
import '../models/consultation.dart';
import '../models/facture.dart';
import '../services/cabinet_repository.dart';
import '../services/repository_provider.dart';

class ConsultationTab extends StatefulWidget {
  final RendezVous? rdvActif;
  final VoidCallback? onConsultationTerminee;

  const ConsultationTab({
    super.key,
    this.rdvActif,
    this.onConsultationTerminee,
  });

  @override
  State<ConsultationTab> createState() => _ConsultationTabState();
}

class _ConsultationTabState extends State<ConsultationTab> {
  final CabinetRepository _repo = RepositoryProvider.repository;
  List<Consultation> _historique = [];
  bool _isLoading = true;

  // Formulaire de consultation en cours
  RendezVous? _patientEnCours;
  Patient? _dossierMedical;

  final _constantesCtrl = TextEditingController(text: 'Tension: 12/8 - Pouls: 72 bpm - Température: 37.1°C');
  final _diagCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _ordoCtrl = TextEditingController();
  bool _alertePharmaceutique = false;

  @override
  void initState() {
    super.initState();
    _patientEnCours = widget.rdvActif;
    _chargerDonnees();
  }

  @override
  void didUpdateWidget(covariant ConsultationTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rdvActif != oldWidget.rdvActif && widget.rdvActif != null) {
      setState(() {
        _patientEnCours = widget.rdvActif;
      });
      _chargerDossierMedical();
    }
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    final consults = await _repo.getConsultations();
    if (mounted) {
      setState(() {
        _historique = consults;
        _isLoading = false;
      });
    }
    if (_patientEnCours != null) {
      await _chargerDossierMedical();
    }
  }

  Future<void> _chargerDossierMedical() async {
    if (_patientEnCours == null) return;
    final patients = await _repo.getPatients();
    final p = patients.where((x) => x.id == _patientEnCours!.patientId);
    if (p.isNotEmpty && mounted) {
      setState(() {
        _dossierMedical = p.first;
      });
    }
  }

  void _verifierSecuritePharmaceutique(String texteOrdonnance) {
    // Règle métier UML : Détection automatique des allergies croisées
    if (_dossierMedical != null && _dossierMedical!.allergies.isNotEmpty) {
      final allergyLower = _dossierMedical!.allergies.toLowerCase();
      final ordoLower = texteOrdonnance.toLowerCase();

      bool alerte = false;
      if (allergyLower.contains('pénicilline') && (ordoLower.contains('amoxicilline') || ordoLower.contains('augmentin'))) {
        alerte = true;
      }

      setState(() {
        _alertePharmaceutique = alerte;
      });
    }
  }

  Future<void> _validerEtGenererOrdonnance() async {
    if (_patientEnCours == null) return;
    if (_diagCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un diagnostic.')),
      );
      return;
    }

    final dateStr = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} à ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    // 1. Sauvegarder la consultation
    final consult = Consultation(
      patientId: _patientEnCours!.patientId,
      nomPatient: _patientEnCours!.nomPatient,
      dateHeure: dateStr,
      constantes: _constantesCtrl.text.trim(),
      diagnostic: _diagCtrl.text.trim(),
      observations: _obsCtrl.text.trim().isEmpty ? 'R.A.S' : _obsCtrl.text.trim(),
      ordonnanceMedicaments: _ordoCtrl.text.trim().isEmpty ? 'Pas de prescription requise' : _ordoCtrl.text.trim(),
    );
    final consultId = await _repo.insertConsultation(consult);

    // 2. Mettre à jour le statut du RDV
    if (_patientEnCours!.id != null) {
      await _repo.updateStatutRdv(_patientEnCours!.id!, 'TERMINE');
    }

    // 3. Générer automatiquement la facture associée
    final facture = Facture(
      consultationId: consultId,
      nomPatient: _patientEnCours!.nomPatient,
      acteCode: 'G (Médecine Générale)',
      montantTotal: 26.50,
      partRO: 18.55,
      partRC: 7.95,
      resteACharge: 7.95,
      statut: 'EN_ATTENTE',
    );
    await _repo.insertFacture(facture);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.teal.shade800,
          content: Text('Consultation clôturée pour ${_patientEnCours!.nomPatient}. Facture générée pour la secrétaire.'),
        ),
      );

      setState(() {
        _patientEnCours = null;
        _dossierMedical = null;
        _diagCtrl.clear();
        _obsCtrl.clear();
        _ordoCtrl.clear();
        _alertePharmaceutique = false;
      });

      await _chargerDonnees();
      widget.onConsultationTerminee?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1 : Consultation active du médecin
            if (_patientEnCours != null) ...[
              Card(
                color: Colors.teal.shade50,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services, color: Colors.teal, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Consultation en cours : ${_patientEnCours!.nomPatient}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Dossier Médical / Antécédents / Allergies (Thinking du diagramme)
                      if (_dossierMedical != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.history_edu, size: 16, color: Colors.indigo),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Dossier Médical (DMI)',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('• Antécédents : ${_dossierMedical!.antecedents}', style: const TextStyle(fontSize: 13)),
                              Text(
                                '• Allergies : ${_dossierMedical!.allergies}',
                                style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _constantesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Constantes vitales (Tension, Pouls, Température)',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _diagCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Diagnostic & Examen clinique *',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _obsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Observations médicales',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _ordoCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Prescription / Ordonnance (Médicaments, posologie, durée)',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: _verifierSecuritePharmaceutique,
                      ),
                      // Bannière d'alerte sécurité médicamenteuse (Diagramme UML)
                      if (_alertePharmaceutique) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ALERTE PHARMACEUTIQUE : Ce médicament contient de la pénicilline à laquelle le patient est allergique ! Remplacer la molécule.',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Valider & Télétransmettre Ordonnance', style: TextStyle(fontSize: 16)),
                          onPressed: _validerEtGenererOrdonnance,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Section 2 : Historique des consultations
            const Text(
              'Historique des Consultations & Prescriptions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_historique.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Aucune consultation enregistrée.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _historique.length,
                itemBuilder: (ctx, i) {
                  final c = _historique[i];
                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ExpansionTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.description, color: Colors.white),
                      ),
                      title: Text(c.nomPatient, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${c.dateHeure} — ${c.diagnostic}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Constantes : ${c.constantes}', style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Observations : ${c.observations}', style: const TextStyle(fontSize: 13)),
                              const Divider(),
                              const Text('Ordonnance délivrée :', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                              const SizedBox(height: 4),
                              Text(c.ordonnanceMedicaments, style: const TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
