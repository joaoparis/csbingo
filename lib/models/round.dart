import 'package:csbingo/models/cell.dart';
import 'package:csbingo/models/player.dart';
import 'package:csbingo/services/socket_service.dart';

class Round {
  final int number;
  final String prompt;
  final String imageUrl;
  final List<Player> players;
  final List<Cell> cells;

  Round({
    required this.number,
    required this.prompt,
    required this.imageUrl,
    required this.players,
    required this.cells,
  });

  factory Round.fromJson(Map<String, dynamic> json) {
    debugPrint('FromJson: $json');
    return Round(
      number: json['number'] ?? 0,
      prompt: json['prompt'] ?? '',
      imageUrl: json['image_url'] ?? '',
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cells: (json['cells'] as List<dynamic>?)
              ?.map((e) => Cell.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
