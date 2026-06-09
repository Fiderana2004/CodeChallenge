class Defi {
  final int id;
  final String titre;
  final String description;
  final String difficulte;
  final int points;
  final String langage;

  Defi({
    required this.id,
    required this.titre,
    required this.description,
    required this.difficulte,
    required this.points,
    required this.langage,
  });

  factory Defi.fromJson(Map<String, dynamic> json) {
    return Defi(
      id: json['id_defi'],
      titre: json['titre'],
      description: json['description'],
      difficulte: json['difficulte'],
      points: json['points'],
      langage: json['langage'],
    );
  }
}