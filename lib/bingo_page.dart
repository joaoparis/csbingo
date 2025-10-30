import 'package:csbingo/game.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BingoPage extends StatelessWidget {
  BingoPage({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: game,
      builder: (context, _) {
        return Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              flex: 8,
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                      flex: 2, child: _buildHeader(game.currentPlayer.name)),
                  Expanded(flex: 2, child: _buildGrid(game.cells)),
                  const Expanded(flex: 1, child: SizedBox.shrink()),
                ],
              ),
            ),
            const Expanded(flex: 1, child: const SizedBox.shrink()),
          ],
        );
      },
    );
  }

  Widget _buildHeader(String playerName) {
    if (game.state == "Idle") {
      return _buildStartHeader(playerName);
    } else if (game.state == "Playing") {
      return _buildGameHeader(playerName);
    } else if (game.state == "GameOver") {
      return _buildGameOverHeader(playerName);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildGameOverHeader(String playerName) {
    return Flex(
      direction: Axis.vertical,
      children: [
        const Expanded(flex: 2, child: SizedBox.shrink()),
        const Expanded(
          flex: 2,
          child: Center(
            child: Text(
              "Game Over!\nCongratulations!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
            flex: 6,
            child: Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => game.start(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(153, 37, 37, 1),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text(
                  game.getButtonTitle(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildStartHeader(String playerName) {
    return Flex(
      direction: Axis.vertical,
      children: [
        const Expanded(flex: 2, child: SizedBox.shrink()),
        const Expanded(
          flex: 2,
          child: Center(
            child: Text(
              "Welcome!!!\nDo you know CS lore?!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
            flex: 6,
            child: Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => game.start(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(153, 37, 37, 1),
                    foregroundColor: Colors.black,
                    // padding: const EdgeInsets.symmetric(
                    //     horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text(
                  game.getButtonTitle(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildGameHeader(String playerName) {
    return Flex(
      direction: Axis.vertical,
      children: [
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 164, 123, 62),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 212, 148, 88),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Image.asset("assets/images/C4.png"),
                          ),
                        ),
                      ),
                      Text(playerName, style: const TextStyle(fontSize: 40)),
                    ],
                  ),
                  Expanded(
                    flex: 2,
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${game.skips} skips remaining "),
                        ElevatedButton(
                          onPressed: () => game.skip(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(153, 37, 37, 1),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
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
                ],
              ),
            ),
          ),
        ),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildGrid(List<Cell> cells) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 164, 123, 62),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 16,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                game.cellTapped(index);
                print("Cell $index tapped");
              },
              child: Container(
                decoration: BoxDecoration(
                  color: paintBox(cells, index),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: (game.state == "Playing")
                      ? Text(cells[index].title)
                      : Image.asset(cells[index].image),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color paintBox(List<Cell> cells, int index) {
    if (cells[index].triggerWrong) {
      game.resetTriggerWrong(index);
      return const Color.fromARGB(255, 231, 121, 87);
    } else {
      return (cells[index].isCompleted)
          ? const Color.fromARGB(255, 94, 153, 99)
          : const Color.fromARGB(255, 212, 148, 88);
    }
  }
}
