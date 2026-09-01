import 'package:flutter/material.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/services/task_list_service.dart';
import 'package:jospar/app/widgets/accept_button.dart';
import 'package:jospar/app/widgets/toggle_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:jospar/core/models/task_list_items_response.dart';

Future<void> showUpsertListModal(
  BuildContext context, {
  TaskListItems? existing, // ← если передаёшь — будет режим Редактирования
}) {
  final global = context.read<GlobalProvider>();
  final userId = int.tryParse(global.authResponse?.user?.id?.toString() ?? '');

  // Начальные значения: для edit берём из existing, для create — дефолты
  final TextEditingController nameController =
      TextEditingController(text: (existing?.name ?? '').trim());
  final FocusNode focusNode = FocusNode();

  bool isHidden = existing?.hidden == true;
  Color selectedColor = _colorFromHex(existing?.colorHex) ?? _colors.first;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return FractionallySizedBox(
            heightFactor: 0.8,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 2,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 25,
                      icon: Image.asset(
                        'assets/icons/arrow_down.png',
                        height: 30,
                        width: 60,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // === Поле с выбранным цветом + название ===
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: selectedColor, radius: 5),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: nameController,
                          focusNode: focusNode,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: S.of(context).listTitleHint,
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _submit(
                            context,
                            nameController: nameController,
                            selectedColor: selectedColor,
                            isHidden: isHidden,
                            existing: existing,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Divider(thickness: 1, color: Colors.grey.shade300),

                  _switchRow(
                    title: S.of(context).listHideFromHome,
                    value: isHidden,
                    onChanged: (v) => setState(() => isHidden = v),
                  ),

                  Divider(thickness: 1, color: Colors.grey.shade300),
                  const Spacer(),

                  // Кнопка Сохранить
                  AcceptButton(
                    text: existing == null
                        ? S.of(context).done
                        : S.of(context).done,
                    onPressed: () => _submit(
                      context,
                      nameController: nameController,
                      selectedColor: selectedColor,
                      isHidden: isHidden,
                      existing: existing,
                    ),
                  ),

                  Divider(thickness: 1, color: Colors.grey.shade300),

                  // Палитра
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final color = _colors[index];
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 18,
                            child: isSelected
                                ? const Icon(Icons.circle_outlined,
                                    color: Colors.white, size: 32)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Сабмит: создаёт или обновляет
Future<void> _submit(
  BuildContext context, {
  required TextEditingController nameController,
  required Color selectedColor,
  required bool isHidden,
  TaskListItems? existing,
}) async {
  final name = nameController.text.trim();
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).enterListTitle)),
    );
    return;
  }

  final taskListService = TaskListService();
  final colorHex = _hexFromColor(selectedColor); // #AARRGGBB

  try {
    dynamic result;
    if (existing == null) {
      // CREATE
      result = await taskListService.createTaskList(
        context,
        name: name,
        colorHex: colorHex,
        hidden: isHidden,
      );
    } else {
      // UPDATE
      result = await taskListService.updateTaskList(
        context,
        id: existing.id!, // предполагаем, что id есть
        name: name,
        colorHex: colorHex,
        hidden: isHidden,
      );
    }

    // Обнови стор, если требуется
    final gp = context.read<GlobalProvider>();
    await gp.refreshTaskLists(context);

    if (context.mounted) {
      Navigator.pop(context, result);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${S.of(context).error}: $e')),
    );
  }
}

Widget _switchRow({
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      ToggleSwitchButton(value: value, onChanged: onChanged),
    ],
  );
}

final List<Color> _colors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
  Colors.cyan,
  Colors.amber,
  Colors.teal,
];

Color? _colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  var s = hex.replaceAll('#', '');
  if (s.length == 6) s = 'FF$s'; // добить альфу
  try {
    return Color(int.parse(s, radix: 16));
  } catch (_) {
    return null;
  }
}

String _hexFromColor(Color c) =>
    '#${c.value.toRadixString(16).padLeft(8, '0')}';
