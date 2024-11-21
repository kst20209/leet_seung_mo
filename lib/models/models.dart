class ProblemSet {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final String subjectId;
  final int price;
  final int totalProblems;
  final String category; // 추리, 논증
  final String subCategory; // 지문분석형, 논쟁형 등
  final String field; // 규범, 인문, 사회, 과학

  ProblemSet({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.subjectId,
    required this.price,
    required this.totalProblems,
    required this.category,
    required this.subCategory,
    required this.field,
  });
}

class Problem {
  final String id;
  final String title;
  final String description;
  final String problemImage;
  final String solutionImage;
  final String imageUrl;
  final List<String> tags;
  final String problemSetId;
  final String correctAnswer;

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.problemImage,
    required this.solutionImage,
    required this.imageUrl,
    required this.tags,
    required this.problemSetId,
    required this.correctAnswer,
  });
}
