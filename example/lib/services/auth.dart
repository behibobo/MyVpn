import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:qrscan_example/models/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

const baseUrl = "https://vpn.coding-lodge.com/api";

class AuthService {
  // Login
  Future<dynamic> login(String token) async {
    var url = baseUrl + "/auth";

    Map<String, String> body = {
      'token': token,
    };

    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      var result = new Data.fromJson(responseJson);
      log(result.customer);
      return result;
    } else {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    // Simulate a future for response after 1 second.
    return await new Future<void>.delayed(new Duration(seconds: 1));
  }

  static storeUserData(String token) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString('token', token);
  }

  static Future<String> getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String token = storage.getString('token');
    return token;
  }
}
