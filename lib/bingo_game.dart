import 'package:csbingo/bingo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BingoGame extends StatefulWidget {
  const BingoGame({super.key});

  @override
  State<BingoGame> createState() => _BingoGameState();
}

class _BingoGameState extends State<BingoGame> {
  Game game = Game();

  @override
  Widget build(BuildContext context) {
    return BingoPage(
      game: game,
    );
  }
}

class Game extends ChangeNotifier {
  String state = "Idle";
  int skips = 69;
  String playerName = "";
  String playerPhoto = "";
  List<String> cells = [];

  void skip() {
    print(skips);
    if (skips > 0) {
      skips--;
    }
    notifyListeners();
  }

  String getButtonTitle() {
    return switch (state) {
      "Idle" => "PLAY",
      "Playing" => "SKIP",
      "GameOver" => "PLAY",
      String() => "SKIP",
    };
  }
}
