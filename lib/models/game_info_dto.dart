import 'package:csbingo/models/cell.dart';
import 'package:csbingo/models/player.dart';

class GameInfoDTO {
  final String cardId;
  final List<Cell> cells;
  final List<Player> players;

  int points;

  GameInfoDTO({
    required this.cardId,
    required this.cells,
    required this.players,
    required this.points,
  });

  factory GameInfoDTO.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '-1';
    final playersJson = json['players'] as List<dynamic>? ?? [];
    final template = json['cells'] as List<dynamic>? ?? [];
    final points = (json['points'] as num?)?.toInt() ?? 0;

    final players = playersJson.map((p) {
      final map = p as Map<String, dynamic>;
      return Player(
        name: map['name']?.toString() ?? '',
        nationality: map['nationality']?.toString() ?? '',
        team: map['team']?.toString() ?? '',
        image: map['image']?.toString() ?? '',
      );
    }).toList();

    final cells = template.map((c) {
      final map = c as Map<String, dynamic>;
      return Cell(
        title: map['altName']?.toString() ?? '',
        // image: map['imageUrl']?.toString() ?? 'assets/images/cell_placeholder.png',
        image: 'assets/images/cell_placeholder.png',
        isCompleted: map['isMarked'] as bool,
      );
    }).toList();

    return GameInfoDTO(
        cardId: id, cells: cells, players: players, points: points);
  }
}
