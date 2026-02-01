import 'package:csbingo/models/game_info.dart';

class GameConfig {
  final bool debugMode;
  final int maxSkips;
  final GameOutput initialGameOutput;
  final Duration roundTime;
  final int gridSize;
  final int maxRounds;

  const GameConfig({
    this.debugMode = false,
    this.maxSkips = 3,
    this.initialGameOutput = GameOutput.userAnswers,
    this.roundTime = const Duration(seconds: 60),
    this.gridSize = 16,
    this.maxRounds = 20,
  });
}
