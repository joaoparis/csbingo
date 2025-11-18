import 'package:csbingo/board_gateway.dart';
import 'package:csbingo/game_state.dart';
import 'package:flutter/material.dart';
import 'package:csbingo/players_gateway.dart';

class Game extends ChangeNotifier {
  bool isGameInitialized = false;
  String state = "Idle";
  int skips = 3;
  List<Cell> cells = [];
  int round = 0;

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
        play();
      case GameState.playing:
        playing();
      case GameState.gameOver:
        gameOver();
    }
  }

  void selectCell(int index) {
    if (state != GameState.playing) return;

    final cell = cells[index];
    if (cell.isCompleted) return;

    // if (cell.title == currentPlayer.name) {
    cell.isCompleted = true;
    round++;
    notifyListeners();
    // } else {
    //   cell.triggerWrong = true;
    //   notifyListeners();
    //   resetTriggerWrong(index);
    // }
  }

  void gameOver() {
    skips = 3;
    state = GameState.idle;
    notifyListeners();
  }

  void play() {
    if (!isGameInitialized) {
      round = 0;
      generate();
    }
    state = GameState.loading;
    notifyListeners();
  }

  void start() {
    state = GameState.playing;
    notifyListeners();
  }

  void playing() {
    if (skips > 0) {
      round++;
      skips -= 1;
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
