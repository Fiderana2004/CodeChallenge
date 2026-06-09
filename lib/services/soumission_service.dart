import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/soumission.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoumissionService {

  static Future<Map<String, dynamic>> runCode(

    String langage,
    String code,
    int idDefi,

    ) async {

  try {

    final prefs =
        await SharedPreferences.getInstance();

    int? idUser =
        prefs.getInt("id_user");

    final response = await http.post(

      Uri.parse("${ApiConfig.baseUrl}/code/execute"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({

        "langage": langage,

        "code": code,

        "id_defi": idDefi,

        "id_user": idUser
      }),
    );

    

    final data = jsonDecode(response.body);

   return {

  "success": data["success"],

  "resultat": data["resultat"],

  "output": data["output"],

  "error": data["error"],

  "points": data["points"]
};

  } catch (e) {

    return {

      "success": false,

      "output": "Erreur connexion",

      "error": e.toString()
    };
  }
}

  Future<SoumissionResult> soumettre({
    required int idUser,
    required int idDefi,
    required String codeSource,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/soumissions'),
      headers: ApiConfig.headers,
      body: jsonEncode({
        'id_user':    idUser,
        'id_defi':    idDefi,
        'code_source': codeSource,
      }),
    );
    if (res.statusCode == 200) {
      return SoumissionResult.fromJson(jsonDecode(res.body));
    }
    throw Exception('Erreur lors de la soumission');
  }

  Future<List<Soumission>> getHistorique(int idUser) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/soumissions/user/$idUser'),
      headers: ApiConfig.headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((s) => Soumission.fromJson(s)).toList();
    }
    throw Exception('Erreur chargement historique');
  }

  Future<List<Map<String, dynamic>>> getClassement() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/classement'),
      headers: ApiConfig.headers,
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }
    throw Exception('Erreur chargement classement');
  }
}