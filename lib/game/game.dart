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

  String state = "Idle";
  bool isGameInitialized = false;
  int defaultMaxRounds = 20;
  int defaultGridSize = 16;
  int currentRound = 0;

  GameTimer timer = GameTimer();
  Duration defaultRoundTime = const Duration(seconds: 10);
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
    print("game type getter: ${gameInfo.hashCode} ${gameInfo.gameType}");
    return gameInfo.gameType;
  }

  String cellImage(index) => gameInfo.cells[index].image;
  String cellTitle(index) => gameInfo.cells[index].title;

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
      case GameState.idle:
        await play();
        return;
      case GameState.ffaLobby:
        ffaLobby();
        return;
      case GameState.playing:
        skip();
        return;
      case GameState.gameOver:
        gameOver();
        return;
    }
  }

  void selectCell(int index) async {
    if (state != GameState.playing) return;

    final cell = gameInfo.cells[index];
    if (cell.isCompleted) return;

    await _evaluateAction(index: index);

    if (_isBoardComplete) {
      _resetCurrentRound;
      timer.resetTimer();
      state = GameState.gameOver;
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
    state = GameState.gameOver;
    _notify("selectCell(): _isBoardComplete=$_isBoardComplete state=$state");
  }

  void ffaLobby() {
    state = GameState.idle;
    _notify("buttonClicked(): returning to idle from ffaLobby");
  }

  void gameOver() {
    state = GameState.idle;
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
      state = GameState.ffaLobby;
      _notify("play(): state=$state");
      return;
    }

    if (!isGameInitialized) {
      currentRound = 0;
      gameInfo.skips = maxSkips;
    }
    _setupTimer();
    await _loadGame();
    start();
  }

  void start() {
    state = GameState.playing;
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
      state = GameState.gameOver;
    }
    _notify("skip(): state=$state");
  }

  bool get _isBoardComplete => !gameInfo.cells.any((c) => !c.isCompleted);
  bool get _isNotLastRound => currentRound < defaultMaxRounds - 1;
  bool get _hasSkips => gameInfo.skips >= 0;
  bool get _isNotGameOver => state != GameState.gameOver;

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
    state = GameState.gameOver;
    _notify("_onTimerFinished(): state=$state");
  }

  Future<void> _loadGame() async {
    state = GameState.loading;
    gameInfo = GameInfo.forLoading(
      defaultGridSize,
      defaultMaxRounds,
      maxSkips,
      type,
    );
    _notify("_loadGame(): start loading game=$state");
    try {
      var info = await gateway.createCard();
      gameInfo = GameInfo.fromDTO(
        info,
        maxSkips,
        0,
        type,
      );
      _notify("_loadGame(): game has loaded state=$state");
    } catch (err) {
      state = GameState.idle;
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
    } else {
      // print(
      //     "[DEBUG] ❌ Wrong answer! ❌ round:$currentRound [cell index: $index] try: ${info.cells[index].title} <> ${gameInfo.players[currentRound].name}");
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
    if (state != GameState.idle) return;
    _toogleCursor();
    _notify("handleCursorTrigger(): cursor toggled");
  }

  void _toogleCursor() => gameInfo.gameType =
      gameInfo.gameType == GameType.daily ? GameType.ffa : GameType.daily;
}
