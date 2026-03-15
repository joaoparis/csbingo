import 'package:csbingo/bloc/lobby_bloc.dart';
import 'package:csbingo/models/lobby.dart';
import 'package:csbingo/services/socket_service.dart';
import 'package:csbingo/services/user_service.dart';
import 'package:csbingo/widgets/cs2_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocListener<LobbyBloc, LobbyState>(
        listener: (context, state) {
          if (state is LobbyError) {
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
            child: BlocBuilder<LobbyBloc, LobbyState>(
              builder: (context, state) {
                if (state is LobbyLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(
                          'Joining lobby...',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                if (state is LobbyError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CS2Button(
                          text: 'Back',
                          size: 50,
                          onPressed: () => context.go('/ffa'),
                        ),
                      ],
                    ),
                  );
                }

                Lobby? lobby;
                if (state is LobbyLoaded) {
                  lobby = state.lobby;
                } else if (state is PlayerListUpdated) {
                  lobby = state.lobby;
                }

                if (lobby == null) {
                  return Center(
                    child: Text(
                      'No lobby data',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lobby code section
                      GestureDetector(
                        onTap: () => _copyCodeToClipboard(lobby!.code, context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'LOBBY CODE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white54,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                lobby.code,
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontFamily: 'StratumNo2',
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '(Click to copy)',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Players count
                      Text(
                        'Players (${lobby.playerCount})',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white54,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Player list
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: lobby.isEmpty
                                ? [
                                    Center(
                                      child: Text(
                                        'No players yet',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.white38,
                                        ),
                                      ),
                                    ),
                                  ]
                                : lobby.users.map((player) {
                                    final isOwner = player.id == lobby!.owner;
                                    final isYou = player.id ==
                                        UserService.getInstance().id;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Player name and owner badge
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    player.nickname,
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: Colors.white,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isOwner)
                                                  _buildOwnerBadge(theme),
                                                if (isYou)
                                                  _buildYouBadge(theme),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Container _buildOwnerBadge(ThemeData theme) => Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          border: Border.all(
            color: Colors.orange,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'OWNER',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Container _buildYouBadge(ThemeData theme) => Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          border: Border.all(
            color: Colors.blue,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'YOU',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.blue,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  void _copyCodeToClipboard(String code, BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lobby code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
