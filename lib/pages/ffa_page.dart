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
  late LobbyBloc _lobbyBloc;

  @override
  void initState() {
    super.initState();
    // Use singleton socket service
    final socketService = SocketService.getInstance();
    _lobbyBloc = LobbyBloc(socketService: socketService);
  }

  @override
  void dispose() {
    _lobbyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return BlocProvider<LobbyBloc>(
      create: (context) => _lobbyBloc,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Listen for state changes and handle navigation
                BlocListener<LobbyBloc, LobbyState>(
                  listener: (context, state) {
                    if (state is LobbyLoaded) {
                      // Navigate to lobby page with the lobby code
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
                  child: BlocBuilder<LobbyBloc, LobbyState>(
                    builder: (context, state) {
                      final isLoading = state is LobbyLoading;

                      return CS2Button(
                        text: isLoading ? "Creating..." : "Create Lobby",
                        size: 60,
                        onPressed: isLoading
                            ? () {}
                            : () => context
                                .read<LobbyBloc>()
                                .add(const CreateLobbyRequested()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
