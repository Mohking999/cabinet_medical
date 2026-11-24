import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/rendez_vous.dart';
import '../models/consultation.dart';
import '../models/facture.dart';
import '../services/cabinet_repository.dart';
import '../services/repository_provider.dart';
import '../widgets/badge_statut.dart';
import 'login_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  final Patient patient;

  const ClientHomeScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final CabinetRepository _repo = RepositoryProvider.repository;
  int _currentIndex = 0;
  bool _isLoading = true;

  List<RendezVous> _mesRendezVous = [];
  List<Consultation> _mesConsultations = [];
  List<Facture> _mesFactures = [];

  @override
  void initState() {
    super.initState();
    _chargerDonneesPatient();
  }

  Future<void> _chargerDonneesPatient() async {
    setState(() => _isLoading = true);
    final tousRdvs = await _repo.getRendezVous();
    final toutesConsults = await _repo.getConsultations();
    final toutesFactures = await _repo.getFactures();

    if (mounted) {
      setState(() {
        // Filtrer les données pour ce patient spécifique
        _mesRendezVous = tousRdvs
            .where((r) => r.patientId == widget.patient.id || r.nomPatient.contains(widget.patient.nom))
            .toList();
        _mesConsultations = toutesConsults
            .where((c) => c.patientId == widget.patient.id || c.nomPatient.contains(widget.patient.nom))
            .toList();
        _mesFactures = toutesFactures
            .where((f) => f.nomPatient.contains(widget.patient.nom))
            .toList();
        _isLoading = false;
      });
    }
  }

  void _ouvrirDialogueNouveauRdv() async {
    final formKey = GlobalKey<FormState>();
    String praticien = 'Dr. Benali (Généraliste)';
    String motif = 'Consultation générale';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 30);

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
                          const Row(
                            children: [
                              Icon(Icons.calendar_month, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Prendre un RDV en ligne',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          )
                        ],
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Patient : ${widget.patient.nomComplet} (Carte Chifa : ${widget.patient.numeroSecu})',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal.shade900, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: praticien,
                        decoration: const InputDecoration(labelText: 'Choisir le Médecin *'),
                        items: const [
                          DropdownMenuItem(value: 'Dr. Benali (Généraliste)', child: Text('Dr. Benali (Généraliste)')),
                          DropdownMenuItem(value: 'Dr. Mansouri (Spécialiste)', child: Text('Dr. Mansouri (Spécialiste)')),
                        ],
                        onChanged: (v) => praticien = v ?? praticien,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: motif,
                        decoration: const InputDecoration(labelText: 'Motif de votre consultation *'),
                        items: const [
                          DropdownMenuItem(value: 'Consultation générale', child: Text('Consultation générale')),
                          DropdownMenuItem(value: 'Renouvellement ordonnance Chifa', child: Text('Renouvellement ordonnance Chifa')),
                          DropdownMenuItem(value: 'Suivi de tension / Diabète', child: Text('Suivi de tension / Diabète')),
                          DropdownMenuItem(value: 'Certificat médical', child: Text('Certificat médical')),
                        ],
                        onChanged: (v) => motif = v ?? motif,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 60)),
                                );
                                if (d != null) setModalState(() => selectedDate = d);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time, size: 16),
                              label: Text(selectedTime.format(context)),
                              onPressed: () async {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (t != null) setModalState(() => selectedTime = t);
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
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirmer la Réservation', style: TextStyle(fontSize: 16)),
                        onPressed: () async {
                          final nav = Navigator.of(ctx);
                          final messenger = ScaffoldMessenger.of(context);

                          if (formKey.currentState?.validate() ?? false) {
                            final dateStr =
                                '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year} à ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                            final rdv = RendezVous(
                              patientId: widget.patient.id ?? 1,
                              nomPatient: widget.patient.nomComplet,
                              praticienNom: praticien,
                              dateHeure: dateStr,
                              motif: motif,
                              statut: 'CONFIRME',
                            );

                            await _repo.insertRendezVous(rdv);
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.teal.shade800,
                                content: Text('Rendez-vous réservé avec succès pour le $dateStr !'),
                              ),
                            );
                            _chargerDonneesPatient();
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

  void _deconnexion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Déconnexion'),
          ],
        ),
        content: const Text('Voulez-vous quitter votre espace patient ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  // Onglet 1 : Mes Rendez-vous
  Widget _buildRendezVousTab() {
    return Scaffold(
      body: _mesRendezVous.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Vous n\'avez aucun rendez-vous planifié.'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    icon: const Icon(Icons.add),
                    label: const Text('Prendre un RDV en ligne'),
                    onPressed: _ouvrirDialogueNouveauRdv,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _chargerDonneesPatient,
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: _mesRendezVous.length,
                itemBuilder: (ctx, i) {
                  final rdv = _mesRendezVous[i];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: Colors.teal, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    rdv.dateHeure,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                              BadgeStatut(statut: rdv.statut),
                            ],
                          ),
                          const Divider(height: 18),
                          Text('Médecin : ${rdv.praticienNom}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('Motif : ${rdv.motif}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Prendre un RDV'),
        onPressed: _ouvrirDialogueNouveauRdv,
      ),
    );
  }

  // Onglet 2 : Mes Ordonnances
  Widget _buildOrdonnancesTab() {
    return _mesConsultations.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication_liquid_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('Aucune ordonnance délivrée pour le moment.'),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _chargerDonneesPatient,
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _mesConsultations.length,
              itemBuilder: (ctx, i) {
                final c = _mesConsultations[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.article, color: Colors.teal),
                                SizedBox(width: 8),
                                Text(
                                  'Ordonnance Médicale',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: const Text('Chifa Validé', style: TextStyle(fontSize: 11, color: Colors.green)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Date : ${c.dateHeure}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Text('Diagnostic : ${c.diagnostic}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Divider(height: 20),
                        const Text(
                          'Traitements prescrits :',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            c.ordonnanceMedicaments,
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  // Onglet 3 : Factures & Remboursements Chifa
  Widget _buildFacturesTab() {
    return _mesFactures.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('Aucune facture enregistrée.'),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _chargerDonneesPatient,
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _mesFactures.length,
              itemBuilder: (ctx, i) {
                final f = _mesFactures[i];
                final isPaye = f.statut == 'PAYEE' || f.statut == 'CLOTUREE_TIERS_PAYANT';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              f.acteCode,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            BadgeStatut(statut: f.statut),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Montant total :'),
                            Text('${f.montantTotal.toStringAsFixed(2)} DA', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Part prise en charge CNAS (80%) :'),
                            Text('${f.partRO.toStringAsFixed(2)} DA', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Reste à votre charge (20%) :'),
                            Text(
                              '${isPaye ? "0.00" : f.resteACharge.toStringAsFixed(2)} DA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPaye ? Colors.green.shade800 : Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                        if (isPaye) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text('Règlement effectué (${f.modePaiement})', style: const TextStyle(fontSize: 12, color: Colors.green)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  // Onglet 4 : Profil Patient & Carte Chifa
  Widget _buildProfilTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte Chifa Numérique Algérienne
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.teal.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RÉPUBLIQUE ALGÉRIENNE',
                      style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('CNAS / CASNOS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.memory, size: 20, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'CARTE CHIFA (بطاقة الشفاء)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.patient.nomComplet.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'N° NSS : ${widget.patient.numeroSecu}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                ),
                Text(
                  'Né(e) le : ${widget.patient.dateNaissance}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Dossier Médical & Antécédents
          const Text('Données Médicales Personnelles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.phone, color: Colors.teal),
                    title: const Text('Téléphone'),
                    subtitle: Text(widget.patient.telephone),
                  ),
                  const Divider(),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_edu, color: Colors.indigo),
                    title: const Text('Antécédents médicaux'),
                    subtitle: Text(widget.patient.antecedents),
                  ),
                  const Divider(),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: const Text('Allergies connues'),
                    subtitle: Text(
                      widget.patient.allergies,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      _buildRendezVousTab(),
      _buildOrdonnancesTab(),
      _buildFacturesTab(),
      _buildProfilTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              radius: 18,
              child: Text(
                widget.patient.nom.substring(0, 1),
                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patient.nomComplet,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  'Espace Patient • Carte Chifa',
                  style: TextStyle(fontSize: 11, color: Colors.teal),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _deconnexion,
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Mes RDV',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Ordonnances',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_outlined),
            selectedIcon: Icon(Icons.receipt),
            label: 'Chifa / Factures',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Carte Chifa',
          ),
        ],
      ),
    );
  }
}
