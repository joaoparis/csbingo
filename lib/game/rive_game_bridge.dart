import 'dart:async';

import 'package:csbingo/constants/skip_state.dart';
import 'package:csbingo/game/game.dart';
import 'package:csbingo/constants/game_state.dart';
import 'package:csbingo/models/cell.dart';
import 'package:csbingo/models/game_info.dart';
import 'package:csbingo/models/rive_bindinds.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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

    bindings.cursorTrigger.addListener(game.handleCursorTrigger);
    bindings.cellTaps.asMap().forEach((i, c) => _handleCellTap(i, c));

    _applyGameStateToRive();
  }

  void _handleRiveEvent(dynamic event) {
    final name = event.name?.toString() ?? '';
    if (name == 'buttonClick') {
      game.buttonClicked();
      return;
    }

    print("[DEBUG] Unhandled Rive event: $name");
  }

  void _handleCellTap(int cellIndex, ViewModelInstanceTrigger tap) {
    tap.addListener((event) {
      game.selectCell(cellIndex);
    });
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
      case GameState.ffaLobby:
        _setFFALobbyText();
        _setBackButton();
        break;
      case GameState.loading:
        _setLoadingText();
        _setMaxRoundText();
        _resetSkips(state: SkipState.available);
        await _setCellImages();
        break;
      case GameState.playing:
        _updateTimer();
        _setPlayText();
        _setButtonText();
        _setCellsStatus();
        _setRoundText();
        _setSkips();
        _updateScore();
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

  void _setBackButton() {
    _bindings!.buttonStatus.value = 'red';
    _bindings!.buttonText.value = 'BACK';
  }

  Future<void> _setCellImages({bool isEmpty = false}) async {
    final futures = <Future<void>>[];

    for (var i = 0; i < game.gridSize; i++) {
      futures.add(
        (() async {
          _bindings!.cellImages[i].value = await _getImage(game.cellAt(i));
          _bindings!.cellsText[i].value = game.cellTitle(i);
        })(),
      );
    }

    await Future.wait(futures);
  }

  void _setCellsStatus() {
    for (var i = 0; i < game.cellsLength; i++) {
      switch (game.cellAt(i)) {
        case var cell when cell.isCompleted:
          _bindings!.cellStatuses[i].value = "correct";
          _bindings!.cellsText[i].value = game.cellTitle(i);
          break;
        case var cell when cell.isWrong:
          _bindings!.cellStatuses[i].value = "wrong";
          break;
        default:
          _bindings!.cellStatuses[i].value = "idle";
          break;
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

  void _setIdleText() {
    _bindings!.outputText.value = "";
    _bindings!.outputTextInfo.value = "Select game:\n"
        "(${game.type == GameType.daily ? '*' : ' '}) daily\n"
        "(${game.type == GameType.ffa ? '*' : ' '}) ffa\n";
  }

  void _setLoadingText() {
    _bindings!.outputText.value = "loading...";
    _bindings!.outputTextInfo.value =
        "CS BINGO: ${game.type == GameType.daily ? 'daily' : 'ffa'}";
  }

  void _setPlayText() =>
      _bindings!.outputText.value = game.players[game.currentRound].name;
  void _setGameOverText() =>
      _bindings!.outputText.value = "gg wp (${game.points})";
  void _resetRoundText() => _bindings!.roundText.value = "--";
  void _resetTimerText() => _bindings!.timerText.value = "--:--";
  void _setRoundText() =>
      _bindings!.roundText.value = (game.currentRound + 1).toString();
  void _setMaxRoundText() =>
      _bindings!.maxRoundText.value = game.defaultMaxRounds.toString();

  void _updateTimer() =>
      _bindings!.timerText.value = game.timer.timerText.value;

  void _setButtonText() =>
      game.skips > 0 ? _setOptionButton() : _setGreyButton();

  void _setOptionButton() => game.currentRound == game.defaultMaxRounds - 1
      ? _setForfeitButton()
      : _setSkipButton();

  void _updateScore() {
    _bindings!.scoreText.value = game.points.toString();
  }

  void _setFFALobbyText() {
    _bindings!.outputText.value = "";
    _bindings!.outputTextInfo.value = "CS BINGO: ffa\nComming soon!";
  }

  Future<RenderImage?> _getImage(Cell cell) async {
    Uint8List bytes;
    final cellImage = cell.image;
    if (cell.criteria == "nationality") {
      const proxyBase = 'https://vercel-image-proxy-nu.vercel.app/api/proxy';
      final proxiedUrl =
          '$proxyBase?url=${Uri.encodeComponent("https://flagsapi.com/${cell.title}/flat/64.png")}';
      final resp = await http.get(Uri.parse(proxiedUrl));
      if (resp.statusCode == 200) {
        bytes = resp.bodyBytes;
      } else {
        print("[CELL_IMAGE] Failed to retrieve image: $cellImage");
        bytes = (await rootBundle.load('assets/images/question_mark.png'))
            .buffer
            .asUint8List();
      }
    } else if (cellImage.startsWith("http")) {
      const proxyBase = 'https://vercel-image-proxy-nu.vercel.app/api/proxy';
      final proxiedUrl = '$proxyBase?url=${Uri.encodeComponent(cellImage)}';
      final resp = await http.get(Uri.parse(proxiedUrl));
      if (resp.statusCode == 200) {
        bytes = resp.bodyBytes;
      } else {
        print("[CELL_IMAGE] Failed to retrieve image: $cellImage");
        bytes = (await rootBundle.load('assets/images/question_mark.png'))
            .buffer
            .asUint8List();
      }
    } else {
      var asset = "assets/images/question_mark.png";
      switch (cell.criteria) {
        case "squad":
          asset = "assets/images/squad_placeholder.png";
        case "teammate":
          asset = "assets/images/teammate_placeholder.png";
        case "trophy":
          asset = "assets/images/trophy_placeholder.png";
      }
      bytes = (await rootBundle.load(asset)).buffer.asUint8List();
    }

    return await Factory.rive.decodeImage(bytes);
  }
}
