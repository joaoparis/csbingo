import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  late int _points = 0;
  late RiveWidgetController _controller;
  late ViewModelInstanceString _outputText;
  late ViewModelInstanceString _timerText;
  late ViewModelInstanceString _scoreText;
  late ViewModelInstanceString _buttonText;
  late ViewModelInstanceString _buttonStatus;
  late ViewModelInstanceTrigger _buttonTrigger;
  late ViewModelInstanceAssetImage _cell;
  late ViewModelInstanceString _cellStatus;
  late ViewModelInstanceString _cellNumber;

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  @override
  void dispose() {
    _outputText.dispose();
    _timerText.dispose();
    _scoreText.dispose();
    _buttonText.dispose();
    _buttonStatus.dispose();
    _buttonTrigger.dispose();
    _cell.dispose();
    _cellStatus.dispose();
    _cellNumber.dispose();
    _file.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    _outputText.value = "KNZZ és um bot";
    _timerText.value = "00:01";
    _scoreText.value = "${_points}pts";
    _buttonText.value = "PLAY";

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
    _controller.stateMachine.addEventListener(_onRiveEvent);

    final areViewModelsReady = await _initViewModels();
    setState(() => isInitialized = areViewModelsReady);
  }

  void _onRiveEvent(dynamic event) {
    var handled = false;
    if ((event.name as String).startsWith(RegExp(r'^Click \d+$'))) {
      final cellIndex = int.parse((event.name as String).split(' ').last);
      _cellNumber.value = cellIndex.toString();
      cellIndex % 2 == 0
          ? _cellStatus.value = "wrong"
          : _cellStatus.value = "correct";
      handled = true;
    }

    if (event.name == 'buttonClick') {
      _outputText.value = (aux % 2 == 0) ? "gg" : "wp";
      _timerText.value = (aux % 2 == 0) ? "00:02" : "00:01";
      _scoreText.value = "${_points}pts";
      _buttonText.value = (aux % 2 == 0) ? "SKIP" : "DONE";
      _buttonStatus.value = (aux % 2 == 0) ? "red" : "blue";
      _points++;
      aux++;
      handled = true;
    }

    if (!handled) {
      print("Unhandled Rive event: ${event.name}");
    }
  }

  Future<bool> _initViewModels() async {
    final viewModelInstance = _controller.dataBind(DataBind.auto());
    //OUTPUT TEXT
    final outputText = viewModelInstance.string("outputText");
    final timerText = viewModelInstance.string("timerText");
    final scoreText = viewModelInstance.string("scoreText");
    final buttonText = viewModelInstance.string("buttonText");
    final buttonStatus = viewModelInstance.string("buttonStatus");
    final buttonTrigger = viewModelInstance.trigger("buttonTrigger");
    //CELLS
    final cell = viewModelInstance.image("cellOne");
    final cellStatus = viewModelInstance.string("cellStatus");
    final cellNumber = viewModelInstance.string("cellNumber");

    if (outputText == null ||
        timerText == null ||
        scoreText == null ||
        buttonText == null ||
        buttonStatus == null ||
        buttonTrigger == null ||
        cellStatus == null ||
        cellNumber == null ||
        cell == null) {
      print("something is null: outputText=$outputText, timerText=$timerText, "
          "scoreText=$scoreText, buttonText=$buttonText, buttonTrigger=$buttonTrigger"
          "buttonStatus=$buttonStatus cell=$cell");
      return false;
    }

    _outputText = outputText;
    _timerText = timerText;
    _scoreText = scoreText;
    _buttonText = buttonText;
    _buttonTrigger = buttonTrigger;
    _buttonStatus = buttonStatus;
    _cellStatus = cellStatus;
    _cellNumber = cellNumber;
    _cell = cell;
    print("all view model instances loaded successfully!");
    _exampleSetCellImage();
    return true;
  }

  void _exampleSetCellImage() async {
    final response = await http.get(Uri.parse("https://picsum.photos/200"));
    final bytes = response.bodyBytes;
    final renderImage = await Factory.rive.decodeImage(bytes);
    if (renderImage != null) {
      _cell.value = renderImage;
      print("Successfully set image for cell");
    } else {
      print("Failed to decode image for cell");
    }
  }
}
