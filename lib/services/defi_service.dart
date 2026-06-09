import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/defi.dart';

class DefiService {

  static Future<List<Defi>> getDefis() async {

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/defis"),
    );

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data.map((e) => Defi.fromJson(e)).toList();

    } else {
      throw Exception("Erreur chargement défis");
    }
  }
}