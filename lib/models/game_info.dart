import 'package:csbingo/game/game.dart';
import 'package:csbingo/models/cell.dart';
import 'package:csbingo/models/game_info_dto.dart';
import 'package:csbingo/models/player.dart';

class PlayedCell {
  final int index;
  final bool isCorrect;
  final String answer;

  PlayedCell({
    required this.index,
    required this.isCorrect,
    required this.answer,
  });
}

class GameInfo {
  final String cardId;
  final List<Cell> cells;
  final List<Player> players;

  int currentRound;
  int points;
  int skips;
  Map<int, PlayedCell> userPlays = {};
  GameType gameType;

  GameInfo({
    required this.cardId,
    required this.cells,
    required this.players,
    required this.points,
    this.skips = 0,
    this.currentRound = 0,
    this.gameType = GameType.daily,
  });

  setPoints(int value) => points = value;

  void setCorrectCell(int index, Cell newCell, int currentRound) {
    cells[index] = newCell;
    cells[index].answer = players[currentRound].name;
    userPlays[index] = PlayedCell(
      index: index,
      answer: players[currentRound].name,
      isCorrect: true,
    );
  }

  void setIncorrectCell(int index, Cell newCell) {
    cells[index] = newCell;
    userPlays[index] = PlayedCell(
      index: index,
      answer: players[currentRound].name,
      isCorrect: false,
    );
  }

  void setUserAnswers() {
    for (var i = 0; i < cells.length; i++) {
      if (userPlays.containsKey(i) && userPlays[i]!.isCorrect) {
        cells[i].answer = userPlays[i]!.answer;
      } else {
        cells[i].answer = '';
      }
    }
  }

  void setSuggestedAnswers() {
    for (var i = 0; i < cells.length; i++) {
      cells[i].answer = "????";
    }
  }

  factory GameInfo.fromDTO(
    GameInfoDTO info,
    int skips,
    int currentRound,
    GameType type,
  ) {
    return GameInfo(
      cardId: info.cardId,
      cells: info.cells,
      players: info.players,
      points: info.points,
      skips: skips,
      currentRound: currentRound,
      gameType: type,
    );
  }

  factory GameInfo.forPlaceholders(int gridSize, int maxRounds, int skips) {
    return GameInfo(
      cardId: "",
      cells: List.generate(
        gridSize,
        (i) => Cell(
          title: "",
          image: "assets/images/empty_placeholder.png",
          criteria: "empty",
        ),
      ),
      players: List.generate(
        maxRounds,
        (i) => Player(
          name: '',
          nationality: '',
          team: '',
          image: "assets/images/empty_placeholder.png",
        ),
      ),
      points: 0,
      skips: skips,
      currentRound: 0,
    );
  }

  factory GameInfo.forLoading(
      int gridSize, int maxRounds, int skips, GameType type) {
    return GameInfo(
      cardId: "",
      cells: List.generate(
        gridSize,
        (i) => Cell(
          title: "",
          image: "assets/images/empty_placeholder.png",
          criteria: "empty",
        ),
      ),
      players: List.generate(
        maxRounds,
        (i) => Player(
          name: 'loading...',
          nationality: '',
          team: '',
          image: "assets/images/empty_placeholder.png",
        ),
      ),
      points: 0,
      skips: skips,
      currentRound: 0,
      gameType: type,
    );
  }
}

enum GameType {
  daily,
  random,
  ffa;

  String get fullName => switch (this) {
        GameType.daily => "Daily Challenge",
        GameType.random => "Random Game",
        GameType.ffa => "Free For All",
      };

  String get description => switch (this) {
        GameType.daily =>
          "Recurring daily challenge. Match the cells as quickly as possible to earn points! On each selection the answer is verified and points are awarded.",
        GameType.random =>
          "Play a random Game. No timeout, no pressure. Select the cells you think match the current player. Points are awarded at the end of the game based on your performance.",
        GameType.ffa =>
          "Join a Free For All lobby with other players and compete to get the highest score! Coming soon!",
      };
}

enum GameOutput {
  userAnswers,
  suggestedAnswers;
}
