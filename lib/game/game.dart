import 'dart:async';

import 'package:csbingo/gateways/board_gateway.dart';
import 'package:csbingo/models/cell.dart';
import 'package:csbingo/constants/game_state.dart';
import 'package:csbingo/game/game_timer.dart';
import 'package:csbingo/models/player.dart';
import 'package:flutter/material.dart';

class Game extends ChangeNotifier {
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

    print("GENERATE GAME!");
  }

  Future<void> buttonClicked() async {
    switch (state) {
      case GameState.idle:
        await play();
      case GameState.playing:
        skip();
      case GameState.gameOver:
        gameOver();
    }
  }

  void selectCell(int index) {
    if (state != GameState.playing) return;

    final cell = cells[index];
    if (cell.isCompleted) return;

    currentRound++;

    //TODO: check if response is correct
    cell.isCompleted = true;
    notifyListeners();

    if (_isComplete()) {
      state = GameState.gameOver;
      notifyListeners();
    }

    if (currentRound <= maxRounds) {
      timer.resetTimer();
      timer.startTimer(roundTime);
      notifyListeners();
      return;
    }
    timer.resetTimer();
    state = GameState.gameOver;
    notifyListeners();
  }

  void gameOver() {
    state = GameState.idle;

    timer.timerText.removeListener(_timerListener);
    _timerFinishedSub.cancel();
    notifyListeners();
    reset();
  }

  void reset() {
    print("RESETTING");
    isGameInitialized = false;
    currentRound = 1;
    skips = maxSkips;

    generate();
    notifyListeners();
  }

  Future<void> play() async {
    if (!isGameInitialized) {
      currentRound = 1;
      skips = maxSkips;
    }
    _timerListener = () => notifyListeners();
    timer.timerText.addListener(_timerListener);
    _timerFinishedSub = timer.onTimerFinished.listen((_) {
      _onTimerFinished();
    });
    await _loadGame();
    state = GameState.loading;
    notifyListeners();
  }

  void start() {
    timer.startTimer(roundTime);
    state = GameState.playing;
    notifyListeners();
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
      state = GameState.gameOver;
    }
    notifyListeners();
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
    if (currentRound <= maxRounds || state != GameState.gameOver) {
      timer.resetTimer();
      timer.startTimer(roundTime);
      return;
    }
    timer.resetTimer();
    state = GameState.gameOver;
    notifyListeners();
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

  bool _isComplete() => !cells.any((c) => !c.isCompleted);
}
