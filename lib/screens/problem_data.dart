import '../widgets/horizontal_subject_list.dart';

class ProblemData {
  final String id;
  final String problemImage;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final bool isFavorite;
  final bool isSolved;
  final String? solveTime;
  final String subject; // 새로 추가된 필드

  ProblemData({
    required this.id,
    required this.problemImage,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    this.isFavorite = false,
    this.isSolved = false,
    this.solveTime,
    required this.subject, // 생성자에 subject 추가
  });
}

// Subject와 ProblemList의 매핑 구조
Map<String, List<String>> subjectToProblemIds = {
  'subject1': ['problem1', 'problem2', 'problem3'],
  'subject2': ['problem4', 'problem5', 'problem6'],
  'subject3': ['problem7', 'problem8', 'problem9'],
};

// 모든 문제 데이터 (예시)
Map<String, ProblemData> allProblems = {
  'problem1': ProblemData(
    id: 'problem1',
    problemImage: "problem_image_url_1",
    title: "추리논증 단순주장+논쟁형 기타",
    description: "Medium",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b",
    tags: ["추리논증", "단순주장", "논쟁형"],
    subject: 'subject1',
  ),
  'problem2': ProblemData(
    id: 'problem2',
    problemImage: "problem_image_url_2",
    title: "Linked List Cycle",
    description: "Easy",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b",
    tags: ["자료구조", "연결리스트"],
    subject: 'subject1',
  ),
  // ... 다른 문제들 추가
};

// 모든 과목 데이터 (예시)
final List<SubjectData> myProblems = [
  SubjectData(
    '1',
    "Array Manipulation",
    "Easy",
    "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0",
    ["자료구조", "배열"],
  ),
  SubjectData(
    '1',
    "Graph Theory",
    "Hard",
    "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%85%BC%EC%9F%81%ED%98%95.png?alt=media&token=e88eb6a5-d88b-46d9-93a5-21feb5fcc124",
    ["알고리즘", "그래프"],
  ),
  SubjectData(
    '1',
    "String Matching",
    "Medium",
    "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EC%B0%A8%ED%8A%B8%ED%98%95.png?alt=media&token=dcb2f00f-c669-4f4d-8e1b-e2d2dea860b4",
    ["알고리즘", "문자열"],
  ),
];

// 최근 풀어본 문제 목록 (예시)
List<String> recentlyAttemptedProblemIds = ['problem1', 'problem2'];

// 좋아요한 문제 목록 (예시)
List<String> favoriteProblemIds = ['problem2'];
