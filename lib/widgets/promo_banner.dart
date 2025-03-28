import 'package:flutter/material.dart';
import '../utils/custom_network_image.dart';
import 'dart:async';

class PromoBanner extends StatefulWidget {
  final List<Map<String, dynamic>> bannerData;
  final Duration autoScrollDuration;
  final Function(Map<String, dynamic>)? onTap;

  PromoBanner({
    Key? key,
    required this.bannerData,
    this.autoScrollDuration = const Duration(seconds: 5),
    this.onTap,
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
              color: Colors.black.withValues(alpha: 0.6),
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

  Widget _buildBannerItem(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(data),
      child: Container(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomNetworkImage(
              imageUrl: data['imageUrl'] as String,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7)
                  ],
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
                    data['title'] as String,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    data['subtitle'] as String,
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
      ),
    );
  }
}
