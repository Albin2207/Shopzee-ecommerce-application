import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/provider/filter_provider.dart';

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
    return OutlinedButton.icon(
      icon: Icon(Icons.filter_list, size: 20, color: Colors.white),
      label: Text(
        'Filter',
        style: TextStyle(color: Colors.white),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        _showFilterBottomSheet(context);
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

// filter_bottom_sheet.dart
class FilterBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const FilterBottomSheet({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(context, filterProvider),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  children: [
                    _buildPriceRangeSection(filterProvider),
                    _buildColorSection(filterProvider),
                    _buildPopularitySection(filterProvider),
                  ],
                ),
              ),
              _buildApplyButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FilterProvider filterProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: filterProvider.resetFilters,
            child: Text(
              'Reset All',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeSection(FilterProvider filterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        RangeSlider(
          values: filterProvider.priceRange,
          min: 0,
          max: 100000,
          divisions: 100,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey.shade800,
          labels: RangeLabels(
            '₹${filterProvider.priceRange.start.round()}',
            '₹${filterProvider.priceRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            // Add setPriceRange method to FilterProvider
          },
        ),
      ],
    );
  }

  Widget _buildColorSection(FilterProvider filterProvider) {
    final colors = ['Black', 'White', 'Red', 'Blue', 'Green', 'Yellow'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colors',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => FilterChip(
            label: Text(color),
            selected: filterProvider.selectedColors.contains(color),
            onSelected: (bool selected) {
              // Add toggleColor method to FilterProvider
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularitySection(FilterProvider filterProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popularity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        CheckboxListTile(
          title: Text(
            'Most Popular',
            style: TextStyle(color: Colors.white),
          ),
          value: false, // Add popularity filter to FilterProvider
          onChanged: (bool? value) {
            // Add togglePopularity method to FilterProvider
          },
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          top: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Apply Filters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}