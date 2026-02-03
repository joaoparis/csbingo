import 'dart:async';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';

import 'package:csbingo/csbingo.dart';

class RiveGameBridge {
  final GameManager manager;
  late final VoidCallback _gameListener;
  late final VoidCallback _menuListener;
  late final http.Client _httpClient;

  RiveWidgetController? _controller;
  RiveBindings? _bindings;
  bool get isReady => _bindings != null && _controller != null;
  bool hasLoadedCells = false;

  RiveGameBridge({required this.manager}) {
    _gameListener = _onGameChanged;
    _menuListener = _onMenuChanged;
    _httpClient = http.Client();
  }

  Future<void> init({
    required RiveWidgetController controller,
    required RiveBindings bindings,
  }) async {
    _controller = controller;
    _bindings = bindings;

    controller.stateMachine.addEventListener(_handleRiveEvent);

    manager.addListener(_menuListener);

    _attachGameListener();
    manager.setGameInstanceChangeCallback(_attachGameListener);

    bindings.cursorTrigger.addListener(manager.handleCursorTrigger);
    bindings.cellTaps.asMap().forEach((i, c) => _handleCellTap(i, c));

    _applyMenuStateToRive();
  }

  void _attachGameListener() {
    try {
      print(
          "[RIVE_GAME_BRIDGE] Attaching game listener to game instance: ${manager.game.hashCode}");
      manager.game.addListener(_gameListener);
    } catch (e) {
      print(
          "[RIVE_GAME_BRIDGE] Error attaching game listener: $e. It might be the first time.");
    }
  }

  void _handleRiveEvent(dynamic event) {
    final name = event.name?.toString() ?? '';
    if (name == 'buttonClick') {
      manager.buttonClicked();
      return;
    }

    print("[DEBUG] Unhandled Rive event: $name");
  }

  void _handleCellTap(int cellIndex, ViewModelInstanceTrigger tap) {
    tap.addListener((event) {
      manager.game.selectCell(cellIndex);
    });
  }

  void _onGameChanged() {
    print("[RIVE_GAME_BRIDGE] Game changed: ${manager.game.info.state}");
    if (!isReady) return;
    _applyGameStateToRive();
  }

  void _applyGameStateToRive() async {
    print(
        "[RIVE_GAME_BRIDGE] Applying game state to Rive: ${manager.game.info.state}");
    switch (manager.game.info.state) {
      case GameState.loading:
        _bindings!.secondOutputLoadingTrigger.trigger();
        _setLoadingText();
        _setMaxRoundText();
        _resetSkips(state: SkipState.available);
        break;
      case GameState.playing:
        _bindings!.secondOutputEmptyTrigger.trigger();
        await _setCellImages();
        _updateTimer();
        _setPlayText();
        _setButtonText();
        _setCellsStatus();
        _setRoundText();
        _setSkips();
        _updateScore();
        await _setCellText();
        break;
      case GameState.gameOver:
        _setResetButton();
        _setGameOverText();
        _resetRoundText();
        _resetTimerText();
        await _setCellText();
        hasLoadedCells = false;
        break;
      case GameState.error:
        _setGhostCellStatus();
        _bindings!.outputText.value = "Error loading game.";
        break;
      case GameState.inactive:
        _setGhostCellStatus();
        _bindings!.outputText.value = "";
        break;
    }
  }

  void _onMenuChanged() {
    print("[RIVE_GAME_BRIDGE] Manager changed: ${manager.game.info.state}");
    if (!isReady) return;
    _applyMenuStateToRive();
  }

  void _applyMenuStateToRive() async {
    print(
        "[RIVE_GAME_BRIDGE] Applying manager state to Rive: ${manager.menuState}");
    switch (manager.menuState) {
      case MenuState.dailyGame:
      case MenuState.randomGame:
      case MenuState.ffaGame:
        _setPlayButton();
        _setMenuTextInMainDisplay();
        _bindings!.secondOutputTextTrigger.trigger();
        _setGhostCellStatus();
        _setEmptyImages();
        _bindings!.secondOutputTitleText.value = manager.targetType.fullName;
        _bindings!.secondOutputBodyText.value = manager.targetType.description;
        break;
      case MenuState.inactive:
        break;
    }
  }

  void dispose() {
    try {
      manager.removeListener(_gameListener);
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

    for (var i = 0; i < manager.game.config.gridSize; i++) {
      _bindings!.cellImages[i].value = await Factory.rive.decodeImage(bytes);
      _bindings!.cellsText[i].value = manager.game.cellTitle(i);
    }
  }

  Future<void> _setCellImages() async {
    if (hasLoadedCells) return;
    hasLoadedCells = true;

    final results = await Future.wait(
      List.generate(manager.game.config.gridSize, (i) async {
        try {
          return await _getImage(manager.game.cellAt(i));
        } catch (e) {
          var asset =
              "assets/images/${manager.game.cellAt(i).criteria}_placeholder.png";
          var bytes = await _getBytesFromLocalAsset(asset);
          return await Factory.rive.decodeImage(bytes);
        }
      }),
    );

    for (var i = 0; i < results.length; i++) {
      if (_bindings!.cellsText[i].value.length <= 33) {
        _bindings!.cellImages[i].value = results[i];
      } else {
        var asset = "assets/images/empty_placeholder.png";
        var bytes = await _getBytesFromLocalAsset(asset);
        _bindings!.cellImages[i].value = await Factory.rive.decodeImage(bytes);
      }
    }
  }

  Future<void> _setCellText() async {
    for (var i = 0; i < manager.game.config.gridSize; i++) {
      _bindings!.cellsAnswers[i].value = manager.game.cellAnswer(i);
      _bindings!.cellsText[i].value = _prettyCellTitle(
          manager.game.cellTitle(i), manager.game.cellCriteria(i));
    }
  }

  String _prettyCellTitle(String title, String criteria) {
    var prettyTitle = "";
    switch (criteria) {
      case "teammate":
        prettyTitle = "Played with ";
        break;
      case "trophy":
        prettyTitle = "Winner of ";
        break;
      case "squad":
        prettyTitle = "Played on ";
        break;
      case "nationality":
        prettyTitle = "Is From ";
        break;
      default:
        prettyTitle = "";
        break;
    }

    return prettyTitle + title;
  }

  void _setCellsStatus() {
    for (var i = 0; i < manager.game.config.gridSize; i++) {
      switch (manager.game.cellAt(i)) {
        case var cell when cell.isCompleted:
          _bindings!.cellStatuses[i].value = "correct";
          _bindings!.cellsText[i].value = manager.game.cellTitle(i);
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
      if (i >= manager.game.skips) _bindings!.skips[i].value = "red";
    }
  }

  void _setMenuTextInMainDisplay() {
    _bindings!.outputText.value = "";
    _bindings!.outputTextInfo.value = "Select game:\n"
        "(${manager.targetType == GameType.daily ? '*' : ' '}) ${GameType.daily.name}\n"
        "(${manager.targetType == GameType.random ? '*' : ' '}) ${GameType.random.name}\n"
        "(${manager.targetType == GameType.ffa ? '*' : ' '}) ${GameType.ffa.name}\n";
  }

  void _setLoadingText() {
    _bindings!.outputText.value = "";
    _bindings!.outputTextInfo.value = "CS BINGO: ${manager.game.type.name}";
  }

  void _setPlayText() => _bindings!.outputText.value =
      manager.game.info.players[manager.game.info.currentRound].name;

  void _setGameOverText() {
    _bindings!.outputText.value = "";
    _bindings!.outputTextInfo.value = "Game Over\n"
        "(${manager.game.info.gameOverState == GameOverState.displayingPlayerAnswers ? '*' : ' '}) Your Answers\n"
        "(${manager.game.info.gameOverState == GameOverState.displayingSuggestedAnswers ? '*' : ' '}) Suggested Answers";
  }

  void _resetRoundText() => _bindings!.roundText.value = "--";
  void _resetTimerText() => _bindings!.timerText.value = "--:--";
  void _setRoundText() => _bindings!.roundText.value =
      (manager.game.info.currentRound + 1).toString();
  void _setMaxRoundText() =>
      _bindings!.maxRoundText.value = manager.game.config.maxRounds.toString();

  void _updateTimer() =>
      _bindings!.timerText.value = manager.game.timer.timerText.value;

  void _setButtonText() =>
      manager.game.skips > 0 ? _setOptionButton() : _setGreyButton();

  void _setOptionButton() =>
      manager.game.info.currentRound == manager.game.config.maxRounds - 1
          ? _setForfeitButton()
          : _setSkipButton();

  void _updateScore() {
    _bindings!.scoreText.value = manager.game.info.points.toString();
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
