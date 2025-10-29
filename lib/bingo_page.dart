import 'package:csbingo/bingo_game.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BingoPage extends StatelessWidget {
  BingoPage({
    super.key,
    required this.game,
  })  : playerName = game.playerName,
        playerPhoto = game.playerPhoto,
        cells = game.cells,
        skips = game.skips;

  final Game game;

  String playerName;
  String playerPhoto;
  List<String> cells;
  int skips;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: game,
      builder: (context, _) {
        return Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(flex: 2, child: _buildHeader(playerName)),
            Expanded(flex: 2, child: _buildGrid(cells)),
            const Expanded(flex: 1, child: SizedBox.shrink())
            // GameFooter(),
          ],
        );
      },
    );
  }

  Widget _buildHeader(String playerName) {
    return Flex(
      direction: Axis.vertical,
      children: [
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 2,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 212, 148, 88),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Image.asset(playerPhoto),
                ),
              ),
              Text(
                playerName,
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 2,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${game.skips} skips remaining "),
              ElevatedButton(
                onPressed: () {
                  if (game.state == "Idle") {
                    print("PLAY");
                    game.state = "Playing";
                  } else {
                    print("SKIP");
                    game.skip();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(153, 37, 37, 1),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  game.getButtonTitle(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildGrid(List<String> cells) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 164, 123, 62),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: 16,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 212, 148, 88),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset((cells.length > index) ? cells[index] : "A"),
              ),
            );
          },
        ),
      ),
    );
  }
}
