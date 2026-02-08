import 'dart:async';

import 'package:csbingo/csbingo.dart';

export 'game_manager.dart';
export 'game_timer.dart';
export 'daily/daily.dart';
export 'rive_game_bridge.dart';

abstract class IGame extends ChangeNotifier {
  GameConfig get config;
  GameType get type => info.type;
  GameInfo info = GameInfo.forPlaceholders();

  final GameTimer timer = GameTimer();
  final BoardGateway gateway = BoardGateway();

  late VoidCallback setGameOverOnManager;
  late VoidCallback timerListener;
  late StreamSubscription timerFinishedSub;

  bool get isNotLastRound => info.currentRound < config.maxRounds - 1;
  bool get isNotGameOver => info.state != GameState.gameOver;
  bool get isBoardComplete => !info.cells.any((c) => !c.isCompleted);
  bool get hasSkips => info.skips >= 0;

  String cellTitle(int index) => info.cells[index].title;
  String cellAnswer(int index) => info.cells[index].answer;
  String cellCriteria(int index) => info.cells[index].criteria;
  Cell cellAt(int index) => info.cells[index];

  int get skips => info.skips;

  void resetCurrentRound() => info.currentRound = config.maxRounds - 1;

  void reset();
  Future<void> initialize();
  Future<void> skip();
  Future<void> gameOver();
  Future<void> selectCell(int index);
  Future<void> evaluateAction({int index = -1});
  Future<void> toggleGameOverState();
  Future<void> getAnswers();
}

class GameFactory {
  static IGame create(GameType type) {
    switch (type) {
      case GameType.daily:
        return DailyGame();
      case GameType.random:
        return DailyGame();
      case GameType.ffa:
        return DailyGame();
    }
  }
}
