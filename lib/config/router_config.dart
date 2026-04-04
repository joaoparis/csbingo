import 'package:csbingo/pages/ffa_page.dart';
import 'package:csbingo/pages/lobby_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:csbingo/pages/app_shell.dart';
import 'package:csbingo/pages/landing_page.dart';
import 'package:csbingo/pages/game_page.dart';

// Router configuration with path-based routing for web
GoRouter createRouter() {
  // Use path routing instead of hash routing
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          routerState: state,
          child: child,
        ),
        routes: [
          GoRoute(
            // path: '/ffa',
            path: '/',
            builder: (context, state) => const FFAPage(
              key: Key("ffa_page_key"),
            ),
          ),
          GoRoute(
            path: '/ffa/lobby/:code',
            builder: (context, state) => const LobbyPage(
              key: Key("lobby_page_key"),
            ),
          ),
          GoRoute(
            path: '/ffa/lobby/:code/game',
            builder: (context, state) => const GamePage(
              key: Key("ffa_game_page_key"),
              themeMode: ThemeMode.dark,
            ),
          ),
          // GoRoute(
          //   path: '/',
          //   builder: (context, state) => const LandingPage(
          //     key: Key("landing_page_key"),
          //   ),
          // ),
          // GoRoute(
          //   path: '/game',
          //   builder: (context, state) {
          //     return GamePage(
          //       themeMode: ThemeMode.dark, // TODO: Pass theme mode from parent
          //     );
          //   },
          // ),
        ],
      ),
    ],
  );
}
