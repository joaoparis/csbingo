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
  late final http.Client _httpClient;

  RiveWidgetController? _controller;
  RiveBindings? _bindings;
  bool get isReady => _bindings != null && _controller != null;
  bool hasLoadedMainDisplay = false;
  bool hasLoadedCells = false;

  RiveGameBridge({required this.game}) {
    _gameListener = _onGameChanged;
    _httpClient = http.Client();
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
        _setGhostCellStatus();
        _setIdleText();
        if (hasLoadedMainDisplay) {
          break;
        }
        await _setEmptyImages();
        _setPlayButton();
        _resetSkips();
        _resetRoundText();
        _resetTimerText();
        hasLoadedMainDisplay = true;
        break;
      case GameState.ffaLobby:
        hasLoadedMainDisplay = false;
        _setFFALobbyText();
        _setBackButton();
        break;
      case GameState.loading:
        _bindings!.secondOutputLoadingTrigger.trigger();
        hasLoadedMainDisplay = false;
        _setLoadingText();
        _setMaxRoundText();
        _resetSkips(state: SkipState.available);
        break;
      case GameState.playing:
        _updateTimer();
        _setPlayText();
        _setButtonText();
        _setCellsStatus();
        _setRoundText();
        _setSkips();
        _updateScore();
        _bindings!.secondOutputEmptyTrigger.trigger();
        await _setCellImages();
        await _setCellText();
        break;
      case GameState.gameOver:
        _setResetButton();
        _setGameOverText();
        _resetRoundText();
        await _setCellText();
        hasLoadedCells = false;
        hasLoadedMainDisplay = false;
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

    try {
      _httpClient.close();
    } catch (_) {}
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

  Future<void> _setEmptyImages() async {
    var asset = "assets/images/empty_placeholder.png";
    var bytes = await _getBytesFromLocalAsset(asset);

    for (var i = 0; i < game.cellsLength; i++) {
      _bindings!.cellImages[i].value = await Factory.rive.decodeImage(bytes);
      _bindings!.cellsText[i].value = game.cellTitle(i);
    }
  }

  Future<void> _setCellImages() async {
    if (hasLoadedCells) return;
    hasLoadedCells = true;

    final results = await Future.wait(
      List.generate(game.gridSize, (i) async {
        try {
          return await _getImage(game.cellAt(i));
        } catch (e, st) {
          var asset =
              "assets/images/${game.cellAt(i).criteria}_placeholder.png";
          var bytes = await _getBytesFromLocalAsset(asset);
          return await Factory.rive.decodeImage(bytes);
        }
      }),
    );

    for (var i = 0; i < results.length; i++) {
      _bindings!.cellImages[i].value = results[i];
    }
  }

  Future<void> _setCellText() async {
    for (var i = 0; i < game.cellsLength; i++) {
      _bindings!.cellsAnswers[i].value = game.cellAnswer(i);
      _bindings!.cellsText[i].value = game.cellTitle(i);
    }
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

  void _setGhostCellStatus() {
    for (var i = 0; i < _bindings!.cellStatuses.length; i++) {
      _bindings!.cellStatuses[i].value = "ghost";
      _bindings!.cellsText[i].value = "";
      _bindings!.cellsAnswers[i].value = "";
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
    _bindings!.secondOutputTextTrigger.trigger();
    _bindings!.outputText.value = "";
    _bindings!.outputTextInfo.value = "Select game:\n"
        "(${game.type == GameType.daily ? '*' : ' '}) ${GameType.daily.name}\n"
        "(${game.type == GameType.random ? '*' : ' '}) ${GameType.random.name}\n"
        "(${game.type == GameType.ffa ? '*' : ' '}) ${GameType.ffa.name}\n";
    _bindings!.secondOutputTitleText.value = game.type.fullName;
    _bindings!.secondOutputBodyText.value = game.type.description;
  }

  void _setLoadingText() {
    _bindings!.outputText.value = "";
    _bindings!.outputTextInfo.value = "CS BINGO: ${game.type.name}";
  }

  void _setPlayText() =>
      _bindings!.outputText.value = game.players[game.currentRound].name;

  void _setGameOverText() {
    _bindings!.outputText.value = "";
    _bindings!.outputTextInfo.value = "Game Over\n"
        "(${Game.gameOutput == GameOutput.userAnswers ? '*' : ' '}) Your Answers\n"
        "(${Game.gameOutput == GameOutput.suggestedAnswers ? '*' : ' '}) Suggested Answers";
  }

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
    Uint8List? bytes;
    switch (cell.criteria) {
      case "nationality":
        print("NATIONALITY! ${cell.title} ${cell.image} ");
        bytes = await getImageFromUrl(
            "https://flagsapi.com/${cell.title}/flat/64.png");
        break;
      default:
        if (cell.image.startsWith("http")) {
          bytes = await getImageFromUrl(cell.image);
        } else {
          var asset = "assets/images/${cell.criteria}_placeholder.png";
          bytes = await _getBytesFromLocalAsset(asset);
        }
    }

    return await Factory.rive.decodeImage(bytes!);
  }

  Future<Uint8List> _getBytesFromLocalAsset(String asset) async =>
      (await rootBundle.load(asset)).buffer.asUint8List();

  Future<Uint8List?> getImageFromUrl(url) async {
    Uint8List? bytes;

    try {
      const proxyBase = 'https://vercel-image-proxy-nu.vercel.app/api/proxy';
      final proxiedUrl = '$proxyBase?url=${Uri.encodeComponent(url)}';

      final resp = await _httpClient.get(Uri.parse(proxiedUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Image request timeout for: $url');
        },
      );

      if (resp.statusCode == 200) {
        bytes = resp.bodyBytes;
        print(
            "[CELL_IMAGE] Retrieve image from url: $url (status: ${resp.statusCode})");
      } else {
        print(
            "[CELL_IMAGE] Failed to retrieve image from url: $url (status: ${resp.statusCode})");
      }
    } catch (e) {
      print("[CELL_IMAGE] Error fetching image from url: $url - Error: $e");
    }

    return bytes;
  }
}
