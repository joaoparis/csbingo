import 'package:csbingo/bloc/lobby_bloc.dart';
import 'package:csbingo/csbingo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameWidget extends StatelessWidget {
  const GameWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LobbyBloc, LobbyState>(builder: (context, state) {
      if (state is LobbyGameLoading) {
        return Center(child: Text('Game is starting in ${state.countdown}...'));
      } else if (state is LobbyRoundStarted) {
        var game = DailyGame();
        game.info = state.gameInfo;
        GameManager gameManager = GameManager(
          game: game,
          orchestratorState: OrchestratorState.playing,
        );
        print(
            "GameWidget: game info loaded with state=${gameManager.game.info.state}");
        return Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BingoWidget(
              gameManager: gameManager,
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    });
  }
}
