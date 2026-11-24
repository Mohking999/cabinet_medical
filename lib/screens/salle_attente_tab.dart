import 'package:flutter/material.dart';
import '../models/rendez_vous.dart';
import '../services/cabinet_repository.dart';
import '../services/repository_provider.dart';
import '../widgets/badge_statut.dart';

class SalleAttenteTab extends StatefulWidget {
  final Function(RendezVous rdv)? onAppelerEnConsultation;
  final VoidCallback? onDataChanged;

  const SalleAttenteTab({
    super.key,
    this.onAppelerEnConsultation,
    this.onDataChanged,
  });

  @override
  State<SalleAttenteTab> createState() => _SalleAttenteTabState();
}

class _SalleAttenteTabState extends State<SalleAttenteTab> {
  final CabinetRepository _repo = RepositoryProvider.repository;
  List<RendezVous> _enAttente = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerSalleAttente();
  }

  Future<void> _chargerSalleAttente() async {
    setState(() => _isLoading = true);
    final tous = await _repo.getRendezVous();
    if (mounted) {
      setState(() {
        _enAttente = tous.where((r) => r.statut == 'EN_SALLE_D_ATTENTE').toList();
        _isLoading = false;
      });
    }
  }

  void _simulerLectureCarteChifa() async {
    final tous = await _repo.getRendezVous();
    final confirmes = tous.where((r) => r.statut == 'CONFIRME').toList();

    if (!mounted) return;

    if (confirmes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun patient avec RDV confirmé en attente d\'arrivée.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.credit_card, color: Colors.green),
              SizedBox(width: 8),
              Text('Lecture Carte Chifa (الشفاء)'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sélectionnez le patient qui vient de présenter sa Carte Chifa (CNAS/CASNOS) :'),
              const SizedBox(height: 12),
              ...confirmes.map((r) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.person),
                    title: Text(r.nomPatient),
                    subtitle: Text(r.dateHeure),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _repo.updateStatutRdv(r.id!, 'EN_SALLE_D_ATTENTE');
                      _chargerSalleAttente();
                      widget.onDataChanged?.call();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green.shade800,
                          content: Text('Carte Chifa validée pour ${r.nomPatient} ! Placé en salle d\'attente.'),
                        ),
                      );
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.amber.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_enAttente.length} patient(s) actuellement présent(s) en salle d\'attente.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.contactless, size: 18),
                        label: const Text('Carte Chifa'),
                        onPressed: _simulerLectureCarteChifa,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _enAttente.isEmpty
                      ? const Center(
                          child: Text(
                            'La salle d\'attente est vide.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _chargerSalleAttente,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _enAttente.length,
                            itemBuilder: (ctx, i) {
                              final rdv = _enAttente[i];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.amber.shade100,
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rdv.nomPatient,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Motif : ${rdv.motif}',
                                              style: TextStyle(color: Colors.grey.shade700),
                                            ),
                                            const SizedBox(height: 4),
                                            const BadgeStatut(statut: 'EN_SALLE_D_ATTENTE'),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          foregroundColor: Colors.white,
                                        ),
                                        icon: const Icon(Icons.door_front_door),
                                        label: const Text('Appeler'),
                                        onPressed: () {
                                          widget.onAppelerEnConsultation?.call(rdv);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
