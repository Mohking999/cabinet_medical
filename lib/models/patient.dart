class Patient {
  final int? id;
  final String nom;
  final String prenom;
  final String telephone;
  final String numeroSecu;
  final String dateNaissance;
  final String antecedents;
  final String allergies;

  Patient({
    this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.numeroSecu,
    required this.dateNaissance,
    this.antecedents = 'Aucun antécédent notable',
    this.allergies = 'Aucune allergie connue',
  });

  String get nomComplet => '$nom $prenom';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'numero_secu': numeroSecu,
      'date_naissance': dateNaissance,
      'antecedents': antecedents,
      'allergies': allergies,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      nom: map['nom'] as String? ?? '',
      prenom: map['prenom'] as String? ?? '',
      telephone: map['telephone'] as String? ?? '',
      numeroSecu: map['numero_secu'] as String? ?? '',
      dateNaissance: map['date_naissance'] as String? ?? '',
      antecedents: map['antecedents'] as String? ?? 'Aucun',
      allergies: map['allergies'] as String? ?? 'Aucune',
    );
  }
}
