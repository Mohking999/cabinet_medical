import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/rendez_vous.dart';
import '../services/cabinet_repository.dart';
import '../services/repository_provider.dart';
import '../widgets/badge_statut.dart';

class RendezVousTab extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const RendezVousTab({super.key, this.onDataChanged});

  @override
  State<RendezVousTab> createState() => _RendezVousTabState();
}

class _RendezVousTabState extends State<RendezVousTab> {
  final CabinetRepository _repo = RepositoryProvider.repository;
  List<RendezVous> _rdvs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerRendezVous();
  }

  Future<void> _chargerRendezVous() async {
    setState(() => _isLoading = true);
    final rdvs = await _repo.getRendezVous();
    if (mounted) {
      setState(() {
        _rdvs = rdvs;
        _isLoading = false;
      });
    }
  }

  void _ouvrirDialogueNouveauRdv() async {
    final patients = await _repo.getPatients();
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    int? selectedPatientId = patients.isNotEmpty ? patients.first.id : null;
    String patientNom = patients.isNotEmpty ? patients.first.nomComplet : '';
    String praticien = 'Dr. Dubois (Généraliste)';
    String motif = 'Consultation générale';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    // Contrôleurs pour nouveau patient si besoin
    bool isNouveauPatient = patients.isEmpty;
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final secuCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nouveau Rendez-vous',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          )
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Checkbox(
                            value: isNouveauPatient,
                            onChanged: (val) {
                              setModalState(() {
                                isNouveauPatient = val ?? false;
                              });
                            },
                          ),
                          const Text('Nouveau patient sans dossier'),
                        ],
                      ),
                      if (isNouveauPatient) ...[
                        TextFormField(
                          controller: nomCtrl,
                          decoration: const InputDecoration(labelText: 'Nom de famille *'),
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                        TextFormField(
                          controller: prenomCtrl,
                          decoration: const InputDecoration(labelText: 'Prénom *'),
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                        TextFormField(
                          controller: telCtrl,
                          decoration: const InputDecoration(labelText: 'Téléphone *'),
                          validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                        ),
                        TextFormField(
                          controller: secuCtrl,
                          decoration: const InputDecoration(labelText: 'N° Sécurité Sociale (NIR)'),
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        DropdownButtonFormField<int>(
                          initialValue: selectedPatientId,
                          decoration: const InputDecoration(labelText: 'Sélectionner le patient *'),
                          items: patients.map((p) {
                            return DropdownMenuItem<int>(
                              value: p.id,
                              child: Text(p.nomComplet),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedPatientId = val;
                              patientNom = patients.firstWhere((p) => p.id == val).nomComplet;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: praticien,
                        decoration: const InputDecoration(labelText: 'Médecin Praticien'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Dr. Dubois (Généraliste)',
                            child: Text('Dr. Dubois (Généraliste)'),
                          ),
                          DropdownMenuItem(
                            value: 'Dr. Martin (Pédiatre)',
                            child: Text('Dr. Martin (Pédiatre)'),
                          ),
                        ],
                        onChanged: (v) => praticien = v ?? praticien,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: motif,
                        decoration: const InputDecoration(labelText: 'Motif de consultation'),
                        items: const [
                          DropdownMenuItem(value: 'Consultation générale', child: Text('Consultation générale')),
                          DropdownMenuItem(value: 'Suivi & Traitement', child: Text('Suivi & Traitement')),
                          DropdownMenuItem(value: 'Certificat médical', child: Text('Certificat médical')),
                          DropdownMenuItem(value: 'Urgence relative', child: Text('Urgence relative')),
                        ],
                        onChanged: (v) => motif = v ?? motif,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_month),
                              label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                  lastDate: DateTime.now().add(const Duration(days: 60)),
                                );
                                if (d != null) {
                                  setModalState(() => selectedDate = d);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(selectedTime.format(context)),
                              onPressed: () async {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (t != null) {
                                  setModalState(() => selectedTime = t);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmer le Rendez-vous', style: TextStyle(fontSize: 16)),
                        onPressed: () async {
                          final nav = Navigator.of(ctx);
                          final messenger = ScaffoldMessenger.of(context);

                          if (formKey.currentState?.validate() ?? false) {
                            int patientId;
                            if (isNouveauPatient) {
                              final newPatient = Patient(
                                nom: nomCtrl.text.trim(),
                                prenom: prenomCtrl.text.trim(),
                                telephone: telCtrl.text.trim(),
                                numeroSecu: secuCtrl.text.trim().isEmpty ? 'Non renseigné' : secuCtrl.text.trim(),
                                dateNaissance: '01/01/1990',
                              );
                              patientId = await _repo.insertPatient(newPatient);
                              patientNom = newPatient.nomComplet;
                            } else {
                              patientId = selectedPatientId!;
                            }

                            final dateStr =
                                '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year} à ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                            final rdv = RendezVous(
                              patientId: patientId,
                              nomPatient: patientNom,
                              praticienNom: praticien,
                              dateHeure: dateStr,
                              motif: motif,
                              statut: 'CONFIRME',
                            );

                            await _repo.insertRendezVous(rdv);
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green.shade800,
                                content: Text('Rendez-vous confirmé pour $patientNom ! SMS de rappel envoyé.'),
                              ),
                            );
                            _chargerRendezVous();
                            widget.onDataChanged?.call();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rdvs.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun rendez-vous planifié.\nCliquez sur + pour créer un RDV.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _chargerRendezVous,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _rdvs.length,
                    itemBuilder: (ctx, i) {
                      final rdv = _rdvs[i];
                      return Card(
                        elevation: 1.5,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade50,
                            child: const Icon(Icons.person, color: Colors.teal),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rdv.nomPatient,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              BadgeStatut(statut: rdv.statut),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(rdv.dateHeure, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              Text(
                                '${rdv.motif} (${rdv.praticienNom})',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: rdv.statut == 'CONFIRME'
                              ? IconButton(
                                  tooltip: 'Pointer l\'arrivée (Salle d\'attente)',
                                  icon: const Icon(Icons.how_to_reg, color: Colors.teal),
                                  onPressed: () async {
                                    await _repo.updateStatutRdv(rdv.id!, 'EN_SALLE_D_ATTENTE');
                                    _chargerRendezVous();
                                    widget.onDataChanged?.call();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${rdv.nomPatient} marqué en salle d\'attente.'),
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau RDV'),
        onPressed: _ouvrirDialogueNouveauRdv,
      ),
    );
  }
}
