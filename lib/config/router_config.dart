import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:csbingo/pages/app_shell.dart';
import 'package:csbingo/pages/landing_page.dart';
import 'package:csbingo/pages/game_page.dart';

// Router configuration
final GoRouter createRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(
        routerState: state,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: '/game',
          builder: (context, state) {
            return GamePage(
              themeMode: ThemeMode.dark, // TODO: Pass theme mode from parent
            );
          },
        ),
      ],
    ),
  ],
);
