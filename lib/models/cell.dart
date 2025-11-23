class Cell {
  String image;
  String title;
  bool isCompleted;
  bool triggerWrong = false;

  Cell({
    required this.title,
    required this.image,
    this.isCompleted = false,
  });
}
