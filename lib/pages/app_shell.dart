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
  @override
  Widget build(BuildContext context) => widget.child;
}
