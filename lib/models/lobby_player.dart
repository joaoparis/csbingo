import 'package:equatable/equatable.dart';

class LobbyPlayer extends Equatable {
  final String id;
  final String nickname;

  const LobbyPlayer({
    required this.id,
    required this.nickname,
  });

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      id: json['id'] as String,
      nickname: json['nickname'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
    };
  }

  LobbyPlayer copyWith({
    String? id,
    String? nickname,
  }) {
    return LobbyPlayer(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
    );
  }

  @override
  List<Object?> get props => [id, nickname];
}
