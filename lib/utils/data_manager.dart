import 'dart:async';
import '../models/models.dart';
import 'data_repository.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  final DataRepository _repository = DataRepository();

  List<ProblemSet>? _cachedProblemSets;
  DateTime? _lastFetchTime;

  Future<List<ProblemSet>> getProblemSets() async {
    if (_cachedProblemSets == null || _shouldRefetch()) {
      _cachedProblemSets = await _repository.getProblemSets();
      _lastFetchTime = DateTime.now();
    }
    return _cachedProblemSets!;
  }

  bool _shouldRefetch() {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!).inMinutes > 15;
  }

  // Additional methods for other data types can be added here
}
