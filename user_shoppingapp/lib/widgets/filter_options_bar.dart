import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/provider/filter_provider.dart';

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
                    SizedBox(height: 24),
                    _buildSizeSection(filterProvider),
                    SizedBox(height: 24),
                    _buildColorSection(filterProvider),
                    SizedBox(height: 24),
                    _buildCategorySection(filterProvider),
                  ],
                ),
              ),
              _buildApplyButton(context, filterProvider),
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
          if (filterProvider.hasActiveFilters)
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
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${filterProvider.priceRange.start.round()}',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            Text(
              '₹${filterProvider.priceRange.end.round()}',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
        SizedBox(height: 8),
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
          onChanged: filterProvider.setPriceRange,
        ),
      ],
    );
  }

  Widget _buildSizeSection(FilterProvider filterProvider) {
    final sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
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
          children: sizes.map((size) {
            final isSelected = filterProvider.selectedSizes.contains(size);
            return FilterChip(
              label: Text(
                size,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => filterProvider.toggleSize(size),
              backgroundColor: Colors.grey.shade800,
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSection(FilterProvider filterProvider) {
    final colors = {
      'Black': Colors.black,
      'White': Colors.white,
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Yellow': Colors.yellow,
    };
    
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
          spacing: 12,
          runSpacing: 12,
          children: colors.entries.map((entry) {
            final isSelected = filterProvider.selectedColors.contains(entry.key);
            return InkWell(
              onTap: () => filterProvider.toggleColor(entry.key),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: entry.key == 'White' ? Colors.black : Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySection(FilterProvider filterProvider) {
  if (filterProvider.isLoadingCategories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ],
    );
  }

  final categories = filterProvider.categories;
  
  if (categories.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'No categories available',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Categories',
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
        children: categories.map((category) {
          final categoryName = category.name.toLowerCase();
          final isSelected = filterProvider.selectedCategories.contains(categoryName);
          return FilterChip(
            avatar: category.image.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(category.image),
                    backgroundColor: Colors.transparent,
                  )
                : null,
            label: Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade300,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => filterProvider.toggleCategory(categoryName),
            backgroundColor: Colors.grey.shade800,
            selectedColor: Colors.blue,
            checkmarkColor: Colors.white,
          );
        }).toList(),
      ),
    ],
  );
}

  Widget _buildApplyButton(BuildContext context, FilterProvider filterProvider) {
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