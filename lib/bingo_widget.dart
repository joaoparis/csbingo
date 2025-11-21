import 'package:csbingo/game.dart';
import 'package:csbingo/rive_game_bridge.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';

class CellImage {
  final ViewModelInstanceAssetImage imageViewModel;
  final ViewModelInstanceString status;
  CellImage(
    this.imageViewModel,
    this.status,
  );
}

class BingoWidget extends StatefulWidget {
  const BingoWidget({super.key});

  @override
  State<BingoWidget> createState() => _BingoWidgetState();
}

class _BingoWidgetState extends State<BingoWidget> {
  bool isInitialized = false;

  late int aux = 0;

  late File _file;
  late int _points = 0;
  late RiveWidgetController _controller;
  late ViewModelInstanceString _outputText;
  late ViewModelInstanceString _timerText;
  late ViewModelInstanceString _scoreText;
  late ViewModelInstanceString _buttonText;
  late ViewModelInstanceString _buttonStatus;
  late ViewModelInstanceTrigger _buttonTrigger;
  late final List<CellImage> _cells = [];

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
      print("Failed to load Rive file.");
      return;
    }
    _file = file;
    _controller = RiveWidgetController(_file);

    await _initViewModels();
    final bindings = ViewModelInstanceBindings(
      buttonText: _buttonText,
      buttonStatus: _buttonStatus,
      buttonTrigger: _buttonTrigger,
      outputText: _outputText,
      timerText: _timerText,
      scoreText: _scoreText,
      cellImages: _cells.map((c) => c.imageViewModel).toList(),
      cellStatuses: _cells.map((c) => c.status).toList(),
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
    final buttonText = viewModelInstance.string("buttonText");
    final buttonStatus = viewModelInstance.string("buttonStatus");
    final buttonTrigger = viewModelInstance.trigger("buttonTrigger");
    //CELLS
    final cellStatus = viewModelInstance.string("cellStatus");
    final cellNumber = viewModelInstance.string("cellNumber");
    final cellTrigger = viewModelInstance.trigger("cellTrigger");
    for (var i = 0; i < 16; i++) {
      var img = viewModelInstance.image("c $i");
      if (img == null) {
        print("Failed to load image view model for cell $i");
        return;
      }
      var str = viewModelInstance.string("c${i}status");
      if (str == null) {
        print("Failed to load status for cell $i");
        return;
      }
      _cells.add(CellImage(img, str));
    }

    if (outputText == null ||
        timerText == null ||
        scoreText == null ||
        buttonText == null ||
        buttonStatus == null ||
        buttonTrigger == null ||
        cellStatus == null ||
        cellNumber == null ||
        cellTrigger == null) {
      print("something is null: outputText=$outputText, timerText=$timerText, "
          "scoreText=$scoreText, buttonText=$buttonText, buttonTrigger=$buttonTrigger"
          "buttonStatus=$buttonStatus cell=$cellStatus, cellNumber=$cellNumber"
          "cellTrigger=$cellTrigger");
      return;
    }

    _outputText = outputText;
    _timerText = timerText;
    _scoreText = scoreText;
    _buttonText = buttonText;
    _buttonTrigger = buttonTrigger;
    _buttonStatus = buttonStatus;

    print("all view model instances loaded successfully!");
    return;
  }
}
