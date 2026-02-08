class Cell {
  String image;
  String title;
  String answer;
  bool isCorrect;
  bool isWrong;
  bool isAnswered;
  String criteria;

  Cell({
    required this.title,
    required this.image,
    required this.criteria,
    this.isCorrect = false,
    this.isWrong = false,
    this.isAnswered = false,
    this.answer = '',
  });
}
