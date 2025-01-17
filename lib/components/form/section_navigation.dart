import 'package:flutter/material.dart';

class SectionNavigator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  SectionNavigator({
    required this.currentPage,
    required this.totalPages,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: currentPage > 1 ? onPreviousPage : null,
          child: Text('Previous'),
        ),
        Text('Page $currentPage of $totalPages'),
        ElevatedButton(
          onPressed: currentPage < totalPages ? onNextPage : null,
          child: Text('Next'),
        ),
      ],
    );
  }
}
