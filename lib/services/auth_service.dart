import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8080";

  Future<Map<String,dynamic>> loginUser({
    required String email,
    required String password,
  })async{

    final url=Uri.parse("$baseUrl/api/auth");

    final loginResponse=await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email":email,
        "password":password,
      })
    );
    return jsonDecode(loginResponse.body);
  }
}