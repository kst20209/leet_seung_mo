import '../models/models.dart';

class SortService {
  static final SortService _instance = SortService._internal();
  factory SortService() => _instance;
  SortService._internal();

  int _getCategoryOrder(String category) {
    switch (category) {
      case '추리':
        return 0;
      case '논증':
        return 1;
      default:
        return 99;
    }
  }

  int _getSubCategoryOrder(String category, String subCategory) {
    if (category == '추리') {
      switch (subCategory) {
        case '지문분석형':
          return 0;
        case '사례분석형':
          return 1;
        case '모형추리형':
          return 2;
        default:
          return 99;
      }
    } else if (category == '논증') {
      switch (subCategory) {
        case '논쟁형':
          return 0;
        case '결과평가형':
          return 1;
        case '다이어그램형':
          return 2;
        default:
          return 99;
      }
    }
    return 99;
  }

  int _getFieldOrder(String field) {
    switch (field) {
      case '규범':
        return 0;
      case '인문':
        return 1;
      case '사회':
        return 2;
      case '과학':
        return 3;
      default:
        return 99;
    }
  }

  List<ProblemSet> sortProblemSets(List<ProblemSet> problemSets,
      {List<String>? purchasedIds}) {
    return List<ProblemSet>.from(problemSets)
      ..sort((a, b) {
        // 구매한 문제꾸러미 정렬 (옵션)
        if (purchasedIds != null) {
          if (purchasedIds.contains(a.id) && !purchasedIds.contains(b.id))
            return 1;
          if (!purchasedIds.contains(a.id) && purchasedIds.contains(b.id))
            return -1;
        }

        // 카테고리 정렬
        if (a.category != b.category) {
          return _getCategoryOrder(a.category)
              .compareTo(_getCategoryOrder(b.category));
        }

        // 서브카테고리 정렬
        if (a.subCategory != b.subCategory) {
          return _getSubCategoryOrder(a.category, a.subCategory)
              .compareTo(_getSubCategoryOrder(b.category, b.subCategory));
        }

        // 분야별 정렬
        return _getFieldOrder(a.field).compareTo(_getFieldOrder(b.field));
      });
  }

  List<Problem> sortProblems(List<Problem> problems) {
    // 먼저 문제꾸러미 ID를 기반으로 ProblemSet 정보를 찾기 위한 Map을 만듭니다
    Map<String, ProblemSet> problemSetMap = {};

    // ProblemSet 정보를 가져와 맵에 저장하는 작업이 필요할 수 있습니다
    // 이는 Firestore에서 한 번에 가져오는 것이 좋습니다

    return List<Problem>.from(problems)
      ..sort((a, b) {
        // 같은 problem set에 속한 문제들끼리 먼저 그룹화
        if (a.problemSetId != b.problemSetId) {
          final problemSetA = problemSetMap[a.problemSetId];
          final problemSetB = problemSetMap[b.problemSetId];

          if (problemSetA != null && problemSetB != null) {
            // 카테고리 정렬
            if (problemSetA.category != problemSetB.category) {
              return _getCategoryOrder(problemSetA.category)
                  .compareTo(_getCategoryOrder(problemSetB.category));
            }

            // 서브카테고리 정렬
            if (problemSetA.subCategory != problemSetB.subCategory) {
              return _getSubCategoryOrder(
                      problemSetA.category, problemSetA.subCategory)
                  .compareTo(_getSubCategoryOrder(
                      problemSetB.category, problemSetB.subCategory));
            }

            // 분야별 정렬
            final fieldCompare = _getFieldOrder(problemSetA.field)
                .compareTo(_getFieldOrder(problemSetB.field));
            if (fieldCompare != 0) return fieldCompare;
          }
        }

        // 같은 카테고리/서브카테고리/분야 내에서는 번호순 정렬
        final aNum =
            int.tryParse(RegExp(r'\d+').firstMatch(a.title)?.group(0) ?? '0') ??
                0;
        final bNum =
            int.tryParse(RegExp(r'\d+').firstMatch(b.title)?.group(0) ?? '0') ??
                0;
        return aNum.compareTo(bNum);
      });
  }
}
