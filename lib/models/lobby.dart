import 'package:equatable/equatable.dart';
import 'lobby_player.dart';

enum LobbyGameState { waiting, ready, inProgress, finished }

class Lobby extends Equatable {
  final String code;
  final String ownerId;
  final List<LobbyPlayer> players;
  final LobbyGameState gameState;
  final DateTime createdAt;
  final int maxPlayers;

  const Lobby({
    required this.code,
    required this.ownerId,
    required this.players,
    this.gameState = LobbyGameState.waiting,
    required this.createdAt,
    this.maxPlayers = 8,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    final playersJson = json['players'] as List<dynamic>? ?? [];
    final players = playersJson
        .map((p) => LobbyPlayer.fromJson(p as Map<String, dynamic>))
        .toList();

    final gameStateStr = json['gameState'] as String? ?? json['game_state'] as String? ?? 'waiting';
    final gameState = LobbyGameState.values.firstWhere(
      (e) => e.name == gameStateStr,
      orElse: () => LobbyGameState.waiting,
    );

    return Lobby(
      code: json['code'] as String,
      ownerId: json['ownerId'] as String? ?? json['owner_id'] as String? ?? '',
      players: players,
      gameState: gameState,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      maxPlayers: json['maxPlayers'] as int? ?? json['max_players'] as int? ?? 8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'ownerId': ownerId,
      'players': players.map((p) => p.toJson()).toList(),
      'gameState': gameState.name,
      'createdAt': createdAt.toIso8601String(),
      'maxPlayers': maxPlayers,
    };
  }

  Lobby copyWith({
    String? code,
    String? ownerId,
    List<LobbyPlayer>? players,
    LobbyGameState? gameState,
    DateTime? createdAt,
    int? maxPlayers,
  }) {
    return Lobby(
      code: code ?? this.code,
      ownerId: ownerId ?? this.ownerId,
      players: players ?? this.players,
      gameState: gameState ?? this.gameState,
      createdAt: createdAt ?? this.createdAt,
      maxPlayers: maxPlayers ?? this.maxPlayers,
    );
  }

  LobbyPlayer? getOwner() {
    try {
      return players.firstWhere((p) => p.id == ownerId);
    } catch (e) {
      return null;
    }
  }

  int get playerCount => players.length;
  bool get isFull => playerCount >= maxPlayers;
  bool get allReady => players.isNotEmpty && players.every((p) => p.ready);

  @override
  List<Object?> get props => [code, ownerId, players, gameState, createdAt, maxPlayers];
}
