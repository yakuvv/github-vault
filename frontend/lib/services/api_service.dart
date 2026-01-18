import 'dart:convert'; // Fixes "json" error
import 'package:http/http.dart' as http; // Fixes "http" error

class ApiService {
  // 1. These variables MUST be here for the functions below to work
  final String baseUrl = 'http://localhost:3000';
  String? token;

  // 2. Fetch Credentials
  Future<List<dynamic>> fetchCredentials(String type) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/credentials?type=$type'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['credentials'];
    }
    return [];
  }

  // 3. Delete Credential
  Future<bool> deleteCredential(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/credentials/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // 4. Reveal Secret
  Future<String?> revealSecret(String credentialId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/credentials/$credentialId/reveal'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['value'];
      }
      return null;
    } catch (e) {
      print('Reveal error: $e');
      return null;
    }
  }
}