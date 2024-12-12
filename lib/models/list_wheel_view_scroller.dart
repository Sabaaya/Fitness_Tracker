import 'package:flutter/material.dart';

class listwheelScrollView extends StatelessWidget {
  final List<String> items;
  final ValueChanged<int> onSelectedItemChanged;
  final String selectedItem;
  final TextStyle selectedItemTextStyle;
  final TextStyle unselectedItemTextStyle; // Add this line

  const listwheelScrollView({
    super.key,
    required this.items,
    required this.onSelectedItemChanged,
    required this.selectedItem,
    required this.selectedItemTextStyle,
    required this.unselectedItemTextStyle, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      itemExtent: 50.0,
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          return Center(
            child: Text(
              items[index],
              style: TextStyle(
                color: items[index] == selectedItem
                    ? Colors.blue // Highlight selected item
                    : Colors.white,
                fontSize: 20,
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}
