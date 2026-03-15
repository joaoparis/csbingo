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
}
