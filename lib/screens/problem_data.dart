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

// Sample data for ProblemSets
List<ProblemSet> problemSets = [
  ProblemSet(
    id: 'set1',
    title: '추리논증 다이어그램형',
    description: '추리논증 다이어그램형 문제꾸러미 1',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0',
    tags: ['추리논증', '다이어그램형'],
    subjectId: 'subject1',
    price: 500,
    totalProblems: 5,
  ),
  ProblemSet(
    id: 'set2',
    title: '추리논증 논쟁형',
    description: '추리논증 논쟁형 복합형 문제꾸러미',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%85%BC%EC%9F%81%ED%98%95.png?alt=media&token=e88eb6a5-d88b-46d9-93a5-21feb5fcc124',
    tags: ['추리논증', '논쟁형', '복합형'],
    subjectId: 'subject1',
    price: 500,
    totalProblems: 5,
  ),
  ProblemSet(
    id: 'set3',
    title: '추리논증 결과분석형',
    description: '추리논증 결과분석형 자연과학 문제꾸러미',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EC%B0%A8%ED%8A%B8%ED%98%95.png?alt=media&token=dcb2f00f-c669-4f4d-8e1b-e2d2dea860b4',
    tags: ['추리논증', '결과분석형', '자연과학'],
    subjectId: 'subject1',
    price: 500,
    totalProblems: 5,
  ),
];

// Sample data for Problems
Map<String, Problem> problems = {
  'problem1': Problem(
    id: 'problem1',
    title: '4번',
    description: '추리논증 단순주장+논쟁형 기타',
    problemImage:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b',
    tags: ['추리논증', '단순주장', '논쟁형'],
    problemSetId: 'set1',
    correctAnswer: 'A',
  ),
  'problem2': Problem(
    id: 'problem2',
    title: '3번',
    description: '추리논증 단순주장+논쟁형 기타',
    problemImage:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b',
    tags: ['추리논증', '단순주장', '논쟁형'],
    problemSetId: 'set1',
    correctAnswer: 'B',
  ),
  'problem3': Problem(
    id: 'problem3',
    title: '2번',
    description: '추리논증 단순주장+논쟁형 기타',
    problemImage:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A8%EC%88%9C%EC%A3%BC%EC%9E%A5.png?alt=media&token=5662465b-8be8-44a9-bb5e-fbf5a5aee41b',
    tags: ['추리논증', '단순주장', '논쟁형'],
    problemSetId: 'set1',
    correctAnswer: 'C',
  ),
};

List<Problem> freeProblemToday = [
  Problem(
    id: 'free1',
    title: '추리논증',
    description: '다이어그램형',
    problemImage:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%8B%A4%EC%9D%B4%EC%96%B4%EA%B7%B8%EB%9E%A8%ED%98%95.png?alt=media&token=2e1290bf-f6c9-403c-bb70-ac270718e6e0',
    tags: ['추리논증', '다이어그램형'],
    problemSetId: 'freeSet',
    correctAnswer: 'A',
  ),
  Problem(
    id: 'free2',
    title: '추리논증',
    description: '논쟁형',
    problemImage:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%85%BC%EC%9F%81%ED%98%95.png?alt=media&token=e88eb6a5-d88b-46d9-93a5-21feb5fcc124',
    tags: ['추리논증', '논쟁형'],
    problemSetId: 'freeSet',
    correctAnswer: 'B',
  ),
  Problem(
    id: 'free3',
    title: '언어이해',
    description: '자료분석형',
    problemImage:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/problem_sample.png?alt=media&token=b2e32d6c-e3f2-42ae-a41a-c0e85e957c03',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EC%B0%A8%ED%8A%B8%ED%98%95.png?alt=media&token=dcb2f00f-c669-4f4d-8e1b-e2d2dea860b4',
    tags: ['언어이해', '자료분석형'],
    problemSetId: 'freeSet',
    correctAnswer: 'C',
  ),
];

// 추천 문제꾸러미 추가
List<ProblemSet> recommendedProblemSets = [
  ProblemSet(
    id: 'rec1',
    title: '추리논증 결과분석형',
    description: '자연과학 문제꾸러미',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/Thumbnail1.png?alt=media&token=03a39d6d-35dd-495f-8533-6e5171fed942',
    tags: ['추리논증', '결과분석형', '자연과학'],
    subjectId: 'subject1',
    price: 500,
    totalProblems: 10,
  ),
  ProblemSet(
    id: 'rec2',
    title: '추리논증 규정해석형',
    description: '특이유형 문제꾸러미',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C1.png?alt=media&token=fa06bb0d-4b2e-44be-a27f-a061e13c475d',
    tags: ['추리논증', '규정해석형', '특이유형'],
    subjectId: 'subject1',
    price: 500,
    totalProblems: 10,
  ),
  ProblemSet(
    id: 'rec3',
    title: '추리논증 퀴즈형',
    description: '논리퀴즈 복합형',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C2.png?alt=media&token=ad8f8f39-d3df-4193-912d-b6a1e646e431',
    tags: ['추리논증', '퀴즈형', '논리퀴즈'],
    subjectId: 'subject1',
    price: 500,
    totalProblems: 10,
  ),
  ProblemSet(
    id: 'rec4',
    title: '추리논증 단순주장+논쟁형',
    description: '순수학문 문제꾸러미',
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/leet-exam.appspot.com/o/%EB%AC%B8%EC%A0%9C3.png?alt=media&token=ad1f8072-9b30-435d-9a7c-c977f184ac3a',
    tags: ['추리논증', '단순주장', '논쟁형', '순수학문'],
    subjectId: 'subject1',
    price: 500,
    totalProblems: 10,
  ),
];

// Mapping between ProblemSets and Problems
Map<String, List<String>> problemSetToProblems = {
  'set1': ['problem1', 'problem2', 'problem3'],
  'set2': ['problem1', 'problem2', 'problem3'],
  'set3': ['problem1', 'problem2', 'problem3'],
};

List<ProblemSet> myProblemSets = [
  problemSets[0],
  problemSets[1],
  problemSets[2],
];

// 최근 풀어본 문제 ID 목록
List<String> recentlyAttemptedProblemIds = ['problem1', 'problem2', 'problem3'];

// 즐겨찾기한 문제 ID 목록
List<String> favoriteProblemIds = ['problem2', 'problem3'];
