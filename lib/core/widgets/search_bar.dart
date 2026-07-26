import 'package:flutter/material.dart';

import 'primary_button.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSearch,
    this.prefixIcon = Icons.search,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSearch;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(prefixIcon),
            ),
          ),
        ),
        const SizedBox(width: 12),
        PrimaryButton(
          text: 'Search',
          icon: Icons.search,
          onPressed: onSearch,
        ),
      ],
    );
  }
}
