import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:csbingo/models/lobby.dart';
import 'package:csbingo/models/lobby_player.dart';
import 'package:csbingo/services/socket_service.dart';

// Events
abstract class LobbyEvent extends Equatable {
  const LobbyEvent();

  @override
  List<Object?> get props => [];
}

class CreateLobbyRequested extends LobbyEvent {
  const CreateLobbyRequested();
}

class JoinLobbyRequested extends LobbyEvent {
  final String code;
  const JoinLobbyRequested(this.code);

  @override
  List<Object?> get props => [code];
}

class LobbyUpdated extends LobbyEvent {
  final Lobby lobby;
  const LobbyUpdated(this.lobby);

  @override
  List<Object?> get props => [lobby];
}

class PlayerReadyToggled extends LobbyEvent {
  final bool ready;
  const PlayerReadyToggled(this.ready);

  @override
  List<Object?> get props => [ready];
}

class LobbyCreated extends LobbyEvent {
  final String lobbyCode;
  const LobbyCreated(this.lobbyCode);

  @override
  List<Object?> get props => [lobbyCode];
}

// States
abstract class LobbyState extends Equatable {
  const LobbyState();

  @override
  List<Object?> get props => [];
}

class LobbyInitial extends LobbyState {
  const LobbyInitial();
}

class LobbyLoading extends LobbyState {
  const LobbyLoading();
}

class LobbyLoaded extends LobbyState {
  final Lobby lobby;
  const LobbyLoaded(this.lobby);

  @override
  List<Object?> get props => [lobby];
}

class LobbyCreatedSuccess extends LobbyState {
  final String lobbyCode;
  const LobbyCreatedSuccess(this.lobbyCode);

  @override
  List<Object?> get props => [lobbyCode];
}

class PlayerListUpdated extends LobbyState {
  final Lobby lobby;
  const PlayerListUpdated(this.lobby);

  @override
  List<Object?> get props => [lobby];
}

class LobbyError extends LobbyState {
  final String message;
  const LobbyError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  final SocketService socketService;
  Lobby? _currentLobby;

  LobbyBloc({required this.socketService}) : super(const LobbyInitial()) {
    on<CreateLobbyRequested>(_onCreateLobbyRequested);
    on<JoinLobbyRequested>(_onJoinLobbyRequested);
    on<LobbyUpdated>(_onLobbyUpdated);
    on<PlayerReadyToggled>(_onPlayerReadyToggled);
  }

  Future<void> _onCreateLobbyRequested(
    CreateLobbyRequested event,
    Emitter<LobbyState> emit,
  ) async {
    emit(const LobbyLoading());

    try {
      // Ensure socket is connected
      if (!socketService.isConnected) {
        await socketService.connect();
      }

      // Send join_lobby request with create flag
      final response = await socketService.request(
        'join_lobby',
        data: {'create': true},
      );
      print('Create lobby response: $response');

      if (response is Map && response.containsKey('code')) {
        final lobby = Lobby.fromJson(response as Map<String, dynamic>);
        _currentLobby = lobby;
        emit(LobbyLoaded(lobby));
      } else {
        emit(const LobbyError('Invalid response from server'));
      }
    } on TimeoutException {
      emit(const LobbyError('Request timed out. Please try again.'));
    } catch (e) {
      emit(LobbyError('Failed to create lobby: ${e.toString()}'));
    }
  }

  Future<void> _onJoinLobbyRequested(
    JoinLobbyRequested event,
    Emitter<LobbyState> emit,
  ) async {
    emit(const LobbyLoading());

    try {
      // Ensure socket is connected
      if (!socketService.isConnected) {
        await socketService.connect();
      }

      // Send join_lobby request with code
      final response = await socketService.request(
        'join_lobby',
        data: {'code': event.code},
      );
      print('Join lobby response: $response');

      if (response is Map && response.containsKey('code')) {
        final lobby = Lobby.fromJson(response as Map<String, dynamic>);
        _currentLobby = lobby;
        emit(LobbyLoaded(lobby));
      } else {
        emit(const LobbyError('Failed to join lobby'));
      }
    } on TimeoutException {
      emit(const LobbyError('Request timed out. Please try again.'));
    } catch (e) {
      emit(LobbyError('Failed to join lobby: ${e.toString()}'));
    }
  }

  Future<void> _onLobbyUpdated(
    LobbyUpdated event,
    Emitter<LobbyState> emit,
  ) async {
    _currentLobby = event.lobby;
    emit(PlayerListUpdated(event.lobby));
  }

  Future<void> _onPlayerReadyToggled(
    PlayerReadyToggled event,
    Emitter<LobbyState> emit,
  ) async {
    if (_currentLobby == null) return;

    try {
      // Send ready status update to socket
      socketService.send('player_ready', data: {'ready': event.ready});
    } catch (e) {
      emit(LobbyError('Failed to update ready status: ${e.toString()}'));
    }
  }
}
