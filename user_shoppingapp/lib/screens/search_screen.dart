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
  String _lastQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 50 && !_isCollapsed) {
        setState(() => _isCollapsed = true);
      } else if (_scrollController.offset <= 50 && _isCollapsed) {
        setState(() => _isCollapsed = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (query == _lastQuery) return;
    _lastQuery = query;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final searchProvider = context.read<SearchProvider>();

      if (query.isEmpty) {
        searchProvider.clearSearch();
      } else {
        searchProvider.getSuggestions(query);
        searchProvider.searchProducts(query);
      }
    });
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _onSearchChanged(suggestion);
  }

  Widget _buildSearchHeader(SearchProvider searchProvider) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(_isCollapsed ? 0 : 20),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: _isCollapsed ? 8 : 16,
                  bottom: _isCollapsed ? 8 : 16,
                ),
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _buildSearchHeader(searchProvider),
              ),
              if (_searchController.text.isNotEmpty)
                const SliverFillRemaining(
                  child: SearchResultsScreen(),
                )
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    alignment: Alignment.center,
                    child: _buildEmptyState(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search, size: 80, color: Colors.grey[700]),
        const SizedBox(height: 16),
        Text(
          'Start searching for products',
          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        Text(
          'Find what you are looking for',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}