class Cell {
  String image;
  String title;
  bool isCompleted;
  bool isWrong;

  Cell({
    required this.title,
    required this.image,
    this.isCompleted = false,
    this.isWrong = false,
  });
}
