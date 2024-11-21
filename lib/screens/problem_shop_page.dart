import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/tag_chip.dart';
import '../widgets/problem_set_item.dart';
import '../utils/data_manager.dart';
import '../models/models.dart';
import '../providers/user_data_provider.dart';
import '../utils/sort_service.dart';

class ProblemShopPage extends StatefulWidget {
  const ProblemShopPage({super.key});

  @override
  _ProblemShopPageState createState() => _ProblemShopPageState();
}

class _ProblemShopPageState extends State<ProblemShopPage> {
  bool _isFilterExpanded = false;
  List<ProblemSet> _problemSets = [];
  final DataManager _dataManager = DataManager();
  final SortService _sortService = SortService();

  // 선택된 필터들을 저장하는 Set
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedSubCategories = {};
  final Set<String> _selectedFields = {};

  // 필터 옵션 정의
  static const Map<String, List<String>> _categorySubCategories = {
    '추리': ['지문분석형', '사례분석형', '모형추리형'],
    '논증': ['논쟁형', '결과평가형', '다이어그램형'],
  };

  static const List<String> _fields = ['규범', '인문', '사회', '과학'];

  @override
  void initState() {
    super.initState();
    _fetchProblemSets();
  }

  Future<void> _fetchProblemSets() async {
    final problemSets = await _dataManager.getProblemSets();
    final userDataProvider = context.read<UserDataProvider>();
    final purchasedSets =
        userDataProvider.userData?['purchasedProblemSets'] as List<dynamic>? ??
            [];

    // 필터 적용
    var filteredSets = problemSets.where((set) {
      bool categoryMatch = _selectedCategories.isEmpty ||
          _selectedCategories.contains(set.category);
      bool subCategoryMatch = _selectedSubCategories.isEmpty ||
          _selectedSubCategories.contains(set.subCategory);
      bool fieldMatch =
          _selectedFields.isEmpty || _selectedFields.contains(set.field);

      return categoryMatch && subCategoryMatch && fieldMatch;
    }).toList();

    // 정렬 로직 적용
    filteredSets = _sortService.sortProblemSets(
      filteredSets,
      purchasedIds: purchasedSets.cast<String>(),
    );

    setState(() {
      _problemSets = filteredSets;
    });
  }

  void _updateFilter(String value, Set<String> filterSet) {
    setState(() {
      if (filterSet.contains(value)) {
        filterSet.remove(value);
      } else {
        filterSet.add(value);
      }
    });
    _fetchProblemSets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문제 상점'),
        elevation: 0,
      ),
      body: Column(
        children: [
          FilterSection(
            isExpanded: _isFilterExpanded,
            onExpandToggle: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            selectedCategories: _selectedCategories,
            selectedSubCategories: _selectedSubCategories,
            selectedFields: _selectedFields,
            onFilterUpdate: _updateFilter,
            categorySubCategories: _categorySubCategories,
            fields: _fields,
          ),
          if (_problemSets.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  '해당하는 문제꾸러미가 없습니다',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          else
            Expanded(
              child: Consumer<UserDataProvider>(
                builder: (context, userDataProvider, _) {
                  return ListView.builder(
                    itemCount: _problemSets.length,
                    itemBuilder: (context, index) {
                      final problemSet = _problemSets[index];
                      final purchasedSets =
                          userDataProvider.userData?['purchasedProblemSets']
                                  as List<dynamic>? ??
                              [];
                      final isPurchased = purchasedSets.contains(problemSet.id);

                      return ProblemSetItem(
                        problemSet: problemSet,
                        isPurchased: isPurchased,
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class FilterSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final Set<String> selectedCategories;
  final Set<String> selectedSubCategories;
  final Set<String> selectedFields;
  final Function(String, Set<String>) onFilterUpdate;
  final Map<String, List<String>> categorySubCategories;
  final List<String> fields;

  const FilterSection({
    Key? key,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.selectedCategories,
    required this.selectedSubCategories,
    required this.selectedFields,
    required this.onFilterUpdate,
    required this.categorySubCategories,
    required this.fields,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '필터',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon:
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: onExpandToggle,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterGroup(
                    context: context,
                    title: '유형',
                    filters: categorySubCategories.keys.toList(),
                    selectedFilters: selectedCategories,
                    onTap: (value) => onFilterUpdate(value, selectedCategories),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterGroup(
                    context: context,
                    title: '세부 유형',
                    filters:
                        categorySubCategories.values.expand((x) => x).toList(),
                    selectedFilters: selectedSubCategories,
                    onTap: (value) =>
                        onFilterUpdate(value, selectedSubCategories),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterGroup(
                    context: context,
                    title: '분야',
                    filters: fields,
                    selectedFilters: selectedFields,
                    onTap: (value) => onFilterUpdate(value, selectedFields),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterGroup({
    required BuildContext context,
    required String title,
    required List<String> filters,
    required Set<String> selectedFilters,
    required Function(String) onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.map((filter) {
            final isSelected = selectedFilters.contains(filter);
            return TagChip(
              label: filter,
              onTap: () => onTap(filter),
              isSelected: isSelected,
              // backgroundColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}
