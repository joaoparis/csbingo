import 'dart:async';

import 'package:csbingo/game.dart';
import 'package:csbingo/game_state.dart';
import 'package:flutter/foundation.dart' hide Factory;
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';

class ViewModelInstanceBindings {
  final ViewModelInstanceString buttonText;
  final ViewModelInstanceString buttonStatus;
  final ViewModelInstanceTrigger buttonTrigger;
  final ViewModelInstanceString outputText;
  final ViewModelInstanceString timerText;
  final ViewModelInstanceString scoreText;
  final List<ViewModelInstanceAssetImage> cellImages;
  final List<ViewModelInstanceString> cellStatuses;

  ViewModelInstanceBindings({
    required this.buttonText,
    required this.buttonStatus,
    required this.buttonTrigger,
    required this.outputText,
    required this.timerText,
    required this.scoreText,
    required this.cellImages,
    required this.cellStatuses,
  });
}

class RiveGameBridge {
  final Game game;
  late final VoidCallback _gameListener;

  RiveWidgetController? _controller;
  ViewModelInstanceBindings? _bindings;
  bool get isReady => _bindings != null && _controller != null;

  RiveGameBridge({required this.game}) {
    _gameListener = _onGameChanged;
  }

  Future<void> init({
    required RiveWidgetController controller,
    required ViewModelInstanceBindings bindings,
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
        print("[GameState] idle");
        _setIdleText();
        _setPlayButton();
        _resetCellStatus();
        break;
      case GameState.loading:
        print("[GameState] loading");
        _setLoadingText();
        await _setCellImages();
        game.start();
        break;
      case GameState.playing:
        print("[GameState] playing");
        _setPlayText();
        _setSkipButton();
        _setCellsStatus();
        break;
      case GameState.gameOver:
        print("[GameState] gameOver");
        _setResetButton();
        await _setCellImages(isEmpty: true);
        _setGameOverText();
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

  void _setPlayButton() {
    _bindings!.buttonStatus.value = 'green';
    _bindings!.buttonText.value = 'PLAY';
  }

  Future<void> _setCellImages({bool isEmpty = false}) async {
    for (var cell in _bindings!.cellImages) {
      if (isEmpty) {
        cell.value = null;
      } else {
        final response = await http.get(Uri.parse("https://picsum.photos/200"));
        final bytes = response.bodyBytes;
        final renderImage = await Factory.rive.decodeImage(bytes);
        cell.value = renderImage;
      }
    }
  }

  void _setCellsStatus() {
    for (var i = 0; i < game.cells.length; i++) {
      if (game.cells[i].isCompleted) {
        print("Correct $i");
        _bindings!.cellStatuses[i].value = "correct";
      }
    }
  }

  void _resetCellStatus() {
    for (var i = 0; i < _bindings!.cellStatuses.length; i++) {
      print("Reseting $i");
      _bindings!.cellStatuses[i].value = "idle";
    }
  }

  void _setIdleText() => _bindings!.outputText.value = "gl hf";
  void _setLoadingText() => _bindings!.outputText.value = "loading...";
  void _setPlayText() => _bindings!.outputText.value = "PáR1S";
  void _setGameOverText() => _bindings!.outputText.value = "gg wp";
}
