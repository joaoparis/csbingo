import 'dart:convert';

import 'package:csbingo/config.dart';
import 'package:csbingo/models/game_info_dto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;
import 'package:url_launcher/url_launcher.dart';

class BoardGateway {
  final String baseUrl = AppConfig.apiBaseUrl;
  static bool isLocal = false;

  Future<GameInfoDTO> createCard(String type) async {
    print("[DEBUG] Calling createCard at '$baseUrl/api/cards'");
    final uri = Uri.parse('$baseUrl/api/cards');
    uri.replace(queryParameters: {'type': type});

    try {
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"type": "normal"}),
      );
      if (resp.statusCode == 200) {
        isLocal = false;
        final Map<String, dynamic> jsonBody = json.decode(resp.body);
        return GameInfoDTO.fromJson(jsonBody);
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

  Future<GameInfoDTO> sendAction(
    String cardId, {
    int cellId = -1,
    bool skip = false,
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
        return GameInfoDTO.fromJson(jsonBody);
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

  Future<GameInfoDTO> _fetchLocalGame() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/examples/message.json');
      final Map<String, dynamic> jsonBody = json.decode(jsonStr);
      var info = GameInfoDTO.fromJson(jsonBody);
      isLocal = true;
      return info;
    } catch (e) {
      print("[DEBUG] Error fetching from json: $e");
    }
    return GameInfoDTO(
      cardId: '1',
      cells: List.empty(),
      players: List.empty(),
      points: 0,
    );
  }
}

class SteamGateway {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<void> login({String? redirect}) async {
    var uri = Uri.parse('$baseUrl/api/auth/steam');

    final redirectUrl = (redirect != null && redirect.isNotEmpty)
        ? redirect
        : (AppConfig.frontendCallbackUrl.isNotEmpty
            ? AppConfig.frontendCallbackUrl
            : null);

    if (redirectUrl != null) {
      uri = uri.replace(queryParameters: {'redirect': redirectUrl});
    }

    try {
      if (await canLaunchUrl(uri)) {
        web.window.location.href = uri.toString();
        // await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        print('[DEBUG] Launched auth URL in browser: $uri');
      } else {
        print('[DEBUG] Cannot launch auth URL: $uri');
      }
    } catch (e) {
      print("[DEBUG] Error launching steam login URL: $e");
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final uri = Uri.parse('$baseUrl/api/steam/user');

    final client = BrowserClient()..withCredentials = true;

    final resp = await client.get(uri);

    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to fetch user: ${resp.statusCode}');
  }
}
