import 'package:flutter/material.dart';

class Game extends ChangeNotifier {
  String state = "Idle";
  int skips = 2;
  String playerName = "";
  String playerPhoto = "";
  List<Cell> cells = [];

  Game() {
    generateCells();
  }

  void skip() {
    print(skips);
    if (skips > 0) {
      skips--;
    } else {
      state = "GameOver";
    }
    notifyListeners();
  }

  String getButtonTitle() {
    return switch (state) {
      "Idle" => "PLAY",
      "Playing" => "SKIP",
      "GameOver" => "PLAY AGAIN",
      String() => "SKIP",
    };
  }

  void start() {
    state = "Playing";
    generateCells();
    skips = 2;
    notifyListeners();
  }

  void cellTapped(int index) {
    if (cells[index].isCompleted || state != "Playing") {
      return;
    } else {
      print("Completing cell $index");
      cells[index].isCompleted = true;
      if (cells.every((cell) => cell.isCompleted)) {
        state = "GameOver";
      }
      notifyListeners();
    }
  }

  generateCells() {
    cells = List.generate(
      16,
      (i) => Cell(title: "a", image: "assets/images/C4.png"),
    );
  }
}

class Cell {
  final String image;
  final String title;
  bool isCompleted;

  Cell({required this.title, required this.image, this.isCompleted = false});
}
