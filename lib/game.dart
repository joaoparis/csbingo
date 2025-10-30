import 'package:csbingo/board_gateway.dart';
import 'package:flutter/material.dart';
import 'package:csbingo/players_gateway.dart';

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
      nextPlayer();
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
    generateGameCells();
    skips = 2;
    nextPlayer();
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
      nextPlayer();
      notifyListeners();
    }
  }

  generateCells() {
    cells = List.generate(
      16,
      (i) => Cell(title: "a", image: "assets/images/C4.png"),
    );
  }

  generateGameCells() {
    try {
      BoardGateway().fetchRandomBoard().then((boardItems) {
        cells = boardItems
            .map((item) => Cell(title: item, image: "assets/images/C4.png"))
            .toList();
        notifyListeners();
      });
    } catch (e) {
      print('generateGameCells error: $e');
      generateCells();
      notifyListeners();
    }
  }

  Future<void> nextPlayer() async {
    try {
      final player = await PlayersGateway().fetchRandomPlayer();
      playerName = player.name;
      playerPhoto = "assets/images/C4.png";
    } catch (e) {
      print('nextPlayer error: $e');
      playerName = 'Unknown';
      playerPhoto = "assets/images/C4.png";
    }

    notifyListeners();
  }
}

class Cell {
  final String image;
  final String title;
  bool isCompleted;

  Cell({required this.title, required this.image, this.isCompleted = false});
}
