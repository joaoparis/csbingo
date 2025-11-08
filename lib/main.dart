import 'dart:async';

import 'package:csbingo/bingo_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CS BINGO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CS BINGO 🔫'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG_LANDSCAPE.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          const SafeArea(
            child: RiveCSBingo(),
            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Center(
            //     child: BingoGame(),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}

class RiveCSBingo extends StatefulWidget {
  const RiveCSBingo({super.key});

  @override
  State<RiveCSBingo> createState() => _RiveCSBingoState();
}

class _RiveCSBingoState extends State<RiveCSBingo> {
  bool isInitialized = false;

  late File _file;
  late RiveWidgetController _controller;
  late ViewModelInstanceString _outputText;
  late ViewModelInstanceString _timerText;
  late ViewModelInstanceString _scoreText;
  late ViewModelInstanceAssetImage _cell;

  @override
  void initState() {
    super.initState();
    initRive();
  }

  void initRive() async {
    _file = (await File.asset("assets/rive/csbingo.riv",
        riveFactory: Factory.rive))!;
    _file.artboardToBind("c4");
    _controller = RiveWidgetController(_file);

    final viewModelInstance = _controller.dataBind(DataBind.auto());

    final outputText = viewModelInstance.string("outputText");
    final timerText = viewModelInstance.string("timerText");
    final scoreText = viewModelInstance.string("scoreText");
    final cell = viewModelInstance.image("cellOne");
    if (outputText == null ||
        timerText == null ||
        scoreText == null ||
        cell == null) {
      print(
          "something is null: outputText=$outputText, timerText=$timerText, scoreText=$scoreText, cell=$cell");
    } else {
      _outputText = outputText;
      _timerText = timerText;
      _scoreText = scoreText;
      _cell = cell;
      print("all view model instances loaded successfully: cell=${cell}");

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

    setState(() => isInitialized = true);
  }

  @override
  void dispose() {
    _outputText.dispose();
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
    _scoreText.value = "0pts";

    // _cell.value = null;

    return RiveWidget(
      controller: _controller,
      fit: Fit.contain,
    );
  }
}
