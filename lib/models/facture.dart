class Facture {
  final int? id;
  final int consultationId;
  final String nomPatient;
  final String acteCode; // Ex: 'G' (Consultation Généraliste) ou 'APC'
  final double montantTotal; // Ex: 26.50 €
  final double partRO; // Part Régime Obligatoire (ex: 70% = 18.55 €)
  final double partRC; // Part Complémentaire (ex: 30% = 7.95 €)
  final double resteACharge; // 0 € si ALD/Tiers-payant ou montant à payer
  final String modePaiement; // 'CB', 'ESPECES', 'CHEQUE', 'TIERS_PAYANT_100%'
  final String statut; // 'EN_ATTENTE', 'PAYEE', 'CLOTUREE_TIERS_PAYANT'

  Facture({
    this.id,
    required this.consultationId,
    required this.nomPatient,
    this.acteCode = 'G (Médecine Générale)',
    required this.montantTotal,
    required this.partRO,
    required this.partRC,
    required this.resteACharge,
    this.modePaiement = 'CB',
    this.statut = 'EN_ATTENTE',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultation_id': consultationId,
      'nom_patient': nomPatient,
      'acte_code': acteCode,
      'montant_total': montantTotal,
      'part_ro': partRO,
      'part_rc': partRC,
      'reste_a_charge': resteACharge,
      'mode_paiement': modePaiement,
      'statut': statut,
    };
  }

  factory Facture.fromMap(Map<String, dynamic> map) {
    return Facture(
      id: map['id'] as int?,
      consultationId: map['consultation_id'] as int? ?? 0,
      nomPatient: map['nom_patient'] as String? ?? '',
      acteCode: map['acte_code'] as String? ?? 'G',
      montantTotal: (map['montant_total'] as num?)?.toDouble() ?? 26.50,
      partRO: (map['part_ro'] as num?)?.toDouble() ?? 18.55,
      partRC: (map['part_rc'] as num?)?.toDouble() ?? 7.95,
      resteACharge: (map['reste_a_charge'] as num?)?.toDouble() ?? 0.0,
      modePaiement: map['mode_paiement'] as String? ?? 'CB',
      statut: map['statut'] as String? ?? 'EN_ATTENTE',
    );
  }

  Facture copyWith({String? statut, String? modePaiement}) {
    return Facture(
      id: id,
      consultationId: consultationId,
      nomPatient: nomPatient,
      acteCode: acteCode,
      montantTotal: montantTotal,
      partRO: partRO,
      partRC: partRC,
      resteACharge: resteACharge,
      modePaiement: modePaiement ?? this.modePaiement,
      statut: statut ?? this.statut,
    );
  }
}
