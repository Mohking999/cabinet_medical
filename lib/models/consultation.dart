class Consultation {
  final int? id;
  final int patientId;
  final String nomPatient;
  final String dateHeure;
  final String constantes; // Ex: 'Tension: 12/8, Pouls: 72 bpm, Temp: 37.1°C'
  final String diagnostic;
  final String observations;
  final String ordonnanceMedicaments; // Ex: 'Amoxicilline 1g (1 matin et soir - 6j)'

  Consultation({
    this.id,
    required this.patientId,
    required this.nomPatient,
    required this.dateHeure,
    required this.constantes,
    required this.diagnostic,
    required this.observations,
    required this.ordonnanceMedicaments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'nom_patient': nomPatient,
      'date_heure': dateHeure,
      'constantes': constantes,
      'diagnostic': diagnostic,
      'observations': observations,
      'ordonnance_medicaments': ordonnanceMedicaments,
    };
  }

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int? ?? 0,
      nomPatient: map['nom_patient'] as String? ?? '',
      dateHeure: map['date_heure'] as String? ?? '',
      constantes: map['constantes'] as String? ?? '',
      diagnostic: map['diagnostic'] as String? ?? '',
      observations: map['observations'] as String? ?? '',
      ordonnanceMedicaments: map['ordonnance_medicaments'] as String? ?? '',
    );
  }
}
