import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear; // Optional callback for clearing

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white), // Text color
        decoration: InputDecoration(
          hintText: 'Search songs, artists, albums...',
          hintStyle: const TextStyle(color: Color(0xFFFFDB4D)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFFDB4D)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFFFDB4D)),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) {
                      onClear!(); // Call the clear callback if provided
                    }
                    onChanged(''); // Notify that the text is now empty
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.black, // Dark background for the field
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Color(0xFFFFDB4D), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Color(0xFFFFDB4D), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Color(0xFFFFDB4D), width: 2.0),
          ),
        ),
      ),
    );
  }
}