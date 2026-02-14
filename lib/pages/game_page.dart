import 'package:csbingo/csbingo.dart';
import 'package:flutter/material.dart';
import 'package:csbingo/widgets/bingo_widget.dart';
import 'package:csbingo/widgets/footer.dart';

class GamePage extends StatefulWidget {
  final ThemeMode themeMode;

  const GamePage({
    super.key,
    required this.themeMode,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 139, 28),
        title: Text(
          'CS BINGO',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontFamily: 'HighSpeed',
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
          IconButton(
            tooltip: 'Info',
            icon: const Icon(Icons.info_outline),
            onPressed: _infoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    _themeMode == ThemeMode.dark
                        ? 'assets/images/BG_LANDSCAPE_NIGHT.png'
                        : 'assets/images/BG_LANDSCAPE.png',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                // Main content with ads - fill the stack
                Positioned.fill(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      // Left ad sidebar
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: const Color.fromARGB(151, 129, 129, 129),
                          width: 200,
                          child: const HtmlElementView(viewType: 'adsense-ad'),
                        ),
                      ),
                      // Center: Game widget
                      const Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: BingoWidget(),
                        ),
                      ),
                      // Right ad sidebar
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: const Color.fromARGB(113, 133, 133, 133),
                          width: 200,
                          child: const HtmlElementView(viewType: 'adsense-ad'),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer
          // const Footer(),
          // Bottom ad
          // const SizedBox(
          //   height: 60,
          //   width: 200,
          //   child: HtmlElementView(viewType: 'adsense-ad'),
          // )
        ],
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
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
}
