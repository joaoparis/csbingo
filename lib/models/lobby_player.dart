import 'package:equatable/equatable.dart';

class LobbyPlayer extends Equatable {
  final String id;
  final String username;
  final bool ready;
  final bool isOwner;

  const LobbyPlayer({
    required this.id,
    required this.username,
    this.ready = false,
    this.isOwner = false,
  });

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Unknown',
      ready: json['ready'] as bool? ?? false,
      isOwner: json['isOwner'] as bool? ?? json['is_owner'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'ready': ready,
      'isOwner': isOwner,
    };
  }

  LobbyPlayer copyWith({
    String? id,
    String? username,
    bool? ready,
    bool? isOwner,
  }) {
    return LobbyPlayer(
      id: id ?? this.id,
      username: username ?? this.username,
      ready: ready ?? this.ready,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  @override
  List<Object?> get props => [id, username, ready, isOwner];
}
