import 'dart:async';

import 'package:csbingo/models/cell.dart';
import 'package:csbingo/constants/game_state.dart';
import 'package:csbingo/game/game_timer.dart';
import 'package:csbingo/models/player.dart';
import 'package:flutter/material.dart';

class Game extends ChangeNotifier {
  static int maxRounds = 10;
  static int maxSkips = 3;
  bool isGameInitialized = false;
  String state = "Idle";
  int currentRound = 1;
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

    currentRound++;
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
    notifyListeners();
  }

  void reset() => isGameInitialized = false;

  void play() {
    if (!isGameInitialized) {
      currentRound = 1;
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
    if (currentRound <= maxRounds) {
      timer.resetTimer();
      timer.startTimer(roundTime);
      return;
    }
    state = GameState.gameOver;
    notifyListeners();
  }
}
