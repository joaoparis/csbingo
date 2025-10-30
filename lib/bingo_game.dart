import 'package:csbingo/bingo_page.dart';
import 'package:csbingo/game.dart';
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
