class CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  CacheEntry(this.data, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

class MemoryDataCache {
  static final _instance = MemoryDataCache._internal();
  factory MemoryDataCache() => _instance;
  MemoryDataCache._internal();

  final _cache = <String, CacheEntry>{};
  static const _maxEntries = 500;

  static const defaultTTL = Duration(minutes: 15);
  static const ttls = {
    'problemSets': Duration(minutes: 15),
    'favorites': Duration(minutes: 5),
    'problems': Duration(minutes: 30),
    'profile': Duration(minutes: 1),
  };

  T? get<T>(String key) {
    final entry = _cache[key] as CacheEntry<T>?;
    if (entry == null) return null;

    final ttl = ttls[key.split(':')[0]] ?? defaultTTL;
    if (entry.isExpired(ttl)) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }

  void set<T>(String key, T data) {
    if (_cache.length >= _maxEntries) {
      final oldest = _cache.entries.reduce(
          (a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b);
      _cache.remove(oldest.key);
    }
    _cache[key] = CacheEntry<T>(data, DateTime.now());
  }

  void remove(String key) => _cache.remove(key);

  void clear() => _cache.clear();
}
