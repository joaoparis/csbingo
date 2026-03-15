import 'package:csbingo/pages/lobby_page.dart';
import 'package:csbingo/widgets/cs2_button.dart';
import 'package:csbingo/services/socket_service.dart';
import 'package:csbingo/bloc/lobby_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FFAPage extends StatefulWidget {
  const FFAPage({super.key});

  @override
  State<FFAPage> createState() => _FFAPageState();
}

class _FFAPageState extends State<FFAPage> {
  late TextEditingController _usernameController;
  late TextEditingController _joinCodeController;
  bool _showJoinForm = false;

  @override
  void initState() {
    super.initState();
    // Use singleton socket service

    _usernameController = TextEditingController();
    _joinCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _joinCodeController.dispose();
    // Don't dispose BLoC here - it will be passed to LobbyPage
    super.dispose();
  }

  bool get _isUsernameValid => _usernameController.text.trim().isNotEmpty;
  bool get _isJoinCodeValid => _joinCodeController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocListener<LobbyBloc, LobbyState>(
        listener: (context, state) {
          if (state is LobbyLoaded) {
            // Navigate to lobby page with the lobby code and keep the BLoC
            context.go('/ffa/lobby/${state.lobby.code}');
          } else if (state is LobbyError) {
            // Show error dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Username input field
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        hintStyle: theme.inputDecorationTheme.hintStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: theme.textTheme.bodyMedium,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Create or Join toggle
                  if (!_showJoinForm)
                    BlocBuilder<LobbyBloc, LobbyState>(
                      builder: (context, state) {
                        final isLoading = state is LobbyLoading;

                        return Column(
                          children: [
                            CS2Button(
                              text: isLoading ? "Creating..." : "Create Lobby",
                              size: 60,
                              onPressed: _isUsernameValid && !isLoading
                                  ? () => context
                                      .read<LobbyBloc>()
                                      .add(CreateLobbyRequested(
                                        _usernameController.text.trim(),
                                      ))
                                  : () {},
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showJoinForm = true;
                                });
                              },
                              child: Text(
                                'Or join an existing lobby',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else
                    // Join form
                    BlocBuilder<LobbyBloc, LobbyState>(
                      builder: (context, state) {
                        final isLoading = state is LobbyLoading;

                        return Column(
                          children: [
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _joinCodeController,
                                decoration: InputDecoration(
                                  hintText: 'Enter lobby code',
                                  hintStyle:
                                      theme.inputDecorationTheme.hintStyle,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.white30,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: theme.textTheme.bodyMedium,
                                textCapitalization:
                                    TextCapitalization.characters,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            CS2Button(
                              text: isLoading ? "Joining..." : "Join Lobby",
                              size: 60,
                              onPressed: _isUsernameValid &&
                                      _isJoinCodeValid &&
                                      !isLoading
                                  ? () => context
                                      .read<LobbyBloc>()
                                      .add(JoinLobbyRequested(
                                        _joinCodeController.text.trim(),
                                        _usernameController.text.trim(),
                                      ))
                                  : () {},
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showJoinForm = false;
                                  _joinCodeController.clear();
                                });
                              },
                              child: Text(
                                'Create a new lobby instead',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
