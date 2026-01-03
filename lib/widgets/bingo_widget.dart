import 'package:csbingo/game/game.dart';
import 'package:csbingo/game/rive_game_bridge.dart';
import 'package:csbingo/models/game_info.dart';
import 'package:csbingo/models/rive_cell.dart';
import 'package:csbingo/models/rive_bindinds.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class BingoWidget extends StatefulWidget {
  const BingoWidget({super.key});

  @override
  State<BingoWidget> createState() => _BingoWidgetState();
}

class _BingoWidgetState extends State<BingoWidget> {
  bool isInitialized = false;

  late int aux = 0;

  late File _file;
  late RiveWidgetController _controller;
  late ViewModelInstanceString _outputText;
  late ViewModelInstanceString _outputTextInfo;
  late ViewModelInstanceString _timerText;
  late ViewModelInstanceString _scoreText;
  late ViewModelInstanceString _roundText;
  late ViewModelInstanceString _maxRoundText;
  late ViewModelInstanceString _buttonText;
  late ViewModelInstanceString _buttonStatus;
  late ViewModelInstanceTrigger _buttonTrigger;
  late ViewModelInstanceTrigger _cursorTrigger;
  late final List<RiveCell> _cells = [];
  late final List<ViewModelInstanceString> _skips = [];
  late ViewModelInstanceString _secondOutputTitleText;
  late ViewModelInstanceString _secondOutputBodyText;
  late ViewModelInstanceTrigger _loadingTrigger;
  late ViewModelInstanceTrigger _emptyTrigger;
  late ViewModelInstanceTrigger _textTrigger;

  RiveGameBridge? _bridge;
  Game game = Game();

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  @override
  void dispose() {
    _bridge?.dispose();
    _controller.dispose();
    _outputText.dispose();
    _outputTextInfo.dispose();
    _timerText.dispose();
    _scoreText.dispose();
    _roundText.dispose();
    _maxRoundText.dispose();
    _buttonText.dispose();
    _buttonStatus.dispose();
    _buttonTrigger.dispose();
    _cursorTrigger.dispose();
    _file.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return RiveWidget(
      controller: _controller,
      fit: Fit.contain,
    );
  }

  void _initRive() async {
    final file =
        await File.asset("assets/rive/csbingo.riv", riveFactory: Factory.rive);

    if (file == null) {
      print("[DEBUG] Failed to load Rive file.");
      return;
    }
    _file = file;
    _controller = RiveWidgetController(_file);

    final ok = await _initViewModels();
    if (!ok) {
      print('[DEBUG] Failed to init view models; aborting Rive init.');
      return;
    }
    final bindings = RiveBindings(
      buttonText: _buttonText,
      buttonStatus: _buttonStatus,
      buttonTrigger: _buttonTrigger,
      cursorTrigger: _cursorTrigger,
      outputText: _outputText,
      outputTextInfo: _outputTextInfo,
      timerText: _timerText,
      scoreText: _scoreText,
      roundText: _roundText,
      maxRoundText: _maxRoundText,
      cellImages: _cells.map((c) => c.imageViewModel).toList(),
      cellStatuses: _cells.map((c) => c.status).toList(),
      cellsText: _cells.map((c) => c.text).toList(),
      skips: _skips,
      cellTaps: _cells.map((c) => c.tap).toList(),
      secondOutputTitleText: _secondOutputTitleText,
      secondOutputBodyText: _secondOutputBodyText,
      secondOutputLoadingTrigger: _loadingTrigger,
      secondOutputEmptyTrigger: _emptyTrigger,
      secondOutputTextTrigger: _textTrigger,
    );
    _bridge = RiveGameBridge(game: game);
    await _bridge!.init(controller: _controller, bindings: bindings);
    setState(() => isInitialized = true);
  }

  Future<bool> _initViewModels() async {
    final viewModelInstance = _controller.dataBind(DataBind.auto());
    //OUTPUT TEXT
    final outputText = viewModelInstance.string("outputText");
    final outputTextInfo = viewModelInstance.string("outputTextInfo");
    final timerText = viewModelInstance.string("timerText");
    final scoreText = viewModelInstance.string("scoreText");
    final roundText = viewModelInstance.string("roundText");
    final maxRoundText = viewModelInstance.string("maxRoundText");
    final buttonText = viewModelInstance.string("buttonText");
    final buttonStatus = viewModelInstance.string("buttonStatus");
    final buttonTrigger = viewModelInstance.trigger("buttonTrigger");
    final cursorTrigger = viewModelInstance.trigger("cursorVM/cursorTrigger");
    //SKIPS
    for (var i = 1; i <= 3; i++) {
      var skip = viewModelInstance.string("skipsVM/skip$i/status");
      if (skip == null) {
        print("[DEBUG] Failed to load string for skip $i");
        return false;
      }
      _skips.add(skip);
    }

    //CELLS
    for (var i = 0; i < 16; i++) {
      var img = viewModelInstance.image("cellsVM/cell$i/image");
      if (img == null) {
        print("[DEBUG] Failed to load image view model for cell $i");
        return false;
      }
      var str = viewModelInstance.string("cellsVM/cell$i/status");
      if (str == null) {
        print("[DEBUG] Failed to load status for cell $i");
        return false;
      }
      var txt = viewModelInstance.string("cellsVM/cell$i/text");
      if (txt == null) {
        print("[DEBUG] Failed to load text for cell $i");
        return false;
      }
      var tap = viewModelInstance.trigger("cellsVM/cell$i/tapped");
      if (tap == null) {
        print("[DEBUG] Failed to load tap trigger for cell $i");
        return false;
      }
      _cells.add(RiveCell(img, str, txt, tap));
    }

    //SECOND OUTPUT
    final secondOutputTitleText =
        viewModelInstance.string("secondOutputVM/title");
    final secondOutputBodyText =
        viewModelInstance.string("secondOutputVM/body");
    final loadingTrigger = viewModelInstance.trigger("secondOutputVM/loading");
    final emptyTrigger = viewModelInstance.trigger("secondOutputVM/empty");
    final textTrigger = viewModelInstance.trigger("secondOutputVM/text");

    if (outputText == null ||
        outputTextInfo == null ||
        timerText == null ||
        scoreText == null ||
        roundText == null ||
        maxRoundText == null ||
        buttonText == null ||
        buttonStatus == null ||
        buttonTrigger == null ||
        cursorTrigger == null ||
        secondOutputTitleText == null ||
        secondOutputBodyText == null ||
        loadingTrigger == null ||
        emptyTrigger == null ||
        textTrigger == null) {
      print("[DEBUG] something is null: outputText=$outputText, "
          "outputTextInfo=$outputTextInfo timerText=$timerText, "
          "scoreText=$scoreText, roundText=$roundText, "
          "maxRoundText=$maxRoundText, buttonText=$buttonText, "
          "buttonTrigger=$buttonTrigger, buttonStatus=$buttonStatus"
          "cursorTrigger=$cursorTrigger secondOutputTitleText=$secondOutputTitleText "
          "secondOutputBodyText=$secondOutputBodyText loadingTrigger=$loadingTrigger "
          "emptyTrigger=$emptyTrigger textTrigger=$textTrigger");
      return false;
    }

    _outputText = outputText;
    _outputTextInfo = outputTextInfo;
    _timerText = timerText;
    _scoreText = scoreText;
    _roundText = roundText;
    _maxRoundText = maxRoundText;
    _buttonText = buttonText;
    _buttonTrigger = buttonTrigger;
    _cursorTrigger = cursorTrigger;
    _buttonStatus = buttonStatus;
    _secondOutputTitleText = secondOutputTitleText;
    _secondOutputBodyText = secondOutputBodyText;
    _loadingTrigger = loadingTrigger;
    _emptyTrigger = emptyTrigger;
    _textTrigger = textTrigger;

    print("[DEBUG] all view model instances loaded successfully!");
    return true;
  }
}
