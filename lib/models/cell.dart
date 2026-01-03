class Cell {
  String image;
  String title;
  String answer;
  bool isCompleted;
  bool isWrong;
  String criteria;

  Cell({
    required this.title,
    required this.image,
    required this.criteria,
    this.isCompleted = false,
    this.isWrong = false,
    this.answer = '',
  });
}
