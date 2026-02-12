import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:csbingo/widgets/footer.dart';
import 'package:csbingo/widgets/cs2_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
            child: Row(
              children: [
                // Image on the left
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/BG_LANDSCAPE_NIGHT.png',
                      fit: BoxFit.cover,
                      height: 400,
                    ),
                  ),
                ),
                const SizedBox(width: 60),
                // Start Button on the right
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ready to play?',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontFamily: 'HighSpeed',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Test your knowledge of CS2 players and teams!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontFamily: 'StratumNo2',
                              color: Colors.white70,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      CS2Button(
                        text: 'START',
                        onPressed: () => context.go('/game'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(
            height: 60,
            thickness: 1,
            color: Colors.white24,
          ),

          // Instructions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontFamily: 'HighSpeed',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 40),
                RichText(
                  text: const TextSpan(
                    text:
                        "Use the toggle to select the Game Mode you want to play.\n\n"
                        "In game:\n"
                        "Try to match the name of the CS player on the Main Display with one of the cells below.\n\n"
                        "The cells will show: Trophies, Teammates, Squads & Nationalities.\n\n"
                        "Match the max players possible to win more points.\n\n"
                        "The information used in this game is based on all Major Final Stages CS2 and CS:GO.\n\n"
                        "Hope you like it!\n"
                        "gl hf",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.6,
                      fontFamily: "StratumNo2",
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          const Footer(),
        ],
      ),
    );
  }
}
