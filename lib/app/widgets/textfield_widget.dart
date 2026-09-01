import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class CustomEditableField extends StatefulWidget {
  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  const CustomEditableField({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomEditableFieldState createState() => _CustomEditableFieldState();
}

class _CustomEditableFieldState extends State<CustomEditableField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();

    // Слушаем изменения фокуса
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Сохраняем значение, если пользователь убрал фокус
        widget.onChanged(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Убираем фокус с текстового поля при нажатии на контейнер
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: false,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                widget.onChanged(value);
              },
              decoration: InputDecoration(
                labelText: widget.title,
                hintText: widget.title,
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: ThemeColors.grey5,
                ),
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: ThemeColors.greyForHint,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
