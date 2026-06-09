class Soumission {
  final int idSoumission;
  final int idUser;
  final int idDefi;
  final String codeSource;
  final String resultat;
  final int pointsGagnes;
  final DateTime dateSoumission;
  final String? titreDefi;
  final String? langageDefi;
  final String? difficulteDefi;

  Soumission({
    required this.idSoumission,
    required this.idUser,
    required this.idDefi,
    required this.codeSource,
    required this.resultat,
    required this.pointsGagnes,
    required this.dateSoumission,
    this.titreDefi,
    this.langageDefi,
    this.difficulteDefi,
  });

  bool get estCorrect => resultat == 'correct';

  factory Soumission.fromJson(Map<String, dynamic> json) => Soumission(
        idSoumission:   json['id_soumission'],
        idUser:         json['id_user'],
        idDefi:         json['id_defi'],
        codeSource:     json['code_source'] ?? '',
        resultat:       json['resultat'] ?? 'incorrect',
        pointsGagnes:   json['points_gagnes'] ?? 0,
        dateSoumission: DateTime.parse(json['date_soumission']),
        titreDefi:      json['titre'],
        langageDefi:    json['langage'],
        difficulteDefi: json['difficulte'],
      );
}

class SoumissionResult {
  final String resultat;
  final int pointsGagnes;
  final String stdout;
  final String stderr;
  final String? erreur;

  SoumissionResult({
    required this.resultat,
    required this.pointsGagnes,
    required this.stdout,
    required this.stderr,
    this.erreur,
  });

  bool get estCorrect => resultat == 'correct';

  factory SoumissionResult.fromJson(Map<String, dynamic> json) =>
      SoumissionResult(
        resultat:     json['resultat'],
        pointsGagnes: json['points_gagnes'] ?? 0,
        stdout:       json['stdout'] ?? '',
        stderr:       json['stderr'] ?? '',
        erreur:       json['erreur'],
      );
}