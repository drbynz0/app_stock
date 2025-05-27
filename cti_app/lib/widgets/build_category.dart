import 'package:flutter/material.dart';
import 'package:cti_app/models/category.dart';

class CategoryDropdown extends StatelessWidget {
  final TextEditingController? controller;
  final List<Category> categories;
  final Function(Category?) onChanged;
  final String? labelText;
  final String? hintText;
  final EdgeInsets? padding;
  final Category? initialValue;
  final bool isRequired;
  final String? errorText;
  final InputBorder? border;
  final TextStyle? style;
  final Color? dropdownColor;

  const CategoryDropdown({
    super.key,
    this.controller,
    required this.categories,
    required this.onChanged,
    this.labelText = 'Catégorie',
    this.hintText,
    this.padding,
    this.initialValue,
    this.isRequired = true,
    this.errorText,
    this.border,
    this.style,
    this.dropdownColor,
  });

  @override
  Widget build(BuildContext context) {
    // Trouver la valeur correspondante dans la liste
    Category? resolvedInitialValue;
    if (initialValue != null) {
      resolvedInitialValue = categories.firstWhere(
        (cat) => cat.id == initialValue!.id,
        orElse: () => initialValue!,
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<Category>(
        value: resolvedInitialValue,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: border ?? OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: const Icon(Icons.category),
          errorText: errorText,
        ),
        dropdownColor: dropdownColor ?? Theme.of(context).cardColor,
        style: style ?? Theme.of(context).textTheme.titleMedium,
        items: categories.map((Category category) {
          return DropdownMenuItem<Category>(
            value: category,
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
              style: style ?? Theme.of(context).textTheme.titleMedium,
            ),
          );
        }).toList(),
        onChanged: (Category? newValue) {
          if (controller != null && newValue != null) {
            controller!.text = newValue.name;
          }
          onChanged(newValue);
        },
        validator: isRequired
            ? (value) {
                if (value == null) {
                  return 'Veuillez sélectionner une catégorie';
                }
                return null;
              }
            : null,
      ),
    );
  }
}