import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _httpClient;
  final Duration timeout;

  ApiClient({
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 10),
  }) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, dynamic>> getJson(String url) async {
    final Uri uri = Uri.parse(url);
    final response = await _httpClient.get(uri).timeout(timeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const FormatException('Expected a JSON object root');
    } else {
      throw Exception('Server returned HTTP ${response.statusCode} for $url');
    }
  }

  void close() => _httpClient.close();
}