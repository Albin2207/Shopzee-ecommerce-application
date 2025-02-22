import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/provider/search_provider.dart';
import 'package:user_shoppingapp/provider/filter_provider.dart';
import 'package:user_shoppingapp/screens/search/widgets/filter_bar.dart';
import 'package:user_shoppingapp/screens/search/widgets/results_count.dart';
import 'package:user_shoppingapp/screens/search/widgets/search_results_grid.dart';
import 'package:user_shoppingapp/widgets/filteroptions_bar.dart';


class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchProvider, FilterProvider>(
      builder: (context, searchProvider, filterProvider, child) {
        if (searchProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        if (searchProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade600,
                ),
                SizedBox(height: 16),
                Text(
                  searchProvider.searchQuery.isEmpty
                      ? "Start searching for products"
                      : "No products found",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Apply filters to search results
        final filteredProducts = filterProvider.applySortAndFilters(
          searchProvider.searchResults,
        );

        return Column(
          children: [
            // Filter status bar
            if (filterProvider.hasActiveFilters)
              FilterStatusBar(filterProvider: filterProvider),
            
            FilterOptionsBar(),
            
            // Results count
            ResultsCount(
              filteredCount: filteredProducts.length,
              searchProvider: searchProvider,
            ),
            
            // Search results grid
            Expanded(
              child: SearchResultsGrid(
                products: filteredProducts,
                filterProvider: filterProvider,
              ),
            ),
          ],
        );
      },
    );
  }
}