import 'dart:async';
import 'dart:math' as math;

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

  final Map<int, Timer?> _loadingTimers = {};
  int? _currentlyLoadingCellIndex;

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
  }

  void _handleCellTap(int cellIndex, ViewModelInstanceTrigger tap) {
    tap.addListener((event) {
      // Prevent tapping other cells while one is loading
      if (_currentlyLoadingCellIndex != null &&
          _currentlyLoadingCellIndex != cellIndex) {
        return;
      }
      manager.game.selectCell(cellIndex);
    });
  }

  void _onGameChanged() {
    if (!isReady) return;
    // print("_currentlyLoadingCellIndex? $_currentlyLoadingCellIndex");
    _applyGameStateToRive();
  }

  void _applyGameStateToRive() async {
    switch (manager.game.info.state) {
      case GameState.loading:
        _bindings!.secondOutputTitleText.value =
            "Loading ${manager.targetType.fullName}";
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
        await _setCellsStatus();
        _setRoundText();
        _setSkips();
        if (manager.game.type == GameType.daily) _updateScore();
        await _setCellText();
        break;
      case GameState.verifyingAnswer:
        for (var i = 0; i < manager.game.config.gridSize; i++) {
          if (manager.game.cellAt(i).isLoadingAnswer) {
            _bindings!.cellIsLoading[i].value = true;
            _startLoadingAnimation(i);
          }
        }
        break;
      case GameState.finishingVerification:
        for (var i = 0; i < manager.game.config.gridSize; i++) {
          if (manager.game.cellAt(i).isLoadingAnswer) {
            await _stopLoadingAnimation(i);
            _bindings!.cellIsLoading[i].value = false;
          }
        }
        manager.game.setPlayingState();
        break;
      case GameState.gameOver:
        _setResetButton();
        _setGameOverText();
        _resetRoundText();
        _resetTimerText();
        await _setCellsStatus();
        _updateScore();
        await _setCellText();
        hasLoadedCells = false;
        break;
      case GameState.error:
        _setGhostCellStatus();
        _bindings!.outputText.value = "Error loading game.";
        break;
      case GameState.inactive:
        hasLoadedCells = false;
        _updateScore(value: "0");
        _setGhostCellStatus();
        _bindings!.outputText.value = "";
        break;
    }
  }

  void _onMenuChanged() {
    if (!isReady) return;
    _applyMenuStateToRive();
  }

  void _applyMenuStateToRive() async {
    switch (manager.menuState) {
      case MenuState.dailyGame:
      case MenuState.randomGame:
        _setPlayButton();
        _setMenuTextInMainDisplay();
        _setGhostCellStatus();
        _setEmptyImages();
        _bindings!.secondOutputTitleText.value = manager.targetType.fullName;
        _bindings!.secondOutputBodyText.value = manager.targetType.description;
        _bindings!.secondOutputTextTrigger.trigger();
        break;
      case MenuState.ffaGame:
        _setInactiveButton();
        _setMenuTextInMainDisplay();
        _setGhostCellStatus();
        _setEmptyImages();
        _bindings!.secondOutputTitleText.value = manager.targetType.fullName;
        _bindings!.secondOutputBodyText.value = manager.targetType.description;
        _bindings!.secondOutputTextTrigger.trigger();
        break;
      case MenuState.inactive:
        break;
    }
  }

  void dispose() {
    for (var timer in _loadingTimers.values) {
      timer?.cancel();
    }
    _loadingTimers.clear();

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

  Future<void> _stopLoadingAnimation(int cellIndex) async {
    // print("loading start: ${_bindings!.cellLoad[cellIndex].value}");
    while (_bindings!.cellLoad[cellIndex].value != 100) {
      await Future.delayed(const Duration(milliseconds: 20));
      // print("finishing loading: ${_bindings!.cellLoad[cellIndex].value}");
    }

    await Future.delayed(const Duration(milliseconds: 200));

    // print("SHOULD NOT laoding");
    _loadingTimers[cellIndex]?.cancel();
    _loadingTimers.remove(cellIndex);

    // print("end laoding");
    _currentlyLoadingCellIndex = null;
    _bindings!.cellLoad[cellIndex].value = 0;
  }

  void _startLoadingAnimation(int cellIndex) {
    if (_loadingTimers[cellIndex] != null) return;

    _currentlyLoadingCellIndex = cellIndex;
    _bindings!.cellLoad[cellIndex].value = 0.0;

    _loadingTimers[cellIndex] = Timer.periodic(
      const Duration(milliseconds: 20),
      (timer) {
        // print("PERIODIC");

        final currentValue = _bindings!.cellLoad[cellIndex].value;
        final increment = 1.0 + (DateTime.now().millisecond % 5).toDouble();
        final newValue = (currentValue + increment).clamp(0.0, 100.0);
        _bindings!.cellLoad[cellIndex].value = newValue;
      },
    );
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

  void _setInactiveButton() {
    _bindings!.buttonStatus.value = 'grey';
    _bindings!.buttonText.value = 'Comming soon!';
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

    for (var i = 0; i < manager.game.images.length; i++) {
      if (_bindings!.cellsText[i].value.length <= 33) {
        //33 magic number! (text size to fit the display)
        _bindings!.cellImages[i].value = manager.game.images[i];
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

  Future<void> _setCellsStatus() async {
    for (var i = 0; i < manager.game.config.gridSize; i++) {
      if (manager.game.info.gameOverState ==
          GameOverState.displayingSuggestedAnswers) {
        _bindings!.cellStatuses[i].value = "answer";
      } else {
        switch (manager.game.cellAt(i)) {
          case var cell when cell.isLoadingAnswer:
            // _bindings!.cellIsLoading[i].value = true;
            // _startLoadingAnimation(i);
            break;
          case var cell when cell.isAnswered:
            _bindings!.cellStatuses[i].value = "answer";
            _bindings!.cellsText[i].value = manager.game.cellTitle(i);
            break;
          case var cell when cell.isCorrect:
            _bindings!.cellStatuses[i].value = "correct";
            _bindings!.cellsText[i].value = manager.game.cellTitle(i);
            break;
          case var cell when cell.isWrong:
            _bindings!.cellStatuses[i].value = "wrong";
            _bindings!.cellsText[i].value = manager.game.cellTitle(i);
            break;
          default:
            _bindings!.cellStatuses[i].value = "idle";
            break;
        }
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
    _bindings!.outputText.value = "Loading...";
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

  void _updateScore({String? value}) {
    _bindings!.scoreText.value = value ?? manager.game.info.points.toString();
  }

  Future<Uint8List> _getBytesFromLocalAsset(String asset) async =>
      (await rootBundle.load(asset)).buffer.asUint8List();
}
