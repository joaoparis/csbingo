import 'package:csbingo/config.dart';
import 'package:csbingo/gateways/board_gateway.dart';
import 'package:csbingo/widgets/bingo_widget.dart';
import 'package:csbingo/widgets/cs2_dialog.dart';
import 'package:flutter/foundation.dart';
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
  void initState() {
    print("[DEBUG] App started");
    print("[DEBUG] API BASE URL: '${AppConfig.apiBaseUrl}'");
    super.initState();
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
  MyHomePage({
    super.key,
    required this.title,
    required this.onToggleTheme,
    required this.themeMode,
  });

  final String title;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  String username = '';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SteamGateway steamGateway = SteamGateway();
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAuthCallback();
    });
  }

  Future<void> _handleAuthCallback() async {
    if (!kIsWeb) {
      return;
    }

    try {
      final userJson = await steamGateway.getUser();

      setState(() {
        widget.username = userJson['username'] ?? '';
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Cs2Dialog(
            title: 'Logged in',
            content: RichText(
              text: TextSpan(
                text: 'Welcome back, ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.3,
                  fontFamily: "StratumNo2",
                ),
                children: [
                  TextSpan(
                    text: widget.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "StratumNo2",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            buttonText: 'Close',
          ),
        );
      }
    } catch (e) {
      // Cookie is missing, invalid, or expired - silently fail
      // This is expected behavior when user is not authenticated
      print('[DEBUG] User not authenticated (cookie missing/invalid): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 139, 28),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'HighSpeed',
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          widget.username.isEmpty
              ? IconButton(
                  tooltip: 'Login',
                  icon: const Icon(Icons.login),
                  onPressed: _loginDialog,
                )
              : Text(widget.username),
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
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                text: "Play CS Bingo under your Steam alias!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.3,
                  fontFamily: "StratumNo2",
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: AnimatedScale(
                scale: _isHovering ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  child: Image.asset("assets/images/steam.png"),
                  onTap: () => steamGateway.login(),
                ),
              ),
            )
          ],
        ),
        buttonText: 'Close',
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
                  decoration: TextDecoration.underline,
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
