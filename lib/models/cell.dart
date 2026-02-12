class Cell {
  String imageUrl;
  String title;
  String answer;
  bool isLoadingAnswer;
  bool isCorrect;
  bool isWrong;
  bool isAnswered;
  String criteria;

  Cell({
    required this.title,
    required this.imageUrl,
    required this.criteria,
    this.isCorrect = false,
    this.isWrong = false,
    this.isAnswered = false,
    this.answer = '',
    this.isLoadingAnswer = false,
  });
}
