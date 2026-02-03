import 'dart:async';
import 'package:csbingo/csbingo.dart';

class GameManager extends ChangeNotifier {
  IGame game;

  OrchestratorState orchestratorState = OrchestratorState.menu;
  MenuState menuState = MenuState.dailyGame;

  bool isGameInitialized = false;

  GameType targetType = GameType.daily;

  late Function() _onGameInstanceChanged;

  GameManager({
    required this.game,
  }) {
    game.reset();
    _onGameInstanceChanged = () {};
  }

  void setGameInstanceChangeCallback(Function() callback) {
    _onGameInstanceChanged = callback;
  }

  void handleCursorTrigger(bool value) {
    switch (orchestratorState) {
      case OrchestratorState.menu:
        _toogleMainMenuCursor();
        notify("handleCursorTrigger(): cursor toggled");
        return;
      case OrchestratorState.gameOver:
        game.toggleGameOverState();
        notify("handleCursorTrigger(): cursor toggled");
        return;
      case OrchestratorState.loading:
      case OrchestratorState.playing:
        return;
    }
  }

  VoidCallback get _setGameOverOnManager => () async {
        orchestratorState = OrchestratorState.gameOver;
        menuState = MenuState.inactive;
        notify("GameManager: Game over triggered from game instance");
      };

  Future<void> buttonClicked() async {
    switch (orchestratorState) {
      case OrchestratorState.menu:
        game = GameFactory.create(targetType);
        game.setGameOverOnManager = _setGameOverOnManager;
        _onGameInstanceChanged();
        orchestratorState = OrchestratorState.loading;
        menuState = MenuState.inactive;
        notify("buttonClicked(): game initialized");
        await game.initialize();
        orchestratorState = OrchestratorState.playing;
        return;
      case OrchestratorState.loading:
        return;
      case OrchestratorState.playing:
        await game.skip();
        return;
      case OrchestratorState.gameOver:
        await game.gameOver();
        orchestratorState = OrchestratorState.menu;
        menuState = MenuState.dailyGame;
        targetType = GameType.daily;
        notify("buttonClicked(): game reset");
        return;
    }
  }

  notify(String src) {
    print("[GameManager] Notifying - src: $src; state: $orchestratorState");
    notifyListeners();
  }

  void _toogleMainMenuCursor() {
    print("Toggling cursor from $targetType");
    var newIndex = targetType.index + 1;
    if (newIndex == GameType.values.length) {
      targetType = GameType.values[0];
      return;
    }
    targetType = GameType.values[newIndex];
  }
}
