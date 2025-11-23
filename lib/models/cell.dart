class Cell {
  final String image;
  final String title;
  bool isCompleted;
  bool triggerWrong = false;

  Cell({required this.title, required this.image, this.isCompleted = false});
}
