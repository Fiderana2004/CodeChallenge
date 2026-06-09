import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/defi.dart';

class ApiService {

  static const String baseUrl = "http://192.168.43.103:3000/api";


  static Future<Map<String, dynamic>> runCode(
      String langage,
      String code,
      int idDefi
  ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/soumission"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "langage": langage,
        "code": code,
        "id_defi": idDefi,
        "id_user": 1
      }),
    );

    return jsonDecode(response.body);
  }

  // LISTE DES DEFIS
  static Future<List<Defi>> getDefis() async {

    final response = await http.get(
      Uri.parse("$baseUrl/defis")
    );

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data.map((e) => Defi.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement défis");
    }
  }
}