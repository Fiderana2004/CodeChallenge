import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // =========================
  // 🔥 LOGIN
  // =========================
  static Future<Map<String, dynamic>> login(
    String email,
    String motDePasse,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "mot_de_passe": motDePasse,
        }),
      );

      final data = jsonDecode(response.body);
      print("LOGIN RESPONSE: $data");

      if (response.statusCode != 200 || data == null) {
        return {
          "success": false,
          "message": data["message"] ?? "Erreur login",
        };
      }

      // Support backend: "user" OU "utilisateur"
      final user = data["user"] ?? data["utilisateur"];

      if (user == null) {
        return {"success": false, "message": "Utilisateur introuvable"};
      }

      // ✅ Tout passe par "user" — plus de crash
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("id_user", user["id_user"] ?? user["id"] ?? 0);
      await prefs.setString("nom",    user["nom"]    ?? "");
      await prefs.setString("email",  user["email"]  ?? "");
      await prefs.setInt("points",    user["points"] ?? 0);
      await prefs.setString("niveau", user["niveau"] ?? "debutant");

      if (data["token"] != null) {
        await prefs.setString("token", data["token"]);
      }

      return {
        "success": true,
        "user": user,
        "token": data["token"],
      };

    } catch (e) {
      return {"success": false, "message": "Erreur serveur : $e"};
    }
  }

  // =========================
  // 🆕 REGISTER
  // =========================
  static Future<Map<String, dynamic>> register(
    String nom,
    String email,
    String motDePasse,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nom,
          "email": email,
          "mot_de_passe": motDePasse,
        }),
      );

      final data = jsonDecode(response.body);
      print("REGISTER RESPONSE: $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Compte créé avec succès",
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Erreur register",
      };

    } catch (e) {
      return {"success": false, "message": "Erreur serveur : $e"};
    }
  }

  // =========================
  // 🔑 GET USER LOCAL
  // =========================
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "id_user": prefs.getInt("id_user"),
      "nom":     prefs.getString("nom"),
      "email":   prefs.getString("email"),
      "points":  prefs.getInt("points"),
      "niveau":  prefs.getString("niveau"),
      "token":   prefs.getString("token"),
    };
  }

  // =========================
  // 🚪 LOGOUT
  // =========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}