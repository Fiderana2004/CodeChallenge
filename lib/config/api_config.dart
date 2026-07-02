class ApiConfig {
  // Changez cette URL selon votre environnement
  // Android émulateur  : http://10.0.2.2:3000
  // iOS simulateur     : http://localhost:3000
  // Appareil physique  : http://<IP_locale>:3000
  static const String baseUrl = 'https://backend-codechallenge.onrender.com/api';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}