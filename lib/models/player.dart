class Player {
  String name;
  String nationality;
  String team;
  String image;

  Player({
    required this.name,
    required this.nationality,
    required this.team,
    required this.image,
  });

  factory Player.emptyPlayer() {
    return Player(
      name: "",
      nationality: "",
      team: "",
      image: "assets/images/cell_placeholder.png",
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] ?? '',
      nationality: json['nationality'] ?? '',
      team: json['team'] ?? '',
      image: json['image'] ?? 'assets/images/cell_placeholder.png',
    );
  }
}
