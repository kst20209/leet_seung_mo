import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  static final _cacheManager = DefaultCacheManager();
  // 메모리 캐시를 위한 static Map
  static final Map<String, FileInfo> _memoryCache = {};

  const CustomNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  Future<FileInfo> _getImage() async {
    // 먼저 메모리 캐시 확인
    if (_memoryCache.containsKey(imageUrl)) {
      return _memoryCache[imageUrl]!;
    }

    // 디스크 캐시에서 파일 가져오기
    final fileInfo = await _cacheManager.downloadFile(imageUrl);
    // 메모리 캐시에 저장
    _memoryCache[imageUrl] = fileInfo;
    return fileInfo;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FileInfo>(
      future: _getImage(),
      builder: (context, snapshot) {
        // 에러 발생 시
        if (snapshot.hasError) {
          print('Error loading image: ${snapshot.error}');
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: Icon(Icons.error, color: Colors.red),
          );
        }

        // 데이터가 있을 경우 (캐시 또는 새로 다운로드)
        if (snapshot.hasData) {
          return Image.file(
            snapshot.data!.file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          );
        }

        // 로딩 중 (메모리/디스크 캐시에 없는 경우에만 표시)
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
