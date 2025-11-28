import 'dart:convert';

import 'package:csbingo/config.dart';
import 'package:csbingo/models/game_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class BoardGateway {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<GameInfo> createCard() async {
    final uri = Uri.parse('$baseUrl/api/cards');

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
      print("[DEBUG] Error fetching card from backend: $e");
      return await _fetchLocalGame();
      // if (kIsWeb) {
      //   throw Exception('Error: $e');
      // }
      // rethrow;
    }
  }

  Future<GameInfo> sendAction(
    String cardId, {
    int cellId = -1,
    bool skip = false,
    bool isLocal = false,
  }) async {
    final uri = Uri.parse('$baseUrl/api/cards/$cardId');

    try {
      if (isLocal) throw Exception("Local game");

      final resp = await http.patch(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(skip ? {"skip": true} : {"index": cellId}),
      );
      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(resp.body);
        return GameInfo.fromJson(jsonBody);
      } else {
        throw Exception(
            'Failed to select cell: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      print("[DEBUG] Error sending action to backend: $e");
      var info = await _fetchLocalGame();
      if (!skip) info.cells[cellId].isCompleted = !skip;
      return info;

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
      var info = GameInfo.fromJson(jsonBody);
      info.setIsLocal(true);
      return info;
    } catch (e) {
      print("[DEBUG] Error fetching from json: $e");
    }
    return GameInfo(cardId: '1', cells: List.empty(), players: List.empty());
  }
}
