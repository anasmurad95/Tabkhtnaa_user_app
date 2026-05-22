import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api/v1';

  static Future<List<dynamic>> fetchTranslations(String lang) async {
    final uri = Uri.parse('$_baseUrl/translate?lang=$lang');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load translations: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> fetchCountries() async {
    final uri = Uri.parse('$_baseUrl/countries');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['data'] as List<dynamic>;
  }
}
