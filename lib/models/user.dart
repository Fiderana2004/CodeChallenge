class User {
  final int idUser;
  final String nom;
  final String email;
  final int points;
  final String niveau;

  User({
    required this.idUser,
    required this.nom,
    required this.email,
    required this.points,
    required this.niveau,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        idUser: json['id_user'],
        nom:    json['nom'],
        email:  json['email'],
        points: json['points'] ?? 0,
        niveau: json['niveau'] ?? 'debutant',
      );

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'nom':     nom,
        'email':   email,
        'points':  points,
        'niveau':  niveau,
      };
}