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
  'subject1': [
    'problem1-1',
    'problem1-2',
    'problem1-3',
    'problem1-4',
    'problem1-5',
  ],
  'subject2': [
    'problem1-1',
    'problem1-2',
    'problem1-3',
    'problem1-4',
    'problem1-5',
  ],
  'subject3': [
    'problem1-1',
    'problem1-2',
    'problem1-3',
    'problem1-4',
    'problem1-5',
  ],
};

// 모든 문제 데이터 (예시)
Map<String, ProblemData> allProblems = {
  'problem1': ProblemData(
    id: 'problem1',
    problemImage:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03",
    title: "4번",
    description: "추리논증 단순주장+논쟁형 기타",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b",
    tags: ["추리논증", "단순주장", "논쟁형"],
    subject: 'subject0',
  ),
  'problem2': ProblemData(
    id: 'problem1',
    problemImage:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03",
    title: "3번",
    description: "추리논증 단순주장+논쟁형 기타",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b",
    tags: ["추리논증", "단순주장", "논쟁형"],
    subject: 'subject0',
  ),
  'problem3': ProblemData(
    id: 'problem1',
    problemImage:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03",
    title: "2번",
    description: "추리논증 단순주장+논쟁형 기타",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b",
    tags: ["추리논증", "단순주장", "논쟁형"],
    subject: 'subject0',
  ),
  'problem1-1': ProblemData(
    id: 'problem1-1',
    problemImage:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03",
    title: "1번",
    description: "추리논증 다이어그램형 문제꾸러미 1",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0",
    tags: ["추리논증", "다이어그램형"],
    subject: 'subject1',
  ),
  'problem1-2': ProblemData(
    id: 'problem1-2',
    problemImage:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03",
    title: "2번",
    description: "추리논증 다이어그램형 문제꾸러미 1",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0",
    tags: ["추리논증", "다이어그램형"],
    subject: 'subject1',
  ),
  'problem1-3': ProblemData(
    id: 'problem1-3',
    problemImage:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03",
    title: "3번",
    description: "추리논증 다이어그램형 문제꾸러미 1",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0",
    tags: ["추리논증", "다이어그램형"],
    subject: 'subject1',
  ),
  'problem1-4': ProblemData(
    id: 'problem1-4',
    problemImage:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03",
    title: "4번",
    description: "추리논증 다이어그램형 문제꾸러미 1",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0",
    tags: ["추리논증", "다이어그램형"],
    subject: 'subject1',
  ),
  'problem1-5': ProblemData(
    id: 'problem1-5',
    problemImage:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03",
    title: "5번",
    description: "추리논증 다이어그램형 문제꾸러미 1",
    imageUrl:
        "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0",
    tags: ["추리논증", "다이어그램형"],
    subject: 'subject1',
  ),
};

// 모든 과목 데이터 (예시)
final List<SubjectData> myProblems = [
  SubjectData(
    'subject1',
    "추리논증 다이어그램형",
    "추리논증 다이어그램형 문제꾸러미 1",
    "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0",
    ["추리논증", "다이어그램형"],
  ),
  SubjectData(
    'subject2',
    "추리논증 논쟁형",
    "추리논증 논쟁형 복합형 문제꾸러미",
    "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%85%BC%EC%9F%81%ED%98%95.png?alt=media&token=e88eb6a5-d88b-46d9-93a5-21feb5fcc124",
    ["추리논증", "논쟁형", "복합형"],
  ),
  SubjectData(
    'subject3',
    "추리논증 결과분석형",
    "추리논증 결과분석형 자연과학 문제꾸러미",
    "https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EC%B0%A8%ED%8A%B8%ED%98%95.png?alt=media&token=dcb2f00f-c669-4f4d-8e1b-e2d2dea860b4",
    ["추리논증", "결과분석형", "자연과학"],
  ),
];

// 최근 풀어본 문제 목록 (예시)
List<String> recentlyAttemptedProblemIds = ['problem1', 'problem2', 'problem3'];

// 좋아요한 문제 목록 (예시)
List<String> favoriteProblemIds = ['problem2'];
