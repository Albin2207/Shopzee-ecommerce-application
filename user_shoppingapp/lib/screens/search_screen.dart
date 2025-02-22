import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_shoppingapp/provider/search_provider.dart';
import 'package:user_shoppingapp/screens/search/search_screen.dart';
import 'package:user_shoppingapp/widgets/search_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  Timer? _suggestionsTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _suggestionsTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _suggestionsTimer?.cancel();

    _suggestionsTimer = Timer(const Duration(milliseconds: 200), () {
      context.read<SearchProvider>().getSuggestions(query);
    });

    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      context.read<SearchProvider>().searchProducts(query);
    });
  }

  void _onSuggestionTap(String suggestion) async {
    _searchController.text = suggestion;

    final searchProvider = context.read<SearchProvider>();
    await searchProvider.searchProducts(suggestion);

    final products = searchProvider.searchResults;
    if (products.isNotEmpty) {
      final product = products.first;
      Navigator.pushNamed(context, "/view_product", arguments: product);
    }

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: EnhancedSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchController.clear();
                    searchProvider.clearSearch();
                  },
                  suggestions: searchProvider.suggestions,
                  onSuggestionTap: _onSuggestionTap,
                ),
              ),
              Expanded(
                child: _searchController.text.isNotEmpty
                    ? SearchResultsScreen()
                    : Center(child: Text('Enter a search term to start searching.')),
              ),
            ],
          );
        },
      ),
    );
  }
}