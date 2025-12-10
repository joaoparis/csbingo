import 'package:csbingo/widgets/bingo_widget.dart';
import 'package:csbingo/widgets/cs2_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 243, 139, 28),
      ),
      useMaterial3: true,
    );

    final dark = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 243, 139, 28),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'CS BINGO',
      theme: light,
      darkTheme: dark,
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'CS BINGO',
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onToggleTheme,
    required this.themeMode,
  });

  final String title;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // use theme's primary color so the AppBar adapts to light/dark
        backgroundColor: const Color.fromARGB(255, 243, 139, 28),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'HighSpeed', // matches family in pubspec.yaml
            fontSize: 40,
            fontWeight: FontWeight.w700, // choose a weight that exists
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Login',
            icon: const Icon(Icons.login),
            onPressed: _loginDialog,
          ),
          IconButton(
            tooltip: 'How to play?',
            icon: const Icon(Icons.gamepad_rounded),
            onPressed: _howToPlayDialog,
          ),
          IconButton(
            tooltip: widget.themeMode == ThemeMode.dark
                ? 'Disable night mode'
                : 'Enable night mode',
            icon: Icon(widget.themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            tooltip: 'Info',
            icon: const Icon(Icons.info_outline),
            onPressed: _infoDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.themeMode == ThemeMode.dark
                  ? 'assets/images/BG_LANDSCAPE_NIGHT.png'
                  : 'assets/images/BG_LANDSCAPE.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          const SafeArea(
            child: BingoWidget(),
          ),
        ],
      ),
    );
  }

  void _loginDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) => Cs2Dialog(
        title: 'Login',
        content: RichText(
          text: const TextSpan(
            text: "Login is currently not implemented. 🤡",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.3,
              fontFamily: "StratumNo2",
            ),
          ),
        ),
        buttonText: 'OK',
      ),
    );
  }

  void _howToPlayDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) => Cs2Dialog(
        title: 'How to play?',
        content: RichText(
          text: const TextSpan(
            text: "Use the cursor to select the Game Mode you want to play.\n"
                "In game: Try to match the name of the CS player on the Main Display with one of the cells below.\n"
                "The cells will show: Trophies, Teammates, Squads & Nationalities\n"
                "Match the max players possible to win!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.3,
              fontFamily: "StratumNo2",
            ),
          ),
        ),
        buttonText: "Let's go!",
      ),
    );
  }

  void _infoDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) => Cs2Dialog(
        title: 'About CS BINGO',
        content: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text:
                    "It's a bingo game for you to play while you wait for CS servers to have 128Hz!\n\nCreated by ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.3,
                  fontFamily: "StratumNo2",
                ),
              ),
              TextSpan(
                text: 'PáR1S',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.3,
                  fontFamily: "StratumNo2",
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () =>
                      launchUrl(Uri.parse('https://joaoparis.github.io/')),
              ),
            ],
          ),
        ),
        buttonText: 'I love it!',
      ),
    );
  }
}
