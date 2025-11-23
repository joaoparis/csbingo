import 'dart:convert';

import 'package:csbingo/models/game_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class BoardGateway {
  final String baseUrl;

  // BoardGateway({this.baseUrl = 'http://localhost:8080'});
  BoardGateway(
      {this.baseUrl =
          'https://backendcsbingo-joaoparis7294-rqyu3jzi.leapcell.dev'});

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

  Future<GameInfo> fetchGame() async {
    // TODO: actually call the BE
    try {
      final jsonStr =
          await rootBundle.loadString('assets/examples/message.json');
      final Map<String, dynamic> jsonBody = json.decode(jsonStr);

      return GameInfo.fromJson(jsonBody);
    } catch (e) {
      print("Error fetching from json: $e");
    }
    return GameInfo(cells: List.empty(), players: List.empty());
  }
}
