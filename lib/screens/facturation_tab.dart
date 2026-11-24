import 'package:flutter/material.dart';
import '../models/facture.dart';
import '../services/cabinet_repository.dart';
import '../services/repository_provider.dart';
import '../widgets/badge_statut.dart';

class FacturationTab extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const FacturationTab({super.key, this.onDataChanged});

  @override
  State<FacturationTab> createState() => _FacturationTabState();
}

class _FacturationTabState extends State<FacturationTab> {
  final CabinetRepository _repo = RepositoryProvider.repository;
  List<Facture> _factures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerFactures();
  }

  Future<void> _chargerFactures() async {
    setState(() => _isLoading = true);
    final list = await _repo.getFactures();
    if (mounted) {
      setState(() {
        _factures = list;
        _isLoading = false;
      });
    }
  }

  void _encaisserPaiement(Facture f) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String modeSelectionne = 'Carte Bancaire (CB)';
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Règlement de la Consultation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Text('Patient : ${f.nomPatient}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Montant total : ${f.montantTotal.toStringAsFixed(2)} €'),
              Text('Part Caisse (RO 70%) : ${f.partRO.toStringAsFixed(2)} € (Tiers-Payant télétransmis)'),
              Text('Part Mutuelle (RC 30%) : ${f.partRC.toStringAsFixed(2)} €'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reste à charge patient :', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${f.resteACharge.toStringAsFixed(2)} €',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Sélectionner le mode de paiement :'),
              DropdownButtonFormField<String>(
                initialValue: modeSelectionne,
                items: const [
                  DropdownMenuItem(value: 'Carte Bancaire (CB)', child: Text('Carte Bancaire (CB)')),
                  DropdownMenuItem(value: 'Espèces', child: Text('Espèces')),
                  DropdownMenuItem(value: 'Chèque', child: Text('Chèque')),
                  DropdownMenuItem(value: 'Tiers-Payant 100% (ALD/C2S)', child: Text('Tiers-Payant 100% (ALD / C2S - 0 €)')),
                ],
                onChanged: (val) => modeSelectionne = val ?? modeSelectionne,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.print),
                label: const Text('Valider & Imprimer Quittance'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final isAld = modeSelectionne.contains('100%');
                  await _repo.updateFactureStatut(
                    f.id!,
                    isAld ? 'CLOTUREE_TIERS_PAYANT' : 'PAYEE',
                    modeSelectionne,
                  );
                  _chargerFactures();
                  widget.onDataChanged?.call();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green.shade800,
                        content: Text('Paiement enregistré pour ${f.nomPatient}. Télétransmission SESAM-Vitale confirmée !'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _factures.isEmpty
          ? const Center(child: Text('Aucune facture en cours.'))
          : RefreshIndicator(
              onRefresh: _chargerFactures,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _factures.length,
                itemBuilder: (ctx, i) {
                  final f = _factures[i];
                  final isPaye = f.statut == 'PAYEE' || f.statut == 'CLOTUREE_TIERS_PAYANT';

                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                f.nomPatient,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              BadgeStatut(statut: f.statut),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Acte : ${f.acteCode} — Total : ${f.montantTotal.toStringAsFixed(2)} €',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Row(
                            children: [
                              Text('Part CPAM : ${f.partRO.toStringAsFixed(2)} €  |  ', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                              Text('Part Mutuelle : ${f.partRC.toStringAsFixed(2)} €', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reste dû : ${isPaye ? "0.00" : f.resteACharge.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isPaye ? Colors.green.shade800 : Colors.deepOrange,
                                ),
                              ),
                              if (!isPaye)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.payment, size: 18),
                                  label: const Text('Encaisser'),
                                  onPressed: () => _encaisserPaiement(f),
                                )
                              else
                                Row(
                                  children: [
                                    const Icon(Icons.check, color: Colors.green, size: 16),
                                    const SizedBox(width: 4),
                                    Text('Mode : ${f.modePaiement}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
