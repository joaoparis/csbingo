import 'dart:async';

import 'package:csbingo/gateways/board_gateway.dart';
import 'package:csbingo/models/cell.dart';
import 'package:csbingo/constants/game_state.dart';
import 'package:csbingo/game/game_timer.dart';
import 'package:csbingo/models/game_info.dart';
import 'package:csbingo/models/player.dart';
import 'package:flutter/material.dart';

class Game extends ChangeNotifier {
  static bool debug = false;
  static int maxSkips = 3;
  static GameOutput gameOutput = GameOutput.userAnswers;

  GameState state = GameState.Idle;
  bool isGameInitialized = false;
  int defaultMaxRounds = 20;
  int defaultGridSize = 16;
  int currentRound = 0;

  GameTimer timer = GameTimer();
  Duration defaultRoundTime = const Duration(seconds: 60);
  Player currentPlayer = Player.emptyPlayer();
  BoardGateway gateway = BoardGateway(); //TODO: Inject this dependency

  late GameInfo gameInfo;
  late VoidCallback _timerListener;
  late StreamSubscription _timerFinishedSub;

  int get gridSize => gameInfo.cells.length;
  int get cellsLength => gameInfo.cells.length;
  int get skips => gameInfo.skips;
  int get points => gameInfo.points;

  List<Player> get players => gameInfo.players;
  Cell cellAt(index) => gameInfo.cells[index];
  GameType get type {
    // print("game type getter: ${gameInfo.hashCode} ${gameInfo.gameType}");
    return gameInfo.gameType;
  }

  String cellImage(index) => gameInfo.cells[index].image;
  String cellTitle(index) => gameInfo.cells[index].title;
  String cellAnswer(index) => gameInfo.cells[index].answer;
  String cellCriteria(index) => gameInfo.cells[index].criteria;

  Game() {
    reset();
  }

  @override
  void dispose() {
    try {
      timer.timerText.removeListener(_timerListener);
    } catch (_) {}
    _timerFinishedSub.cancel();
    timer.dispose();
    super.dispose();
  }

  Future<void> buttonClicked() async {
    switch (state) {
      case GameState.Idle:
        await play();
        return;
      case GameState.FFALobby:
        ffaLobby();
        return;
      case GameState.Playing:
        skip();
        return;
      case GameState.GameOver:
        gameOver();
        return;
      case GameState.Loading:
        return;
    }
  }

  void selectCell(int index) async {
    if (state != GameState.Playing) return;

    final cell = gameInfo.cells[index];
    if (cell.isCompleted) return;

    await _evaluateAction(index: index);

    if (_isBoardComplete) {
      _resetCurrentRound;
      timer.resetTimer();
      state = GameState.GameOver;
      _notify("selectCell(): _isBoardComplete=$_isBoardComplete state=$state");
      return;
    }

    if (_isNotLastRound) {
      currentRound++;
      timer.resetTimer();
      timer.startTimer(defaultRoundTime);
      return;
    }

    _resetCurrentRound;
    timer.resetTimer();
    state = GameState.GameOver;
    _notify("selectCell(): _isBoardComplete=$_isBoardComplete state=$state");
  }

  void ffaLobby() {
    state = GameState.Idle;
    _notify("buttonClicked(): returning to idle from ffaLobby");
  }

  void gameOver() {
    state = GameState.Idle;
    timer.timerText.removeListener(_timerListener);
    _timerFinishedSub.cancel();
    _notify("gameOver(): state=$state");
    reset();
  }

  void reset() {
    isGameInitialized = false;
    currentRound = 0;

    gameInfo = GameInfo.forPlaceholders(
      defaultGridSize,
      defaultMaxRounds,
      maxSkips,
    );

    isGameInitialized = true;
    _notify("reset(): state=$state");
  }

  Future<void> play() async {
    if (gameInfo.gameType == GameType.ffa) {
      state = GameState.FFALobby;
      _notify("play(): state=$state");
      return;
    }

    if (!isGameInitialized) {
      currentRound = 0;
      gameInfo.skips = maxSkips;
      gameOutput = GameOutput.userAnswers;
    }
    _setupTimer();
    await _loadGame();
    start();
  }

  void start() {
    state = GameState.Playing;
    timer.startTimer(defaultRoundTime);
    _notify("start(): state=$state");
  }

  Future<void> skip() async {
    if (gameInfo.skips <= 0) return;

    await _evaluateAction();

    if (_isNotLastRound) {
      currentRound++;
      gameInfo.skips--;
      if (_hasSkips) {
        timer.resetTimer();
        timer.startTimer(defaultRoundTime);
      }
    } else {
      _resetCurrentRound;
      timer.resetTimer();
      state = GameState.GameOver;
    }
    _notify("skip(): state=$state");
  }

  bool get _isBoardComplete => !gameInfo.cells.any((c) => !c.isCompleted);
  bool get _isNotLastRound => currentRound < defaultMaxRounds - 1;
  bool get _hasSkips => gameInfo.skips >= 0;
  bool get _isNotGameOver => state != GameState.GameOver;

  void _resetCurrentRound() => currentRound = defaultMaxRounds - 1;

  void _setupTimer() {
    _timerListener = () => _notify("timer");
    timer.timerText.addListener(_timerListener);
    _timerFinishedSub = timer.onTimerFinished.listen((_) {
      _onTimerFinished();
    });
  }

  void _onTimerFinished() {
    if (_isNotLastRound && _isNotGameOver) {
      currentRound++;
      _evaluateAction();
      timer.resetTimer();
      timer.startTimer(defaultRoundTime);
      return;
    }
    _resetCurrentRound;
    timer.resetTimer();
    state = GameState.GameOver;
    _notify("_onTimerFinished(): state=$state");
  }

  Future<void> _loadGame() async {
    state = GameState.Loading;
    gameInfo = GameInfo.forLoading(
      defaultGridSize,
      defaultMaxRounds,
      maxSkips,
      type,
    );
    _notify("_loadGame(): start loading game=$state");
    try {
      var info = await gateway.createCard(type.name);
      gameInfo = GameInfo.fromDTO(
        info,
        maxSkips,
        0,
        type,
      );
      // _notify("_loadGame(): game has loaded state=$state");
    } catch (err) {
      state = GameState.Idle;
      _notify("_loadGame(): failed to load game, reverting to state=$state");
      rethrow;
    }
  }

  Future<void> _evaluateAction({int index = -1}) async {
    var info = await gateway.sendAction(
      gameInfo.cardId,
      cellId: index,
      skip: index == -1 ? true : false,
    );

    if (index == -1) return;

    gameInfo.cells[index].isWrong = false;
    _notify("_evaluateAction(): before evaluating answer");

    if (info.cells[index].isCompleted) {
      // print(
      //     "[DEBUG] ✅ Right answer ✅ card:${gameInfo.cardId} round:$currentRound [cell index: $index] match: ${info.cells[index].title} <> ${gameInfo.players[currentRound].name}");
      gameInfo.setCorrectCell(index, info.cells[index], currentRound);
      gameInfo.setPoints(info.points);
      _notify("_evaluateAction(): reset wrong answer visual");
    } else {
      // print(
      //     "[DEBUG] ❌ Wrong answer! ❌ round:$currentRound [cell index: $index] try: ${info.cells[index].title} <> ${gameInfo.players[currentRound].name}");
      gameInfo.setIncorrectCell(index, info.cells[index]);
      gameInfo.cells[index].isWrong = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        gameInfo.cells[index].isWrong = false;
        _notify("_evaluateAction(): reset wrong answer visual");
      });
    }
  }

  _notify(String src) {
    if (debug) {
      print("[DEBUG] Notifying...");
      print("[DEBUG] Source: $src");
      print("[DEBUG] State: $state");
    }
    notifyListeners();
  }

  void handleCursorTrigger(bool value) {
    switch (state) {
      case GameState.Idle:
        _toogleMainMenuCursor();
        _notify("handleCursorTrigger(): cursor toggled");
        return;
      case GameState.GameOver:
        _toggleGameOverCursor();
        _updateCellsText();
        _notify("handleCursorTrigger(): cursor toggled");
        return;
      case GameState.Loading:
      case GameState.FFALobby:
      case GameState.Playing:
        return;
    }
  }

  void _toogleMainMenuCursor() {
    var newIndex = gameInfo.gameType.index + 1;

    if (newIndex == GameType.values.length) {
      gameInfo.gameType = GameType.values[0];
      return;
    }

    gameInfo.gameType = GameType.values[newIndex];
  }

  void _toggleGameOverCursor() {
    var newIndex = Game.gameOutput.index + 1;

    if (newIndex == GameOutput.values.length) {
      Game.gameOutput = GameOutput.values[0];
      return;
    }

    Game.gameOutput = GameOutput.values[newIndex];
  }

  void _updateCellsText() {
    for (var i = 0; i < gameInfo.cells.length; i++) {
      if (Game.gameOutput == GameOutput.userAnswers) {
        gameInfo.setUserAnswers();
      } else {
        gameInfo.setSuggestedAnswers();
      }
    }
  }
}
