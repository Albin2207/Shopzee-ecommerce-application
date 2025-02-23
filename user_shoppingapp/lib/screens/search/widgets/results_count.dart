import 'package:flutter/material.dart';
import 'package:user_shoppingapp/provider/search_provider.dart';

class ResultsCount extends StatelessWidget {
  final int filteredCount;
  final SearchProvider searchProvider;

  const ResultsCount({
    required this.filteredCount,
    required this.searchProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$filteredCount ${filteredCount == 1 ? 'result' : 'results'}',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          if (filteredCount < searchProvider.searchResults.length)
            Text(
              'Filtered from ${searchProvider.searchResults.length}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}