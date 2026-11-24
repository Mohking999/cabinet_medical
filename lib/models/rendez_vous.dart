class RendezVous {
  final int? id;
  final int patientId;
  final String nomPatient;
  final String praticienNom;
  final String dateHeure; // Format ISO: '2026-11-24 10:30'
  final String motif;
  final String statut; // 'CONFIRME', 'EN_SALLE_D_ATTENTE', 'EN_CONSULTATION', 'TERMINE', 'ANNULE'

  RendezVous({
    this.id,
    required this.patientId,
    required this.nomPatient,
    required this.praticienNom,
    required this.dateHeure,
    required this.motif,
    this.statut = 'CONFIRME',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'nom_patient': nomPatient,
      'praticien_nom': praticienNom,
      'date_heure': dateHeure,
      'motif': motif,
      'statut': statut,
    };
  }

  factory RendezVous.fromMap(Map<String, dynamic> map) {
    return RendezVous(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int? ?? 0,
      nomPatient: map['nom_patient'] as String? ?? '',
      praticienNom: map['praticien_nom'] as String? ?? 'Dr. Martin',
      dateHeure: map['date_heure'] as String? ?? '',
      motif: map['motif'] as String? ?? 'Consultation générale',
      statut: map['statut'] as String? ?? 'CONFIRME',
    );
  }

  RendezVous copyWith({String? statut}) {
    return RendezVous(
      id: id,
      patientId: patientId,
      nomPatient: nomPatient,
      praticienNom: praticienNom,
      dateHeure: dateHeure,
      motif: motif,
      statut: statut ?? this.statut,
    );
  }
}
