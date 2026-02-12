import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csbingo/widgets/bingo_widget.dart';
import 'package:csbingo/widgets/footer.dart';

class GamePage extends StatelessWidget {
  final ThemeMode themeMode;

  const GamePage({
    super.key,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            themeMode == ThemeMode.dark
                ? 'assets/images/BG_LANDSCAPE_NIGHT.png'
                : 'assets/images/BG_LANDSCAPE.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.3),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        // Main content with ads and game
        SingleChildScrollView(
          child: Column(
            children: [
              Flex(
                direction: Axis.horizontal,
                children: [
                  // Left ad sidebar
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: const Color.fromARGB(151, 129, 129, 129),
                      height: 600,
                      width: 200,
                      child: const HtmlElementView(viewType: 'adsense-ad'),
                    ),
                  ),
                  // Center: Game widget
                  const Expanded(
                    flex: 4,
                    child: SafeArea(
                      child: BingoWidget(),
                    ),
                  ),
                  // Right ad sidebar
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: const Color.fromARGB(113, 133, 133, 133),
                      height: 600,
                      width: 200,
                      child: const HtmlElementView(viewType: 'adsense-ad'),
                    ),
                  )
                ],
              ),
              // Footer
              const Footer(),
            ],
          ),
        ),
        // Bottom ad
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 600,
            width: 200,
            child: const HtmlElementView(viewType: 'adsense-ad'),
          ),
        )
      ],
    );
  }
}
