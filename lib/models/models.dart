class ProblemSet {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final String subjectId;
  final int price;
  final int totalProblems;

  ProblemSet({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.subjectId,
    required this.price,
    required this.totalProblems,
  });
}

class Problem {
  final String id;
  final String title;
  final String description;
  final String problemImage;
  final String imageUrl;
  final List<String> tags;
  final String problemSetId;
  final String correctAnswer;

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.problemImage,
    required this.imageUrl,
    required this.tags,
    required this.problemSetId,
    required this.correctAnswer,
  });
}
