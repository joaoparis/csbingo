import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class PlayerDTO {
  final String name;
  final String nationality;
  final String team;

  PlayerDTO(
      {required this.name, required this.nationality, required this.team});

  factory PlayerDTO.fromJson(Map<String, dynamic> json) {
    return PlayerDTO(
      name: json['name'] ?? '',
      nationality: json['nationality'] ?? '',
      team: json['team'] ?? '',
    );
  }
}

class PlayersGateway {
  final String baseUrl;

  // PlayersGateway({this.baseUrl = 'http://localhost:8080'});
  PlayersGateway(
      {this.baseUrl =
          'https://backendcsbingo-joaoparis7294-rqyu3jzi.leapcell.dev'});

  Future<PlayerDTO> fetchRandomPlayer() async {
    final uri = Uri.parse('$baseUrl/api/player/random');
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(resp.body);
        return PlayerDTO.fromJson(jsonBody);
      } else {
        throw Exception(
            'Failed to fetch player: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      if (kIsWeb) {
        throw Exception(
            'Network error while fetching player (XMLHttpRequest). If you\'re running on web, this is commonly caused by CORS. Ensure the server at $baseUrl adds the header `Access-Control-Allow-Origin: *` (or the origin of your app). Original error: $e');
      }
      rethrow;
    }
  }
}
