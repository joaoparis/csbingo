import 'package:csbingo/board_gateway.dart';
import 'package:flutter/material.dart';
import 'package:csbingo/players_gateway.dart';

class Game extends ChangeNotifier {
  String state = "Idle";
  int skips = 2;
  Player currentPlayer = Player(
    name: "",
    nationality: "",
    team: "",
    image: "assets/images/C4.png",
  );
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
      if (isCorrect(cells[index])) {
        cells[index].isCompleted = true;
        if (cells.every((cell) => cell.isCompleted)) {
          state = "GameOver";
        }
        nextPlayer();
      } else {
        blinkRed(index);
      }
      notifyListeners();
    }
  }

  void blinkRed(int index) {
    cells[index].triggerWrong = true;
    notifyListeners();
    resetTriggerWrong(index);
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
      currentPlayer = Player(
        name: player.name,
        nationality: player.nationality,
        team: player.team,
        image: "assets/images/C4.png",
      );
    } catch (e) {
      print('nextPlayer error: $e');
    }

    notifyListeners();
  }

  bool isCorrect(Cell cell) {
    if (cell.title == currentPlayer.nationality ||
        cell.title == currentPlayer.team) {
      return true;
    }
    return false;
  }

  void resetTriggerWrong(int index) =>
      Future.delayed(const Duration(seconds: 2), () {
        cells[index].triggerWrong = false;
        notifyListeners();
      });
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
