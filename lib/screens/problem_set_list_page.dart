import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './problem_list_page.dart';
import '../utils/custom_network_image.dart';
import '../models/models.dart';
import '../providers/user_data_provider.dart';

class ProblemSetListPage extends StatefulWidget {
  const ProblemSetListPage({Key? key}) : super(key: key);

  @override
  State<ProblemSetListPage> createState() => _ProblemSetListPageState();
}

class _ProblemSetListPageState extends State<ProblemSetListPage> {
  List<ProblemSet>? _problemSets;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProblemSets();
  }

  Future<void> _loadProblemSets() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final problemSets =
          await context.read<UserDataProvider>().getPurchasedProblemSets();

      if (mounted) {
        setState(() {
          _problemSets = problemSets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문제꾸러미 목록'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProblemSets,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류가 발생했습니다: $_error'),
            ElevatedButton(
              onPressed: _loadProblemSets,
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_problemSets?.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '구매한 문제꾸러미가 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _problemSets!.length,
      itemBuilder: (context, index) {
        final problemSet = _problemSets![index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomNetworkImage(
                imageUrl: problemSet.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(problemSet.title),
            subtitle: Text(problemSet.description),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProblemListPage(
                    title: problemSet.title,
                    type: ProblemListType.problemSet,
                    problemSetId: problemSet.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
