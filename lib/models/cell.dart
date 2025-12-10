class Cell {
  String image;
  String title;
  bool isCompleted;
  bool isWrong;
  String criteria;

  Cell({
    required this.title,
    required this.image,
    required this.criteria,
    this.isCompleted = false,
    this.isWrong = false,
  });
}
