import 'dart:async';

import 'package:csbingo/constants/skip_state.dart';
import 'package:csbingo/game/game.dart';
import 'package:csbingo/constants/game_state.dart';
import 'package:csbingo/models/rive_bindinds.dart';
import 'package:flutter/foundation.dart' hide Factory;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';

class RiveGameBridge {
  final Game game;
  late final VoidCallback _gameListener;

  RiveWidgetController? _controller;
  RiveBindings? _bindings;
  bool _isLoadingImages = false;
  final Set<int> _loadedImageIndices = {};
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
      print("button clicked");
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
        print("[GameState] idle");
        _setCellImages(isEmpty: true);
        _setIdleText();
        _setPlayButton();
        _resetCellStatus();
        _resetSkips();
        _resetRoundText();
        break;
      case GameState.loading:
        print("[GameState] loading");
        _setLoadingText();
        _setMaxRoundText();
        _resetSkips(state: SkipState.available);
        await _setCellImages();
        game.start();
        break;
      case GameState.playing:
        print("[GameState] playing");
        _setPlayText();
        _setButtonText();
        _setCellsStatus();
        _setRoundText();
        _setSkips();
        _updateTimer();
        break;
      case GameState.gameOver:
        print("[GameState] gameOver");
        _setResetButton();
        _setGameOverText();
        _resetRoundText();
        break;
    }
  }

  // void _exampleSetCellImage() async {
  //   for (var cell in _cells) {
  //     final response = await http.get(Uri.parse("https://picsum.photos/200"));
  //     final bytes = response.bodyBytes;
  //     final renderImage = await Factory.rive.decodeImage(bytes);
  //     if (renderImage != null) {
  //       cell.imageViewModel.value = renderImage;
  //       print("Successfully set image for cell");
  //     } else {
  //       print("Failed to decode image for cell");
  //     }
  //   }
  // }

  /// Manual helper to set a cell image (async).
  // Future<void> setCellImage(int index, RiveImage? image) async {
  //   if (!isReady) return;
  //   final images = _bindings!.cellImages;
  //   if (index < 0 || index >= images.length) return;
  //   images[index].value = image;
  // }

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
    if (_isLoadingImages) return;
    _isLoadingImages = true;
    try {
      for (var i = 0; i < _bindings!.cellImages.length; i++) {
        _bindings!.cellsText[i].value = "option $i";
        final cell = _bindings!.cellImages[i];
        if (isEmpty) {
          final bytes =
              await rootBundle.load("assets/images/cell_placeholder.png");
          cell.value =
              await Factory.rive.decodeImage(bytes.buffer.asUint8List());
          _loadedImageIndices.remove(i);
          continue;
        }

        if (_loadedImageIndices.contains(i)) continue;

        final response = await http.get(Uri.parse("https://picsum.photos/200"));
        final bytes = response.bodyBytes;
        final renderImage = await Factory.rive.decodeImage(bytes);
        cell.value = renderImage;
        _loadedImageIndices.add(i);
      }
    } finally {
      _isLoadingImages = false;
    }
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
      _bindings!.cellsText[i].value = "option...";
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
  void _setPlayText() => _bindings!.outputText.value = "PáR1S";
  void _setGameOverText() => _bindings!.outputText.value = "gg wp";
  void _resetRoundText() => _bindings!.roundText.value = "--";
  void _setRoundText() =>
      _bindings!.roundText.value = game.currentRound.toString();
  void _setMaxRoundText() =>
      _bindings!.maxRoundText.value = Game.maxRounds.toString();

  void _updateTimer() =>
      _bindings!.timerText.value = game.timer.timerText.value;

  void _setButtonText() =>
      game.skips > 0 ? _setOptionButton() : _setGreyButton();

  void _setOptionButton() => game.currentRound == Game.maxRounds
      ? _setForfeitButton()
      : _setSkipButton();
}
