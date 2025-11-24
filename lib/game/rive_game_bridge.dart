import 'dart:async';

import 'package:csbingo/constants/skip_state.dart';
import 'package:csbingo/game/game.dart';
import 'package:csbingo/constants/game_state.dart';
import 'package:csbingo/models/rive_bindinds.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveGameBridge {
  final Game game;
  late final VoidCallback _gameListener;

  RiveWidgetController? _controller;
  RiveBindings? _bindings;
  bool get isReady => _bindings != null && _controller != null;

  RiveGameBridge({required this.game}) {
    _gameListener = _onGameChanged;
  }

  Future<void> init({
    required RiveWidgetController controller,
    required RiveBindings bindings,
  }) async {
    _controller = controller;
    _bindings = bindings;

    controller.stateMachine.addEventListener(_handleRiveEvent);
    game.addListener(_gameListener);

    _applyGameStateToRive();
  }

  void _handleRiveEvent(dynamic event) {
    final name = event.name?.toString() ?? '';
    if (name == 'buttonClick') {
      game.buttonClicked();
      return;
    }

    if (name.startsWith('Click ')) {
      final parts = name.split(' ');
      final index = int.tryParse(parts.last);
      if (index != null) {
        game.selectCell(index);
      }
      return;
    }

    // handle other events...
  }

  /// Invoked when the Game notifies listeners. Translate game state -> Rive view model updates.
  void _onGameChanged() {
    if (!isReady) return;
    _applyGameStateToRive();
  }

  void _applyGameStateToRive() async {
    switch (game.state) {
      case GameState.idle:
        await _setCellImages(isEmpty: true);
        _setIdleText();
        _setPlayButton();
        _resetCellStatus();
        _resetSkips();
        _resetRoundText();
        _resetTimerText();
        break;
      case GameState.loading:
        _setLoadingText();
        _setMaxRoundText();
        _resetSkips(state: SkipState.available);
        await _setCellImages();
        game.start();
        break;
      case GameState.playing:
        _updateTimer();
        _setPlayText();
        _setButtonText();
        _setCellsStatus();
        _setRoundText();
        _setSkips();
        break;
      case GameState.gameOver:
        _setResetButton();
        _setGameOverText();
        _resetRoundText();
        break;
    }
  }

  void dispose() {
    try {
      game.removeListener(_gameListener);
    } catch (_) {}

    if (_controller != null) {
      try {
        _controller!.stateMachine.removeEventListener(_handleRiveEvent);
      } catch (_) {}
    }
  }

  void _setResetButton() {
    _bindings!.buttonStatus.value = 'blue';
    _bindings!.buttonText.value = 'RESET';
  }

  void _setSkipButton() {
    _bindings!.buttonStatus.value = 'red';
    _bindings!.buttonText.value = 'SKIP';
  }

  void _setForfeitButton() {
    _bindings!.buttonStatus.value = 'red';
    _bindings!.buttonText.value = 'FORFEIT';
  }

  void _setGreyButton() {
    _bindings!.buttonStatus.value = 'grey';
    _bindings!.buttonText.value = 'SKIP';
  }

  void _setPlayButton() {
    _bindings!.buttonStatus.value = 'green';
    _bindings!.buttonText.value = 'PLAY';
  }

  Future<void> _setCellImages({bool isEmpty = false}) async {
    final futures = <Future<void>>[];

    for (var i = 0; i < game.gridSize; i++) {
      futures.add(
        (() async {
          final bytes = await rootBundle.load(game.cells[i].image);
          final decoded =
              await Factory.rive.decodeImage(bytes.buffer.asUint8List());
          _bindings!.cellImages[i].value = decoded;
          _bindings!.cellsText[i].value = game.cells[i].title;
        })(),
      );
    }

    await Future.wait(futures);
  }

  void _setCellsStatus() {
    for (var i = 0; i < game.cells.length; i++) {
      if (game.cells[i].isCompleted) {
        _bindings!.cellStatuses[i].value = "correct";
      }
    }
  }

  void _resetCellStatus() {
    for (var i = 0; i < _bindings!.cellStatuses.length; i++) {
      _bindings!.cellStatuses[i].value = "idle";
    }
  }

  void _resetSkips({String state = SkipState.idle}) {
    for (var i = 0; i < _bindings!.skips.length; i++) {
      _bindings!.skips[i].value = state;
    }
  }

  void _setSkips() {
    for (var i = 0; i < _bindings!.skips.length; i++) {
      if (i >= game.skips) _bindings!.skips[i].value = "red";
    }
  }

  void _setIdleText() => _bindings!.outputText.value = "gl hf";
  void _setLoadingText() => _bindings!.outputText.value = "loading...";
  void _setPlayText() =>
      _bindings!.outputText.value = game.players[game.currentRound - 1].name;
  void _setGameOverText() => _bindings!.outputText.value = "gg wp";
  void _resetRoundText() => _bindings!.roundText.value = "--";
  void _resetTimerText() => _bindings!.timerText.value = "--:--";
  void _setRoundText() =>
      _bindings!.roundText.value = game.currentRound.toString();
  void _setMaxRoundText() =>
      _bindings!.maxRoundText.value = game.maxRounds.toString();

  void _updateTimer() =>
      _bindings!.timerText.value = game.timer.timerText.value;

  void _setButtonText() =>
      game.skips > 0 ? _setOptionButton() : _setGreyButton();

  void _setOptionButton() => game.currentRound == game.maxRounds
      ? _setForfeitButton()
      : _setSkipButton();
}
