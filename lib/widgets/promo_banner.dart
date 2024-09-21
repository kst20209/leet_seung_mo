import 'package:flutter/material.dart';
import 'dart:async';

class PromoBanner extends StatefulWidget {
  final List<Map<String, String>> bannerData;
  final Duration autoScrollDuration;

  PromoBanner({
    Key? key,
    required this.bannerData,
    this.autoScrollDuration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  _PromoBannerState createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (_currentPage < widget.bannerData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300, // Increased height
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.bannerData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildBannerItem(widget.bannerData[index]);
            },
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPage + 1}/${widget.bannerData.length}',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(Map<String, String> data) {
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            Uri.encodeFull(data['imageUrl']!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return Container(
                color: Colors.grey,
                child: Icon(Icons.error),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']!,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  data['subtitle']!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
