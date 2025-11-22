import 'dart:async';

import 'package:csbingo/board_gateway.dart';
import 'package:csbingo/game_state.dart';
import 'package:csbingo/game_timer.dart';
import 'package:flutter/material.dart';
import 'package:csbingo/players_gateway.dart';

class Game extends ChangeNotifier {
  static int maxRounds = 10;
  static int maxSkips = 3;
  bool isGameInitialized = false;
  String state = "Idle";
  int rounds = maxRounds;
  int skips = maxSkips;
  List<Cell> cells = [];
  GameTimer timer = GameTimer();
  late final VoidCallback _timerListener;
  late final StreamSubscription _timerFinishedSub;
  Duration roundTime = const Duration(seconds: 5);

  Game() {
    _timerListener = () => notifyListeners();
    timer.timerText.addListener(_timerListener);
    _timerFinishedSub = timer.onTimerFinished.listen((_) {
      _onTimerFinished();
    });
  }

  Player currentPlayer = Player(
    name: "",
    nationality: "",
    team: "",
    image: "assets/images/C4.png",
  );

  void generate() {
    cells = List.generate(
      16,
      (i) => Cell(title: "a", image: "assets/images/C4.png"),
    );
    isGameInitialized = true;
  }

  void resetTriggerWrong(int index) =>
      Future.delayed(const Duration(seconds: 2), () {
        cells[index].triggerWrong = false;
        notifyListeners();
      });

  void buttonClicked() {
    switch (state) {
      case GameState.idle:
        reset();
        play();
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

    //TODO: check if response is correct
    cell.isCompleted = true;

    rounds--;
    if (rounds >= 0) {
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
    notifyListeners();
  }

  void reset() => isGameInitialized = false;

  void play() {
    if (!isGameInitialized) {
      rounds = maxRounds;
      skips = maxSkips;
      generate();
    }
    state = GameState.loading;
    notifyListeners();
  }

  void start() {
    timer.startTimer(roundTime);
    state = GameState.playing;
    notifyListeners();
  }

  void skip() {
    if (skips < 0 && rounds >= 0) return;
    rounds--;
    skips--;
    if (skips >= 0 || rounds >= 0) {
      timer.resetTimer();
      timer.startTimer(roundTime);
      notifyListeners();
      return;
    }
    state = GameState.gameOver;
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
    rounds--;
    if (rounds >= 0) {
      timer.resetTimer();
      timer.startTimer(roundTime);
      return;
    }
    state = GameState.gameOver;
    notifyListeners();
  }
}

class Cell {
  final String image;
  final String title;
  bool isCompleted;
  bool triggerWrong = false;

  Cell({required this.title, required this.image, this.isCompleted = false});
}

class Player {
  final String name;
  final String nationality;
  final String team;
  final String image;

  Player({
    required this.name,
    required this.nationality,
    required this.team,
    required this.image,
  });
}
