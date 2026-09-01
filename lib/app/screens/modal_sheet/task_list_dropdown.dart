import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/models/task_list_items_response.dart';

class TaskListSelectionView extends StatefulWidget {
  final List<TaskListItems> lists;
  final String? selectedListId;
  final VoidCallback onBack;
  final void Function(String id, String? colorHex) onPick;

  const TaskListSelectionView({
    super.key,
    required this.lists,
    required this.selectedListId,
    required this.onBack,
    required this.onPick,
  });

  @override
  State<TaskListSelectionView> createState() => _TaskListSelectionViewState();
}

class _TaskListSelectionViewState extends State<TaskListSelectionView> {
  late final TextEditingController _searchCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text;
      if (q != _query) setState(() => _query = q);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TaskListItems> get _filtered {
    if (_query.trim().isEmpty) return widget.lists;
    final q = _query.toLowerCase();
    return widget.lists.where((e) {
      final name = (e.name ?? '').toLowerCase();
      return name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Padding(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 40,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Поиск списка',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtrl.clear();
                              // setState вызовется из листенера
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: widget.lists.isEmpty
                ? Center(
                    child: Text(
                      'Нет списков задач — сначала создай список.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : (filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Ничего не найдено',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final id = (item.id ?? '');
                          final name =
                              (item.name ?? 'Без названия').trim().isEmpty
                                  ? 'Без названия'
                                  : item.name!;
                          final isSelected =
                              (widget.selectedListId ?? '') == id;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            leading: _ColorDot(hex: item.colorHex),
                            title: Text(name),
                            trailing: isSelected
                                ? Icon(Icons.check, color: ThemeColors.primary)
                                : null,
                            onTap: () => widget.onPick(id, item.colorHex),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final String? hex;
  const _ColorDot({required this.hex});

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFCCCCCC);
    var s = hex.trim();
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 6) s = 'FF$s'; // добавить альфу при необходимости
    try {
      return Color(int.parse(s, radix: 16));
    } catch (_) {
      return const Color(0xFFCCCCCC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _parseHex(hex);
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}
