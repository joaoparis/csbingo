import 'package:csbingo/game/game.dart';
import 'package:csbingo/models/cell.dart';
import 'package:csbingo/models/game_info_dto.dart';
import 'package:csbingo/models/player.dart';

class GameInfo {
  final String cardId;
  final List<Cell> cells;
  final List<Player> players;

  int currentRound;
  int points;
  int skips;
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
    cells[index].title = "${players[currentRound].name}\n${cells[index].title}";
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
          title: "[option]",
          image: "assets/images/cell_placeholder.png",
          criteria: "",
        ),
      ),
      players: List.generate(
        maxRounds,
        (i) => Player(
          name: '',
          nationality: '',
          team: '',
          image: "assets/images/cell_placeholder.png",
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
          title: "loading...",
          image: "assets/images/cell_placeholder.png",
          criteria: "loading",
        ),
      ),
      players: List.generate(
        maxRounds,
        (i) => Player(
          name: 'loading...',
          nationality: '',
          team: '',
          image: "assets/images/cell_placeholder.png",
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
  ffa,
}
