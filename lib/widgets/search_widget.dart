import 'package:flutter/material.dart';
import 'dart:async';

class SearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final int debounceTime;

  const SearchWidget({super.key, required this.onSearch, this.debounceTime = 400});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _searchFocusNode.unfocus();
              widget.onSearch(''); // Trigger search with empty query
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        onSubmitted: (value) {
          _searchFocusNode.unfocus();
          widget.onSearch(value); // Trigger search immediately on submit
        },
      ),
    );
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceTime), () {
      widget.onSearch(_searchController.text);
    });
    setState(() {
      // This empty setState will rebuild the widget when the text changes
      // allowing the clear button to appear/disappear as needed
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
