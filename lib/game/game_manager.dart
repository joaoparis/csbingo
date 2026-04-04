import 'dart:async';
import 'package:csbingo/csbingo.dart';

class GameManager extends ChangeNotifier {
  IGame game;

  OrchestratorState orchestratorState;

  GameType targetType = GameType.daily;

  late Function() _onGameInstanceChanged;

  GameManager({
    required this.game,
    required this.orchestratorState,
  }) {
    game.reset();
    _onGameInstanceChanged = () {};
  }

  void setGameInstanceChangeCallback(Function() callback) {
    _onGameInstanceChanged = callback;
  }

  Future<void> buttonClicked() async {
    switch (orchestratorState) {
      case OrchestratorState.loading:
        return;
      case OrchestratorState.playing:
        await game.skip();
        return;
      case OrchestratorState.gameOver:
        await game.gameOver();
        targetType = GameType.daily;
        notify("buttonClicked(): game reset");
        return;
    }
  }

  notify(String src) {
    notifyListeners();
  }
}
