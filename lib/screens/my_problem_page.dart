import 'package:flutter/material.dart';
import 'package:leet_seung_mo/screens/problem_list_page.dart';

class MyProblemPage extends StatelessWidget {
  final Map<String, dynamic> problemData = {
    "recentActivity": [
      {
        "title": "Binary Search",
        "difficulty": "Medium",
        "category": "Algorithms",
        "progress": 0.7,
        "tags": ["알고리즘", "이진탐색", "분할정복"],
        "isFavorite": false,
        "isSolved": true,
        "solveTime": "15분"
      },
      {
        "title": "Linked List Cycle",
        "difficulty": "Easy",
        "category": "Data Structures",
        "progress": 0.3,
        "tags": ["자료구조", "연결리스트", "포인터"],
        "isFavorite": true,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "Dynamic Programming",
        "difficulty": "Hard",
        "category": "Algorithms",
        "progress": 0.1,
        "tags": ["알고리즘", "DP", "최적화"],
        "isFavorite": true,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "Tree Traversal",
        "difficulty": "Medium",
        "category": "Data Structures",
        "progress": 0.5,
        "tags": ["자료구조", "트리", "재귀"],
        "isFavorite": false,
        "isSolved": true,
        "solveTime": "20분"
      },
      {
        "title": "Sorting Algorithms",
        "difficulty": "Medium",
        "category": "Algorithms",
        "progress": 0.8,
        "tags": ["알고리즘", "정렬", "비교"],
        "isFavorite": true,
        "isSolved": true,
        "solveTime": "25분"
      }
    ],
    "myProblems": [
      {
        "title": "Array Manipulation",
        "difficulty": "Easy",
        "category": "Data Structures",
        "progress": 1.0,
        "tags": ["자료구조", "배열", "인덱싱"],
        "isFavorite": false,
        "isSolved": true,
        "solveTime": "8분"
      },
      {
        "title": "Graph Theory",
        "difficulty": "Hard",
        "category": "Algorithms",
        "progress": 0.2,
        "tags": ["알고리즘", "그래프", "네트워크"],
        "isFavorite": true,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "String Matching",
        "difficulty": "Medium",
        "category": "Algorithms",
        "progress": 0.6,
        "tags": ["알고리즘", "문자열", "패턴매칭"],
        "isFavorite": false,
        "isSolved": true,
        "solveTime": "18분"
      },
      {
        "title": "Heap Operations",
        "difficulty": "Medium",
        "category": "Data Structures",
        "progress": 0.4,
        "tags": ["자료구조", "힙", "우선순위큐"],
        "isFavorite": true,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "Recursion Basics",
        "difficulty": "Easy",
        "category": "Concepts",
        "progress": 0.9,
        "tags": ["개념", "재귀", "스택"],
        "isFavorite": false,
        "isSolved": true,
        "solveTime": "12분"
      }
    ],
    "favorites": [
      {
        "title": "Dijkstra's Algorithm",
        "difficulty": "Hard",
        "category": "Algorithms",
        "progress": 0.5,
        "tags": ["알고리즘", "그래프", "최단경로"],
        "isFavorite": true,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "Binary Tree",
        "difficulty": "Medium",
        "category": "Data Structures",
        "progress": 0.7,
        "tags": ["자료구조", "트리", "이진트리"],
        "isFavorite": true,
        "isSolved": true,
        "solveTime": "22분"
      },
      {
        "title": "Dynamic Programming",
        "difficulty": "Hard",
        "category": "Algorithms",
        "progress": 0.3,
        "tags": ["알고리즘", "DP", "최적화"],
        "isFavorite": true,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "Quick Sort",
        "difficulty": "Medium",
        "category": "Algorithms",
        "progress": 0.8,
        "tags": ["알고리즘", "정렬", "분할정복"],
        "isFavorite": true,
        "isSolved": true,
        "solveTime": "17분"
      },
      {
        "title": "Hash Tables",
        "difficulty": "Easy",
        "category": "Data Structures",
        "progress": 1.0,
        "tags": ["자료구조", "해시", "키-값"],
        "isFavorite": true,
        "isSolved": true,
        "solveTime": "10분"
      }
    ],
    "incorrectAnswers": [
      {
        "title": "Red-Black Tree",
        "difficulty": "Hard",
        "category": "Data Structures",
        "progress": 0.1,
        "tags": ["자료구조", "트리", "균형트리"],
        "isFavorite": false,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "A* Search Algorithm",
        "difficulty": "Hard",
        "category": "Algorithms",
        "progress": 0.2,
        "tags": ["알고리즘", "그래프", "휴리스틱"],
        "isFavorite": true,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "Knapsack Problem",
        "difficulty": "Medium",
        "category": "Dynamic Programming",
        "progress": 0.4,
        "tags": ["알고리즘", "DP", "최적화"],
        "isFavorite": false,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "Depth-First Search",
        "difficulty": "Medium",
        "category": "Algorithms",
        "progress": 0.3,
        "tags": ["알고리즘", "그래프", "탐색"],
        "isFavorite": true,
        "isSolved": false,
        "solveTime": null
      },
      {
        "title": "Bit Manipulation",
        "difficulty": "Easy",
        "category": "Concepts",
        "progress": 0.5,
        "tags": ["개념", "비트연산", "최적화"],
        "isFavorite": false,
        "isSolved": false,
        "solveTime": null
      }
    ]
  };

  MyProblemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Problems'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
              context, 'Recent Activity', problemData['recentActivity']!),
          _buildSection(context, 'My Problems', problemData['myProblems']!),
          _buildSection(context, 'Favorites', problemData['favorites']!),
          _buildSection(
              context, 'Incorrect Answers', problemData['incorrectAnswers']!),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Map<String, dynamic>> problems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProblemListPage(
                        title: title,
                        problems: problems,
                      ),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: problems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ProblemCard(problem: problems[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProblemCard extends StatelessWidget {
  final Map<String, dynamic> problem;

  const ProblemCard({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              problem['title'],
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Difficulty: ${problem['difficulty']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Category: ${problem['category']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: problem['progress'] ?? 0,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
