import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:csbingo/models/lobby.dart';
import 'package:csbingo/models/lobby_player.dart';
import 'package:csbingo/services/socket_service.dart';
import 'package:csbingo/services/user_service.dart';

// Events
abstract class LobbyEvent extends Equatable {
  const LobbyEvent();

  @override
  List<Object?> get props => [];
}

class CreateLobbyRequested extends LobbyEvent {
  final String username;
  const CreateLobbyRequested(this.username);

  @override
  List<Object?> get props => [username];
}

class JoinLobbyRequested extends LobbyEvent {
  final String code;
  final String username;
  const JoinLobbyRequested(this.code, this.username);

  @override
  List<Object?> get props => [code, username];
}

class LobbyUpdated extends LobbyEvent {
  final Lobby lobby;
  const LobbyUpdated(this.lobby);

  @override
  List<Object?> get props => [lobby];
}

class LeaveLobbyRequested extends LobbyEvent {
  const LeaveLobbyRequested();
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
  bool _isInitialResponse = true;

  LobbyBloc({required this.socketService}) : super(const LobbyInitial()) {
    on<CreateLobbyRequested>(_onCreateLobbyRequested);
    on<JoinLobbyRequested>(_onJoinLobbyRequested);
    on<LobbyUpdated>(_onLobbyUpdated);
    on<LeaveLobbyRequested>(_onLeaveLobbyRequested);
    on<PlayerReadyToggled>(_onPlayerReadyToggled);

    // Register listener for lobby_update broadcasts
    socketService.onBroadcast('lobby_update', _handleLobbyUpdate);
  }

  void _handleLobbyUpdate(Map<String, dynamic> message) {
    debugPrint('Received lobby update: $message');
    if (message['type'] == 'lobby_update') {
      final lobby = Lobby.fromJson(message);
      add(LobbyUpdated(lobby));
    }
  }

  Future<void> _onCreateLobbyRequested(
    CreateLobbyRequested event,
    Emitter<LobbyState> emit,
  ) async {
    _isInitialResponse = true;
    emit(const LobbyLoading());

    try {
      // Ensure socket is connected
      if (!socketService.isConnected) {
        await socketService.connect();
      }

      final userService = UserService.getInstance();
      userService.setNickname(event.username);

      print(
          'Creating lobby for user: ${userService.nickname} (ID: ${userService.id})');

      // Send join message - fire and forget, broadcast listener will handle response
      socketService.request(
        'join',
        data: {
          'type': 'join',
          'id': userService.id,
          'nickname': event.username,
          'lobbyCode': '', // Empty code = create new
        },
      );

      // State will be updated via _handleLobbyUpdate callback when server broadcasts lobby_update
    } catch (e) {
      emit(LobbyError('Failed to create lobby: ${e.toString()}'));
    }
  }

  Future<void> _onJoinLobbyRequested(
    JoinLobbyRequested event,
    Emitter<LobbyState> emit,
  ) async {
    _isInitialResponse = true;
    emit(const LobbyLoading());

    try {
      // Ensure socket is connected
      if (!socketService.isConnected) {
        await socketService.connect();
      }

      final userService = UserService.getInstance();
      userService.setNickname(event.username);

      print('Joining lobby with code: ${event.code} as ${event.username}');

      // Send join message - fire and forget, broadcast listener will handle response
      socketService.request(
        'join',
        data: {
          'type': 'join',
          'id': userService.id,
          'nickname': event.username,
          'lobbyCode': event.code,
        },
      );

      // State will be updated via _handleLobbyUpdate callback when server broadcasts lobby_update
    } catch (e) {
      emit(LobbyError('Failed to join lobby: ${e.toString()}'));
    }
  }

  Future<void> _onLobbyUpdated(
    LobbyUpdated event,
    Emitter<LobbyState> emit,
  ) async {
    _currentLobby = event.lobby;
    
    if (_isInitialResponse) {
      // First response: emit LobbyLoaded to trigger navigation
      _isInitialResponse = false;
      emit(LobbyLoaded(event.lobby));
    } else {
      // Subsequent updates: emit PlayerListUpdated for UI refresh
      emit(PlayerListUpdated(event.lobby));
    }
  }

  Future<void> _onLeaveLobbyRequested(
    LeaveLobbyRequested event,
    Emitter<LobbyState> emit,
  ) async {
    if (_currentLobby == null) return;

    try {
      final userService = UserService.getInstance();
      // Send leave message to socket (fire-and-forget)
      socketService.request(
        'leave',
        data: {
          'type': 'leave',
          'id': userService.id,
          'lobbyCode': _currentLobby!.code,
        },
      );
      _currentLobby = null;
      _isInitialResponse = true;
    } catch (e) {
      print('Error leaving lobby: $e');
    }
  }

  Future<void> _onPlayerReadyToggled(
    PlayerReadyToggled event,
    Emitter<LobbyState> emit,
  ) async {
    if (_currentLobby == null) return;

    try {
      // Send ready status update to socket (fire-and-forget)
      socketService.request('player_ready', data: {'ready': event.ready});
    } catch (e) {
      emit(LobbyError('Failed to update ready status: ${e.toString()}'));
    }
  }
}
