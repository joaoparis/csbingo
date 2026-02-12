import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csbingo/widgets/cs2_dialog.dart';

class AppShell extends StatefulWidget {
  final GoRouterState routerState;
  final Widget child;

  const AppShell({
    super.key,
    required this.routerState,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  bool _isOnGamePage() {
    return widget.routerState.matchedLocation.startsWith('/game');
  }

  void _howToPlayDialog() {
    showDialog(
      context: context,
      builder: (context) => Cs2Dialog(
        title: 'How to play?',
        content: RichText(
          text: const TextSpan(
            text: "Use the toggle to select the Game Mode you want to play.\n\n"
                "In game:\nTry to match the name of the CS player on the Main Display with one of the cells below.\n\n"
                "The cells will show: Trophies, Teammates, Squads & Nationalities.\n\n"
                "Match the max players possible to win more points.\n\n"
                "The information used in this game is based on all Major Final Stages CS2 and CS:GO.\n\n"
                "Hope you like it!\n"
                "gl hf",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 139, 28),
        title: Text(
          'CS BINGO',
          style: const TextStyle(
            fontFamily: 'HighSpeed',
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          // How to play button
          IconButton(
            tooltip: 'How to play?',
            icon: const Icon(Icons.gamepad_rounded),
            onPressed: _howToPlayDialog,
          ),
          // Theme toggle button
          IconButton(
            tooltip: _themeMode == ThemeMode.dark
                ? 'Disable night mode'
                : 'Enable night mode',
            icon: Icon(_themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: _toggleTheme,
          ),
          // Info button - only show on game page
          if (_isOnGamePage())
            IconButton(
              tooltip: 'Info',
              icon: const Icon(Icons.info_outline),
              onPressed: _infoDialog,
            ),
        ],
      ),
      body: widget.child,
    );
  }
}
