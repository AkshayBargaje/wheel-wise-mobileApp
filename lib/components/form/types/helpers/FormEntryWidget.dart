import 'package:flutter/material.dart';

class FormEntryWidget extends StatelessWidget {
  final String description;
  final String whatToCheck;
  final List<Map<String, String>> parameters;
  final String selectedValue;

  final Function(String?, String?) onChanged;

  const FormEntryWidget({
    Key? key,
    required this.description,
    required this.whatToCheck,
    required this.parameters,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for adaptive layout
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2, // Limit lines for long text
                overflow: TextOverflow.ellipsis, // Add "..." for overflowed text
              ),
              const SizedBox(height: 4),

              // Display the "What to Check" field
              Text(
                whatToCheck,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2, // Limit lines for long text
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Display the dropdown for parameters
              if (parameters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true, // Ensure the dropdown adapts to screen width
                    // value: selectedValue.isNotEmpty ? selectedValue : null,
                    value: parameters.any((param) => param['condition'] == selectedValue) 
    ? selectedValue 
    : null,

                    items: parameters.map((parameter) {
                      return DropdownMenuItem<String>(
                        value: parameter['condition'],
                        child: Text(
                          "${parameter['condition']} - ${parameter['rating']}",
                          maxLines: 1, // Limit lines for dropdown text
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
            // Pass response and corresponding rating to the callback
            String? rating = parameters
    .firstWhere((param) => param["condition"] == value, orElse: () => {})
    ["rating"];

            onChanged(value, rating);
          },

                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Select an option',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                    ),
                  ),
                )
              else
                // Handle the case where no parameters are available
                const Text(
                  'No options available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
