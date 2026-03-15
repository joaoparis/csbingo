import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:csbingo/widgets/footer.dart';
import 'package:csbingo/widgets/cs2_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: height * 2 / 5,
            elevation: 0,
            backgroundColor: const Color.fromARGB(255, 243, 139, 28),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.black),
              expandedTitleScale: 4.0,
              titlePadding: const EdgeInsets.fromLTRB(15.0, 8.0, 0, 8.0),
              title: Text(
                'CS BINGO',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontFamily: 'HighSpeed',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: height * 3 / 5,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 0, 0, 0),
                        Color.fromARGB(255, 32, 32, 32),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.6, 0.9],
                      tileMode: TileMode.repeated,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'How to play?',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontFamily: 'StratumNo2',
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(Icons.arrow_downward_rounded),
                    ],
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: double.infinity,
                    height: height * 3 / 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Are you a Global Elite or just another Silver rushing B without a flash?\n'
                          'The bomb is ticking, and your brain is lagging. Stop baiting your teammates and prove you’re not a bot.\n'
                          'Enter the lobby if you dare.\n',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontFamily: 'StratumNo2',
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        CS2Button(
                          text: 'PLAY NOW',
                          size: 60,
                          onPressed: () => context.go('/game'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // How to play - full screen section with bottom-left image
          SliverToBoxAdapter(
            child: Container(
              color: const Color.fromARGB(255, 32, 32, 32),
              height: height * 3 / 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final imageWidth = constraints.maxWidth * 0.45;
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 40.0, right: 40.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How to play?',
                                  style:
                                      theme.textTheme.headlineLarge?.copyWith(
                                    fontFamily: 'HighSpeed',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      "Listen up, team. This isn't your grandma’s bingo—it’s a high-stakes matching operation.\n"
                                      "We’ve extracted data from every CS:GO and CS2 Major Final phase event in history.\n"
                                      "Your mission is to match the legends, the icons, and the teams before the 'Bingo C4' blows the site.\n"
                                      "You’ll be playing against the clock across multiple rounds. Check your corners, match the cells, and don't whiff your shots.\n\n"
                                      "Pick the game mode you feel more confy with - use the toggle button to do so.\n"
                                      "In game: just match the nickname of the pro with the cell that fits best... gl hf!",
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontFamily: 'StratumNo2',
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: imageWidth,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/menu.png',
                                width: imageWidth,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 80.0, vertical: 60.0),
                  child: Text(
                    'Game Modes',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontFamily: 'HighSpeed',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          //Daily explanation
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 80.0, vertical: 60.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/BG_LANDSCAPE.png',
                          fit: BoxFit.cover,
                          height: 320,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Daily Grind',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontFamily: 'HighSpeed',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          RichText(
                            text: const TextSpan(
                              text:
                                  "Think you’ve got the stamina for a Major? The Daily Challenge puts you through 20 grueling rounds. You have 2 minutes to correctly match all 16 cells on the grid. If you get one wrong, don't tilt—the cell resets so you can try again. If you’re totally flashed, you’ve got 3 skips for the entire game. Match them all to advance, or let the timer run out and take the L.\n\n"
                                  "Stay frosty.",
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
                  ],
                ),
              ),
            ),
          ),

          //Random explanation
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 80.0, vertical: 60.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/BG_LANDSCAPE.png',
                          fit: BoxFit.cover,
                          height: 320,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spray and pray',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontFamily: 'HighSpeed',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          RichText(
                            text: const TextSpan(
                              text:
                                  "Welcome to Random Mode, where there are no do-overs and no respect for your 'calculated' guesses.\n"
                                  "Like a full eco round, you have to make every click count. You have 2 minutes to answer every cell, but here’s the catch: once you click, it’s locked. Whether you’re right or wrong, that cell is done, and you’re moving on. Answer all 16 cells to reach the next round.\n\n"
                                  "One tap or bust—don't spray and pray.",
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
                  ],
                ),
              ),
            ),
          ),

          //FFA explanation
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 80.0, vertical: 60.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/BG_LANDSCAPE.png',
                          fit: BoxFit.cover,
                          height: 320,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Free for all...',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontFamily: 'HighSpeed',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          RichText(
                            text: const TextSpan(
                              text: "Currently under development 🚧\n\n"
                                  "Nothing says 'Tactical Cooperation' like humiliating your friends.\n"
                                  "In Free For All, you and your 'buddies' join a lobby to tackle the exact same bingo card. It’s a straight-up race to the finish. The first one to solve the board wins the bragging rights; the rest of you get kicked from the server (mentally).\n\n"
                                  "It’s clutch or kick time—who’s the real top fragger?",
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
                  ],
                ),
              ),
            ),
          ),

          //Play button
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: SizedBox(
                width: double.infinity,
                height: height * 3 / 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ready?',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontFamily: 'StratumNo2',
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    CS2Button(
                      text: 'PLAY NOW',
                      size: 40,
                      onPressed: () => context.go('/game'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //About
          SliverToBoxAdapter(
            child: Container(
              color: const Color.fromARGB(255, 32, 32, 32),
              height: height * 3 / 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 40.0, right: 40.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style:
                                      theme.textTheme.headlineLarge?.copyWith(
                                    fontFamily: 'HighSpeed',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      "CS Bingo is a free-to-play browser game created for Counter-Strike 2 players who live and breathe the game. Whether you're grinding Premier, watching Majors, or arguing about the meta with your stack, this game was built with you in mind."
                                      "The idea came from seeing how much the community enjoys Counter-Strike trivia, inside jokes, and deep knowledge about maps, mechanics, and iconic moments. There was clear interest in having a game focused purely on Counter-Strike lore and game sense — something competitive, fast, and memory-based, but also fun."
                                      "This project is not affiliated with Valve, but it is inspired by the culture, strategy, and history surrounding Counter-Strike. The goal is simple: create a place where CS2 players can test their knowledge, compete with friends, and prove they truly understand the game beyond just aim and mechanics."
                                      "No downloads, no paywalls, no hidden mechanics. Just open your browser and play.",
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontFamily: 'StratumNo2',
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // QA
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 40.0, right: 40.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q&A',
                                  style:
                                      theme.textTheme.headlineLarge?.copyWith(
                                    fontFamily: 'HighSpeed',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      "Q: Is CS Bingo free to play?\n"
                                      "A:Yes. CS Bingo is completely free to play. There are no entry fees, no purchases required, and no pay-to-win mechanics."
                                      "\n\nQ: Do I need to register to play?\n"
                                      "A: No registration is required for basic gameplay. You can jump straight into the action. Some features like tracking progress or competing with friends may require joining a lobby."
                                      "\n\nQ: Does the game involve real money or gambling?\n"
                                      "A: No. CS Bingo does not involve gambling, betting, or real-money prizes. It is purely a knowledge and skill-based browser game created for entertainment."
                                      "\n\nQ: Can I play on mobile?\n"
                                      "A: Yes. CS Bingo will is designed to run in modern web browsers and works on desktop and most mobile devices. For the best competitive experience, desktop is recommended."
                                      "\n\nQ: How often are boards updated?\n"
                                      "A: Game boards and challenges are updated regularly to reflect Counter-Strike updates, meta changes, and community trends. The Daily Challenge refreshes each day, giving players new opportunities to test their knowledge."
                                      "\n\nQ: What data is used?\n"
                                      "A: The game is based on all final stages of Counter-Strike Major events: which include CS:GO and CS2 events.",
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontFamily: 'StratumNo2',
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Footer
          const SliverToBoxAdapter(
            child: Footer(),
          ),
        ],
      ),
    );
  }
}
