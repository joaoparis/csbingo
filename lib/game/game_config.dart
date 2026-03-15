import 'package:csbingo/csbingo.dart';

class GameConfig {
  final bool debugMode;
  final int maxSkips;
  final GameOverState initialGameOutput;
  final Duration roundTime;
  final int gridSize;
  final int maxRounds;

  const GameConfig({
    this.debugMode = false,
    this.maxSkips = 3,
    this.initialGameOutput = GameOverState.displayingPlayerAnswers,
    this.roundTime = const Duration(seconds: 120),
    this.gridSize = 16,
    this.maxRounds = 20,
  });
}
