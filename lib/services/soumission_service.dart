import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SoumissionService {
  static Future<Map<String, dynamic>> runCode(
    String langage,
    String code,
    int idDefi,
  ) async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final idUser = prefs.getInt('id_user') ?? 0;

      // Correspondance langage Flutter → langage Paiza
      final langageMap = {
        'python':     'python3',
        'python3':    'python3',
        'javascript': 'javascript',
        'js':         'javascript',
        'java':       'java',
        'c':          'c',
        'cpp':        'cpp',
        'c++':        'cpp',
        'dart':       'python3', // Paiza ne supporte pas Dart
        'sql':        'python3', // fallback
      };

      final langagePaiza = langageMap[langage.toLowerCase()] ?? 'python3';

      print("🚀 Langage envoyé à Paiza : $langagePaiza (original: $langage)");

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/code/execute'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'id_user': idUser,
          'id_defi': idDefi,
          'code':    code,
          'langage': langagePaiza,
        }),
      );

      final data = jsonDecode(res.body);
      print("DEBUG API RESULT: $data");

      return {
        'resultat': data['resultat'] ?? 'wrong',
        'points':   data['points']  ?? 0,
        'output':   data['output']  ?? '',
        'error':    data['error']   ?? '',
      };
    } catch (e) {
      return {
        'resultat': 'wrong',
        'points':   0,
        'output':   '',
        'error':    'Impossible de joindre le serveur : $e',
      };
    }
  }
}