import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jospar/app/utils/theme.dart';

class SMSCodeInputField extends StatefulWidget {
  final String title;
  final TextEditingController controller;

  const SMSCodeInputField({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  _SMSCodeInputFieldState createState() => _SMSCodeInputFieldState();
}

class _SMSCodeInputFieldState extends State<SMSCodeInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        cursorColor: ThemeColors.primary,
        maxLength: 6, // Ограничение на 6 символов
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Только цифры
          LengthLimitingTextInputFormatter(6), // Ограничение длины ввода
        ],
        decoration: InputDecoration(
          labelText: widget.title,
          counterText: "", // Убираем счетчик символов
          contentPadding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
          hintText: "123456",
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
          hintStyle: TextStyle(
            color: ThemeColors.greyForHint,
            fontSize: 16,
          ),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 4, // Разделение символов для удобства чтения
        ),
        textAlign: TextAlign.start, // Центрируем ввод
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Введите код из SMS";
          }
          if (value.length != 6) {
            return "Код должен содержать 6 цифр";
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
