import 'package:csbingo/csbingo.dart';
import 'package:equatable/equatable.dart';
import 'lobby_player.dart';

class Lobby extends Equatable {
  final String code;
  final String owner;
  final List<LobbyPlayer> users;
  final GameState state;

  const Lobby({
    required this.code,
    required this.owner,
    required this.users,
    required this.state,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    final usersJson = json['users'] as List<dynamic>? ?? [];
    final users = usersJson
        .map((u) => LobbyPlayer.fromJson(u as Map<String, dynamic>))
        .toList();

    return Lobby(
      code: json['lobbyCode'] as String? ?? json['code'] as String? ?? '',
      owner: json['owner'] as String? ?? '',
      users: users,
      state: GameState.values.firstWhere(
        (e) => e.toString() == 'GameState.${json['state']}',
        orElse: () => GameState.inactive,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lobbyCode': code,
      'owner': owner,
      'users': users.map((u) => u.toJson()).toList(),
    };
  }

  Lobby copyWith({
    String? code,
    String? owner,
    List<LobbyPlayer>? users,
    GameState? state,
  }) {
    return Lobby(
      code: code ?? this.code,
      owner: owner ?? this.owner,
      users: users ?? this.users,
      state: state ?? this.state,
    );
  }

  LobbyPlayer? getOwner() {
    try {
      return users.firstWhere((u) => u.id == owner);
    } catch (e) {
      return null;
    }
  }

  int get playerCount => users.length;
  bool get isEmpty => users.isEmpty;

  @override
  List<Object?> get props => [code, owner, users];
}
