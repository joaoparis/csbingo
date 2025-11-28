import 'dart:convert';

import 'package:csbingo/config.dart';
import 'package:csbingo/models/game_info.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class BoardGateway {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<GameInfo> fetchGame() async {
    final uri = Uri.parse('$baseUrl/api/game/');

    try {
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"type": "normal"}),
      );
      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(resp.body);
        return GameInfo.fromJson(jsonBody);
      } else {
        throw Exception(
            'Failed to fetch board: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      print("[DEBUG] Error fetching from backend: $e");
      return _fetchLocalGame();

      // if (kIsWeb) {
      //   throw Exception('Error: $e');
      // }
      // rethrow;
    }
  }

  Future<GameInfo> _fetchLocalGame() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/examples/message.json');
      final Map<String, dynamic> jsonBody = json.decode(jsonStr);

      return GameInfo.fromJson(jsonBody);
    } catch (e) {
      print("[DEBUG] Error fetching from json: $e");
    }
    return GameInfo(cells: List.empty(), players: List.empty());
  }
}
