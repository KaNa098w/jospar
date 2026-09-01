import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class TaskTitleField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool autofocus;

  const TaskTitleField({
    Key? key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.hintText = 'Новая задача',
    required this.autofocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: ThemeColors.primary,
      autofocus: autofocus,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 18.5),
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        hintStyle: const TextStyle(fontSize: 18.5),
      ),
    );
  }
}
