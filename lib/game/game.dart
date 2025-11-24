import 'dart:async';

import 'package:csbingo/gateways/board_gateway.dart';
import 'package:csbingo/models/cell.dart';
import 'package:csbingo/constants/game_state.dart';
import 'package:csbingo/game/game_timer.dart';
import 'package:csbingo/models/player.dart';
import 'package:flutter/material.dart';

class Game extends ChangeNotifier {
  static bool debug = false;
  int maxRounds = 20;
  int gridSize = 16;
  static int maxSkips = 3;
  bool isGameInitialized = false;
  String state = "Idle";
  int currentRound = 1;
  int skips = maxSkips;
  List<Cell> cells = [];
  List<Player> players = [];
  GameTimer timer = GameTimer();
  late VoidCallback _timerListener;
  late StreamSubscription _timerFinishedSub;
  Duration roundTime = const Duration(seconds: 5);
  BoardGateway gateway = BoardGateway();

  Player currentPlayer = Player(
    name: "",
    nationality: "",
    team: "",
    image: "assets/images/C4.png",
  );

  Game() {
    reset();
  }

  void generate() {
    cells = [];
    cells = List.generate(
      gridSize,
      (i) => Cell(
        title: "[option]",
        image: "assets/images/cell_placeholder.png",
      ),
    );
    players = [];
    players = List.generate(
      maxRounds,
      (i) => Player(
        name: 'PáR1S',
        nationality: 'PT',
        team: 'benfica',
        image: 'noImage',
      ),
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

  void selectCell(int index) {
    if (state != GameState.playing) return;

    final cell = cells[index];
    if (cell.isCompleted) return;

    currentRound++;

    //TODO: check if response is correct
    cell.isCompleted = true;
    _notify("selectCell: cell complete");

    if (_isFullBoardComplete()) {
      currentRound = maxRounds;
      timer.resetTimer();
      state = GameState.gameOver;
      _notify("selectCell: _isFullBoardComplete()=true");
      return;
    }

    if (currentRound <= maxRounds) {
      timer.resetTimer();
      timer.startTimer(roundTime);
      // _notify("selectCell: isComplete()=true");
      return;
    }

    currentRound = maxRounds;
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
    currentRound = 1;
    skips = maxSkips;

    generate();
    _notify("reset(): state=$state");
  }

  Future<void> play() async {
    if (!isGameInitialized) {
      currentRound = 1;
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

  void skip() {
    if (skips <= 0) return;
    currentRound++;
    skips--;
    if (currentRound <= maxRounds) {
      if (skips >= 0) {
        timer.resetTimer();
        timer.startTimer(roundTime);
      }
    } else {
      currentRound = maxRounds;
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
    currentRound++;
    if (currentRound <= maxRounds && state != GameState.gameOver) {
      timer.resetTimer();
      timer.startTimer(roundTime);
      return;
    }
    currentRound = maxRounds;
    timer.resetTimer();
    state = GameState.gameOver;
    _notify("_onTimerFinished(): state=$state");
  }

  Future<void> _loadGame() async {
    final gameInfo = await gateway.fetchGame();

    maxRounds = gameInfo.players.length;
    gridSize = gameInfo.cells.length;

    for (int i = 0; i < gridSize; i++) {
      // cells[i].image = gameInfo.cells[i].image;
      cells[i].title = gameInfo.cells[i].title;
    }

    players = [];
    for (int i = 0; i < maxRounds; i++) {
      players.add(gameInfo.players[i]);
    }
  }

  bool _isFullBoardComplete() => !cells.any((c) => !c.isCompleted);
}
