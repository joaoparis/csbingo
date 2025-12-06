import 'package:csbingo/widgets/bingo_widget.dart';
import 'package:csbingo/widgets/cs2_dialog.dart';
import 'package:flutter/material.dart';

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
      builder: (context) => const Cs2Dialog(
        title: 'Login',
        content: "Login is currently not implemented. 🤡",
        buttonText: 'OK',
      ),
    );
  }

  void _infoDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) => const Cs2Dialog(
        title: 'About CS BINGO',
        content:
            "It's a bingo game for you to play while you wait for CS servers to have 128Hz!",
        buttonText: 'I love it!',
      ),
    );
  }
}
