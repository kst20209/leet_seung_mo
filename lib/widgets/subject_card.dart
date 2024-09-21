import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final bool isSmall;

  const SubjectCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSmall) {
      return _buildSmallCard();
    }
    return _buildLargeCard();
  }

  Widget _buildLargeCard() {
    return Container(
      width: 150,
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl,
                height: 120, width: 150, fit: BoxFit.cover),
          ),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(description, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSmallCard() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl,
                height: 50, width: 50, fit: BoxFit.cover),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
