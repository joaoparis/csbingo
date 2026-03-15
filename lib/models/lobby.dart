import 'package:equatable/equatable.dart';
import 'lobby_player.dart';

class Lobby extends Equatable {
  final String code;
  final String owner;
  final List<LobbyPlayer> users;

  const Lobby({
    required this.code,
    required this.owner,
    required this.users,
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
  }) {
    return Lobby(
      code: code ?? this.code,
      owner: owner ?? this.owner,
      users: users ?? this.users,
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
