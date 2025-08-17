import 'package:flutter/material.dart';

class SearchBarWithSuggestions extends StatefulWidget {
  final List<String> suggestionsData;
  final void Function(String) onSearch;

  const SearchBarWithSuggestions({
    super.key,
    required this.suggestionsData,
    required this.onSearch,
  });

  @override
  State<SearchBarWithSuggestions> createState() =>
      _SearchBarWithSuggestionsState();
}

class _SearchBarWithSuggestionsState extends State<SearchBarWithSuggestions> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _focusNode.hasFocus &&
            _controller.text.isNotEmpty &&
            _filteredSuggestions.isNotEmpty;
      });
    });
  }

  void _onChanged() {
    final query = _controller.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = [];
        _showSuggestions = false;
      } else {
        _filteredSuggestions =
            widget.suggestionsData
                .where((s) => s.toLowerCase().contains(query))
                .toList();
        _showSuggestions =
            _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
      }
    });
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    widget.onSearch(suggestion);
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onSubmitted: (value) => widget.onSearch(value),
                ),
              ),
            ],
          ),
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  title: Text(
                    suggestion,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  onTap: () => _onSuggestionTap(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}
