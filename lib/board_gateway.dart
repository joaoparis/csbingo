import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class BoardGateway {
  final String baseUrl;

  BoardGateway({this.baseUrl = 'http://localhost:8080'});

  /// Fetches a random board from `/api/board/random`.
  /// Response shape expected:
  /// {"board": ["Astralis","NAVI", ... ]}
  ///
  /// Returns the list of team/cell strings on success.
  Future<List<String>> fetchRandomBoard() async {
    final uri = Uri.parse('$baseUrl/api/board/random');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(resp.body);
        final dynamic boardRaw = jsonBody['board'];
        if (boardRaw is List) {
          return boardRaw.map((e) => e.toString()).toList();
        } else {
          throw Exception(
              'Invalid board format: expected "board" to be a list');
        }
      } else {
        throw Exception(
            'Failed to fetch board: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      if (kIsWeb) {
        throw Exception(
            'Network error while fetching board (XMLHttpRequest). If you\'re running on web, this is commonly caused by CORS. Ensure the server at $baseUrl adds the header `Access-Control-Allow-Origin: *` (or the origin of your app). Original error: $e');
      }
      rethrow;
    }
  }
}
