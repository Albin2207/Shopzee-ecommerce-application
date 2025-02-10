import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/provider/filter_provider.dart';
import 'package:user_shoppingapp/widgets/filter_options_bar.dart';

class FilterOptionsBar extends StatelessWidget {
  const FilterOptionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade900,
      child: Row(
        children: [
          _buildSortButton(context),
          SizedBox(width: 12),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return OutlinedButton.icon(
          icon: Icon(Icons.sort, size: 20, color: Colors.white),
          label: Text(
            'Sort',
            style: TextStyle(color: Colors.white),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            _showSortBottomSheet(context);
          },
        );
      },
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return OutlinedButton.icon(
          icon: Icon(
            Icons.filter_list,
            size: 20,
            color: filterProvider.hasActiveFilters ? Colors.blue : Colors.white,
          ),
          label: Text(
            'Filter',
            style: TextStyle(
              color: filterProvider.hasActiveFilters ? Colors.blue : Colors.white,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: filterProvider.hasActiveFilters
                  ? Colors.blue
                  : Colors.grey.shade700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            _showFilterBottomSheet(context);
          },
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<FilterProvider>(
        builder: (context, filterProvider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade800),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort By',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              _buildSortOption(
                context,
                filterProvider,
                SortOption.newest,
                'Newest First',
              ),
              _buildSortOption(
                context,
                filterProvider,
                SortOption.priceLowToHigh,
                'Price: Low to High',
              ),
              _buildSortOption(
                context,
                filterProvider,
                SortOption.priceHighToLow,
                'Price: High to Low',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    FilterProvider filterProvider,
    SortOption option,
    String label,
  ) {
    return InkWell(
      onTap: () {
        filterProvider.setSortOption(option);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            if (filterProvider.currentSort == option)
              Icon(Icons.check, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return FilterBottomSheet(scrollController: scrollController);
        },
      ),
    );
  }
}