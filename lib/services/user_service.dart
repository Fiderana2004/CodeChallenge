import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class UserService {

  static Future<bool> uploadPhoto(

    int idUser,
    File image,

  ) async {

    var request =
      http.MultipartRequest(

      "POST",

      Uri.parse(
        "${ApiConfig.baseUrl}/api/user/upload/$idUser",
      ),
    );

    request.files.add(

      await http.MultipartFile.fromPath(
        "photo",
        image.path,
      ),
    );

    var response = await request.send();

    return response.statusCode == 200;
  }
}