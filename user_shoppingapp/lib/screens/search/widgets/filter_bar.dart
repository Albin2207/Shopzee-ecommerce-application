import 'package:flutter/material.dart';
import 'package:user_shoppingapp/provider/filter_provider.dart';

class FilterStatusBar extends StatelessWidget {
  final FilterProvider filterProvider;

  const FilterStatusBar({required this.filterProvider, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade900,
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 18, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            'Filters applied',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: filterProvider.resetFilters,
            child: Text(
              'Clear all',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}