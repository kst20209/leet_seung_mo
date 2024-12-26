import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/custom_network_image.dart';

class GenericItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  GenericItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

// GenericItem으로 변환하는 함수 추가
GenericItem convertToGenericItem(dynamic item) {
  if (item is Problem || item is ProblemSet) {
    return GenericItem(
      id: item.id,
      title: item.title,
      description: item.description,
      imageUrl: item.imageUrl,
    );
  } else {
    throw ArgumentError('Unsupported item type');
  }
}

class HorizontalItemList extends StatelessWidget {
  final List<GenericItem> items;
  final Function(GenericItem) onItemTap;

  const HorizontalItemList({
    Key? key,
    required this.items,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items.asMap().entries.map((entry) {
                int index = entry.key;
                GenericItem item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 12 : 0,
                    right: 6,
                  ),
                  child: SizedBox(
                    width: 160,
                    child: ItemCard(item: item, onTap: onItemTap),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ItemCard extends StatelessWidget {
  final GenericItem item;
  final Function(GenericItem) onTap;

  const ItemCard({Key? key, required this.item, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CustomNetworkImage(
                imageUrl: item.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
