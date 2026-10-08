import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NlpConnectionService {
  static String? baseUrl = 'https://mosabadel.pythonanywhere.com';

  static bool get isConnected => baseUrl != null;
  static String? get currentUrl => baseUrl;

  static bool isValidIpv4(String ip) => true;

  static Future<bool> connect(String ipAddress) async {
    // Hardcoded connection bypass
    baseUrl = 'https://mosabadel.pythonanywhere.com';
    return true;
  }

  static Future<Map<String, dynamic>> analyzeFragrance(String description) async {
    if (baseUrl == null) {
      throw Exception('Server not connected');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'description': description}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error analyzing fragrance: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  static void disconnect() {
    // Do nothing
  }
}
