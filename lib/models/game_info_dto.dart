import 'package:csbingo/models/cell.dart';
import 'package:csbingo/models/player.dart';

class GameAnswerDTO {
  final String answer;

  GameAnswerDTO({
    required this.answer,
  });

  factory GameAnswerDTO.fromJson(Map<String, dynamic> json) {
    final answer = json['answer']?.toString() ?? '';

    return GameAnswerDTO(answer: answer);
  }
}

class GameAnswersDTO {
  final List<GameAnswerDTO> answers;

  GameAnswersDTO({
    required this.answers,
  });

  factory GameAnswersDTO.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List<dynamic>? ?? [];

    final answers = answersJson
        .map((a) => GameAnswerDTO.fromJson(a as Map<String, dynamic>))
        .toList();

    return GameAnswersDTO(answers: answers);
  }
}

class GameInfoDTO {
  final String gameId;
  final String cardId;
  final List<Cell> cells;
  final List<Player> players;

  int points;

  GameInfoDTO({
    required this.gameId,
    required this.cardId,
    required this.cells,
    required this.players,
    required this.points,
  });

  factory GameInfoDTO.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '-1';
    final gameId = json['gameId']?.toString() ?? '-1';
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
      final img = map['imageUrl']?.toString() ?? '';

      return Cell(
        title: map['altName']?.toString() ?? '',
        image: img.isEmpty ? 'assets/images/question_mark.png' : img,
        isCorrect: map['isMarked'] as bool,
        criteria: map['criteria']?.toString() ?? 'idle',
      );
    }).toList();

    return GameInfoDTO(
      gameId: gameId,
      cardId: id,
      cells: cells,
      players: players,
      points: points,
    );
  }
}
