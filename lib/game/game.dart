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
  late GameInfo gameInfo;
  int maxRounds = 20;
  int gridSize = 16;
  static int maxSkips = 3;
  bool isGameInitialized = false;
  String state = "Idle";
  int currentRound = 0;
  int skips = maxSkips;
  GameTimer timer = GameTimer();
  late VoidCallback _timerListener;
  late StreamSubscription _timerFinishedSub;
  Duration roundTime = const Duration(seconds: 10);
  BoardGateway gateway = BoardGateway();

  Player currentPlayer = Player(
    name: "",
    nationality: "",
    team: "",
    image: "assets/images/cell_placeholder.png",
  );

  Game() {
    reset();
  }

  void generate() {
    gameInfo = GameInfo(
      cardId: "",
      cells: List.generate(
        gridSize,
        (i) => Cell(
          title: "[option]",
          image: "assets/images/cell_placeholder.png",
        ),
      ),
      players: List.generate(
        maxRounds,
        (i) => Player(
          name: 'PáR1S',
          nationality: 'PT',
          team: 'benfica',
          image: "assets/images/cell_placeholder.png",
        ),
      ),
      points: 0,
    );

    isGameInitialized = true;
  }

  Future<void> buttonClicked() async {
    switch (state) {
      case GameState.idle:
        await play();
        return;
      case GameState.playing:
        skip();
        return;
      case GameState.gameOver:
        gameOver();
        return;
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

  void selectCell(int index) async {
    if (state != GameState.playing) return;

    final cell = gameInfo.cells[index];
    if (cell.isCompleted) return;

    await _evaluateAction(index: index);
    _notify("selectCell: cell complete");

    if (_isFullBoardComplete()) {
      currentRound = maxRounds - 1;
      timer.resetTimer();
      state = GameState.gameOver;
      _notify("selectCell: _isFullBoardComplete()=true");
      return;
    }

    if (currentRound < maxRounds - 1) {
      currentRound++;
      timer.resetTimer();
      timer.startTimer(roundTime);
      return;
    }

    currentRound = maxRounds - 1;
    timer.resetTimer();
    state = GameState.gameOver;
    _notify("selectCell: isComplete()=true");
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
    skips = maxSkips;

    generate();
    _notify("reset(): state=$state");
  }

  Future<void> play() async {
    if (!isGameInitialized) {
      currentRound = 0;
      skips = maxSkips;
    }
    _timerListener = () => _notify("timerListener");
    timer.timerText.addListener(_timerListener);
    _timerFinishedSub = timer.onTimerFinished.listen((_) {
      _onTimerFinished();
    });
    await _loadGame();
    state = GameState.loading;
    _notify("play(): game has loaded state=$state");
  }

  void start() {
    state = GameState.playing;
    timer.startTimer(roundTime);
    _notify("start(): state=$state");
  }

  Future<void> skip() async {
    if (skips <= 0) return;

    await _evaluateAction();

    if (currentRound < maxRounds - 1) {
      currentRound++;
      skips--;
      if (skips >= 0) {
        timer.resetTimer();
        timer.startTimer(roundTime);
      }
    } else {
      // If we're on the last round, move to gameOver state and ensure
      // currentRound stays within valid bounds.
      currentRound = maxRounds - 1;
      timer.resetTimer();
      state = GameState.gameOver;
    }
    _notify("skip(): state=$state");
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

  void _onTimerFinished() {
    if (currentRound < maxRounds - 1 && state != GameState.gameOver) {
      currentRound++;
      _evaluateAction();
      timer.resetTimer();
      timer.startTimer(roundTime);
      return;
    }
    currentRound = maxRounds - 1;
    timer.resetTimer();
    state = GameState.gameOver;
    _notify("_onTimerFinished(): state=$state");
  }

  Future<void> _loadGame() async {
    gameInfo = await gateway.createCard();

    maxRounds = gameInfo.players.length;
    gridSize = gameInfo.cells.length;

    for (int i = 0; i < gridSize; i++) {
      // cells[i].image = gameInfo.cells[i].image;
      gameInfo.cells[i].title = gameInfo.cells[i].title;
    }

    for (int i = 0; i < maxRounds; i++) {
      gameInfo.players.add(gameInfo.players[i]);
    }
  }

  bool _isFullBoardComplete() => !gameInfo.cells.any((c) => !c.isCompleted);

  Future<void> _evaluateAction({int index = -1}) async {
    var info = await gateway.sendAction(
      gameInfo.cardId,
      cellId: index,
      skip: index == -1 ? true : false,
      isLocal: gameInfo.isLocal,
    );

    if (index == -1) return;
    gameInfo.cells[index].isWrong = false;
    _notify("_evaluateAction: before evaluating answer");

    if (info.cells[index].isCompleted) {
      // print(
      //     "[DEBUG] ✅ Right answer ✅ card:${gameInfo.cardId} round:$currentRound [cell index: $index] match: ${info.cells[index].title} <> ${gameInfo.players[currentRound].name}");

      gameInfo.setCorrectCell(index, info.cells[index], currentRound);
      gameInfo.setPoints(info.points);
    } else {
      gameInfo.cells[index].isWrong = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        gameInfo.cells[index].isWrong = false;
        _notify("_evaluateAction: reset wrong answer visual");
      });
      // print(
      //     "[DEBUG] ❌ Wrong answer! ❌ round:$currentRound [cell index: $index] try: ${info.cells[index].title} <> ${gameInfo.players[currentRound].name}");
    }
  }
}
