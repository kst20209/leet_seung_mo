import 'package:flutter/material.dart';
import '../utils/custom_network_image.dart';
import './tag_chip.dart';
import '../screens/problem_sell_detail.dart';
import '../models/models.dart';

class ProblemSetItem extends StatelessWidget {
  final ProblemSet problemSet;
  final bool isPurchased;

  const ProblemSetItem(
      {Key? key, required this.problemSet, required this.isPurchased})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(isPurchased
          ? [
              0.95, 0, 0, 0, 0, // Red
              0, 0.95, 0, 0, 0, // Green
              0, 0, 0.95, 0, 0, // Blue
              0, 0, 0, 0.6, 0, // Alpha
            ]
          : [
              1, 0, 0, 0, 0, // Red
              0, 1, 0, 0, 0, // Green
              0, 0, 1, 0, 0, // Blue
              0, 0, 0, 1, 0, // Alpha
            ]),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProblemSellDetail(problemSet: problemSet),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomNetworkImage(
                      imageUrl: problemSet.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        problemSet.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: problemSet.tags
                            .map((tag) => TagChip(label: tag))
                            .toList(),
                      ),
                      SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text('P ${problemSet.price}',
                            style: Theme.of(context).textTheme.headlineMedium),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
