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
        String modeSelectionne = 'Espèces (DA)';
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
                    'Règlement Consultation & Chifa',
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
              Text('Montant total : ${f.montantTotal.toStringAsFixed(2)} DA'),
              Text('Part Caisse CNAS/CASNOS : ${f.partRO.toStringAsFixed(2)} DA (Tiers-Payant Chifa)'),
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
                      '${f.resteACharge.toStringAsFixed(2)} DA',
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
                  DropdownMenuItem(value: 'Espèces (DA)', child: Text('Espèces (DA)')),
                  DropdownMenuItem(value: 'Carte CIB / Edahabia', child: Text('Carte CIB / Edahabia')),
                  DropdownMenuItem(value: 'Chèque bancaire', child: Text('Chèque bancaire')),
                  DropdownMenuItem(value: '100% Chifa Chronique', child: Text('100% Chifa Chronique (0 DA)')),
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
                  final isChifa100 = modeSelectionne.contains('100%');
                  await _repo.updateFactureStatut(
                    f.id!,
                    isChifa100 ? 'CLOTUREE_TIERS_PAYANT' : 'PAYEE',
                    modeSelectionne,
                  );
                  _chargerFactures();
                  widget.onDataChanged?.call();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green.shade800,
                        content: Text('Paiement enregistré pour ${f.nomPatient}. Télétransmission Chifa CNAS validée !'),
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
                            'Acte : ${f.acteCode} — Total : ${f.montantTotal.toStringAsFixed(2)} DA',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Row(
                            children: [
                              Text('Part CNAS/Chifa : ${f.partRO.toStringAsFixed(2)} DA  |  ', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                              Text('Ticket Modérateur : ${f.resteACharge.toStringAsFixed(2)} DA', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reste dû : ${isPaye ? "0.00" : f.resteACharge.toStringAsFixed(2)} DA',
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
