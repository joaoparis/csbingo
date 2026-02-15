import 'dart:async';

import 'package:csbingo/csbingo.dart';

class DailyGame extends IGame {
  @override
  GameConfig get config => const GameConfig();

  bool isEvaluatingAnswer = false;

  @override
  void dispose() {
    try {
      timer.timerText.removeListener(timerListener);
    } catch (_) {}
    timerFinishedSub.cancel();
    timer.dispose();
    super.dispose();
  }

  @override
  void reset() {
    info = GameInfo.forPlaceholders(
      gridSize: config.gridSize,
      maxRounds: config.maxRounds,
      skips: config.maxSkips,
    );

    _notify("reset(): info.state=${info.state}");
  }

  @override
  Future<void> initialize() async {
    info.currentRound = 0;
    info.skips = config.maxSkips;
    info.gameOverState = GameOverState.displayingPlayerAnswers;

    _setupTimer();
    info = GameInfo.forLoading(
      config.gridSize,
      config.maxRounds,
      config.maxSkips,
      info.type,
    );
    _notify("_loadGame(): start loading game=${info.state}");
    await _loadGame();
    images = await imagesGateway.loadImages(info.cells);

    info.state = GameState.playing;
    timer.startTimer(config.roundTime);
    _notify("initialize(): state=${info.state}");
  }

  @override
  Future<void> gameOver() async {
    info.state = GameState.inactive;
    timer.timerText.removeListener(timerListener);
    timerFinishedSub.cancel();
    _notify("gameOver(): info.state=${info.state}");
    reset();
  }

  @override
  Future<void> skip() async {
    if (info.skips <= 0) return;

    await evaluateAction();

    if (isNotLastRound) {
      info.currentRound++;
      info.skips--;
      if (hasSkips) {
        timer.resetTimer();
        timer.startTimer(config.roundTime);
      }
    } else {
      resetCurrentRound;
      timer.resetTimer();
      _updateStatesWithGameOver();
    }
    _notify("skip(): info.state=${info.state}");
  }

  @override
  Future<void> selectCell(int index) async {
    if (info.state != GameState.playing) return;

    final cell = info.cells[index];
    if (cell.isCorrect) return;

    await evaluateAction(index: index);

    if (isBoardComplete) {
      resetCurrentRound;
      timer.resetTimer();
      _updateStatesWithGameOver();
      _notify(
          "selectCell(): _isBoardComplete=$isBoardComplete info.state=${info.state}");
      return;
    }

    if (isNotLastRound) {
      info.currentRound++;
      timer.resetTimer();
      timer.startTimer(config.roundTime);
      return;
    }

    resetCurrentRound;
    timer.resetTimer();
    _updateStatesWithGameOver();
    _notify(
        "selectCell(): _isBoardComplete=$isBoardComplete info.state=${info.state}");
  }

  @override
  Future<void> evaluateAction({int index = -1}) async {
    info.cells[index].isLoadingAnswer = true;
    _notify("evaluateAction(): cell $index is loading answer");

    info.state = GameState.verifyingAnswer;

    var dto = await gateway.sendAction(
      info.cardId,
      cellId: index,
      skip: index == -1 ? true : false,
    );
    // DEBUG await Future.delayed(const Duration(milliseconds: 500));

    info.state = GameState.playing;

    info.cells[index].isLoadingAnswer = false;
    _notify("evaluateAction(): cell $index is loading answer");

    if (index == -1) return;

    info.cells[index].isWrong = false;
    _notify("_evaluateAction(): before evaluating answer");

    if (dto.cells[index].isCorrect) {
      // print(
      //     "[DEBUG] ✅ Right answer ✅ card:${gameInfo.cardId} round:$currentRound [cell index: $index] match: ${info.cells[index].title} <> ${gameInfo.players[currentRound].name}");
      info.setCorrectCell(index, dto.cells[index], info.currentRound);
      info.setPoints(dto.points);
      _notify("_evaluateAction(): reset wrong answer visual");
    } else {
      // print(
      //     "[DEBUG] ❌ Wrong answer! ❌ round:$currentRound [cell index: $index] try: ${info.cells[index].title} <> ${gameInfo.players[currentRound].name}");
      info.setIncorrectCell(index, dto.cells[index]);
      info.cells[index].isWrong = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        info.cells[index].isWrong = false;
        _notify("_evaluateAction(): reset wrong answer visual");
      });
    }
  }

  @override
  Future<void> toggleGameOverState() async {
    _toggleGameOverCursor();
    _updateCellsText();
    _notify("toggleGameOverState(): gameOverState=${info.gameOverState}");
  }

  @override
  Future<void> getAnswers() async {
    var dto = await gateway.getAnswers(info.gameId);
    for (var i = 0; i < info.cells.length; i++) {
      info.suggestedAnswers[i] = dto.answers[i].answer;
    }
    _notify("getAnswers(): answers fetched for all cells");
  }

  void _toggleGameOverCursor() {
    var newIndex = info.gameOverState.index + 1;

    if (newIndex == GameOverState.values.length) {
      info.gameOverState = GameOverState.values[0];
      return;
    }

    info.gameOverState = GameOverState.values[newIndex];
  }

  void _updateCellsText() {
    if (info.gameOverState == GameOverState.displayingPlayerAnswers) {
      info.setUserAnswers();
    } else {
      info.setSuggestedAnswers();
    }
  }

  _notify(String src) {
    if (config.debugMode) {
      print(
          "[NOTIFYING] Source: $src State: ${info.state} hasListeners: $hasListeners $hashCode");
    }
    notifyListeners();
  }

  void _setupTimer() {
    timerListener = () => _notify("timer");
    timer.timerText.addListener(timerListener);
    timerFinishedSub = timer.onTimerFinished.listen((_) {
      _onTimerFinished();
    });
  }

  void _onTimerFinished() {
    if (isNotLastRound && isNotGameOver) {
      info.currentRound++;
      evaluateAction();
      timer.resetTimer();
      timer.startTimer(config.roundTime);
      return;
    }
    resetCurrentRound();
    timer.resetTimer();
    _updateStatesWithGameOver();
    _notify("_onTimerFinished(): info.state=${info.state}");
  }

  Future<void> _loadGame() async {
    try {
      var dto = await gateway.createCard(info.type.name);
      info = GameInfo.fromDTO(
        dto,
        config.maxSkips,
        0,
        info.type,
      );
      // _notify("_loadGame(): game has loaded info.state=$info.state");
    } catch (err) {
      info.state = GameState.error;
      // _notify(
      //     "_loadGame(): failed to load game, reverting to info.state=${info.state}");
      rethrow;
    }
  }

  void _updateStatesWithGameOver() {
    info.state = GameState.gameOver;
    for (var cell in info.cells) {
      cell.isAnswered = false;
    }
    setGameOverOnManager();
  }
}
