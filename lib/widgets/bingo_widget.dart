import 'package:csbingo/game/game.dart';
import 'package:csbingo/game/rive_game_bridge.dart';
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
  late ViewModelInstanceString _timerText;
  late ViewModelInstanceString _scoreText;
  late ViewModelInstanceString _roundText;
  late ViewModelInstanceString _maxRoundText;
  late ViewModelInstanceString _buttonText;
  late ViewModelInstanceString _buttonStatus;
  late ViewModelInstanceTrigger _buttonTrigger;
  late final List<RiveCell> _cells = [];
  late final List<ViewModelInstanceString> _skips = [];

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
    _timerText.dispose();
    _scoreText.dispose();
    _roundText.dispose();
    _maxRoundText.dispose();
    _buttonText.dispose();
    _buttonStatus.dispose();
    _buttonTrigger.dispose();
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

    await _initViewModels();
    final bindings = RiveBindings(
      buttonText: _buttonText,
      buttonStatus: _buttonStatus,
      buttonTrigger: _buttonTrigger,
      outputText: _outputText,
      timerText: _timerText,
      scoreText: _scoreText,
      roundText: _roundText,
      maxRoundText: _maxRoundText,
      cellImages: _cells.map((c) => c.imageViewModel).toList(),
      cellStatuses: _cells.map((c) => c.status).toList(),
      cellsText: _cells.map((c) => c.text).toList(),
      skips: _skips,
      cellTaps: _cells.map((c) => c.tap).toList(),
    );
    _bridge = RiveGameBridge(game: game);
    await _bridge!.init(controller: _controller, bindings: bindings);
    setState(() => isInitialized = true);
  }

  Future<void> _initViewModels() async {
    final viewModelInstance = _controller.dataBind(DataBind.auto());
    //OUTPUT TEXT
    final outputText = viewModelInstance.string("outputText");
    final timerText = viewModelInstance.string("timerText");
    final scoreText = viewModelInstance.string("scoreText");
    final roundText = viewModelInstance.string("roundText");
    final maxRoundText = viewModelInstance.string("maxRoundText");
    final buttonText = viewModelInstance.string("buttonText");
    final buttonStatus = viewModelInstance.string("buttonStatus");
    final buttonTrigger = viewModelInstance.trigger("buttonTrigger");
    //SKIPS
    for (var i = 1; i <= 3; i++) {
      var skip = viewModelInstance.string("skipsVM/skip$i/status");
      if (skip == null) {
        print("[DEBUG] Failed to load string for skip 1");
        return;
      }
      _skips.add(skip);
    }

    //CELLS
    for (var i = 0; i < 16; i++) {
      var img = viewModelInstance.image("cellsVM/cell$i/image");
      if (img == null) {
        print("[DEBUG] Failed to load image view model for cell $i");
        return;
      }
      var str = viewModelInstance.string("cellsVM/cell$i/status");
      if (str == null) {
        print("[DEBUG] Failed to load status for cell $i");
        return;
      }
      var txt = viewModelInstance.string("cellsVM/cell$i/text");
      if (txt == null) {
        print("[DEBUG] Failed to load text for cell $i");
        return;
      }
      var tap = viewModelInstance.trigger("cellsVM/cell$i/tapped");
      if (tap == null) {
        print("[DEBUG] Failed to load tap trigger for cell $i");
        return;
      }
      _cells.add(RiveCell(img, str, txt, tap));
    }

    if (outputText == null ||
        timerText == null ||
        scoreText == null ||
        roundText == null ||
        maxRoundText == null ||
        buttonText == null ||
        buttonStatus == null ||
        buttonTrigger == null) {
      print(
          "[DEBUG] something is null: outputText=$outputText, timerText=$timerText, "
          "scoreText=$scoreText, roundText=$roundText, maxRoundText=$maxRoundText, "
          "buttonText=$buttonText, buttonTrigger=$buttonTrigger, "
          "buttonStatus=$buttonStatus");
      return;
    }

    _outputText = outputText;
    _timerText = timerText;
    _scoreText = scoreText;
    _roundText = roundText;
    _maxRoundText = maxRoundText;
    _buttonText = buttonText;
    _buttonTrigger = buttonTrigger;
    _buttonStatus = buttonStatus;

    print("[DEBUG] all view model instances loaded successfully!");
    return;
  }
}
