import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/l10n/s.dart';

class ReminderPickerResult {
  const ReminderPickerResult.selected(this.time) : remove = false;
  const ReminderPickerResult.remove()
      : time = null,
        remove = true;

  final TimeOfDay? time;
  final bool remove;
}

TimeOfDay resolveReminderInitialTime(
  TimeOfDay? initialTime, {
  DateTime? now,
}) {
  return initialTime ?? TimeOfDay.fromDateTime(now ?? DateTime.now());
}

Future<ReminderPickerResult?> showReminderPickerSheet(
  BuildContext context, {
  TimeOfDay? initialTime,
}) {
  final isDesktop = _usesDesktopReminderPicker(context);
  return showDialog<ReminderPickerResult>(
    context: context,
    barrierColor:
        isDesktop ? Colors.transparent : Colors.black.withValues(alpha: .28),
    builder: (_) => Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: _ReminderPickerSheet(
        initialTime: initialTime,
        isDesktop: isDesktop,
      ),
    ),
  );
}

bool _usesDesktopReminderPicker(BuildContext context) {
  if (kIsWeb) return MediaQuery.sizeOf(context).width >= 800;
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;
}

class _ReminderPickerSheet extends StatefulWidget {
  const _ReminderPickerSheet({
    this.initialTime,
    required this.isDesktop,
  });

  final TimeOfDay? initialTime;
  final bool isDesktop;

  @override
  State<_ReminderPickerSheet> createState() => _ReminderPickerSheetState();
}

class _ReminderPickerSheetState extends State<_ReminderPickerSheet> {
  static const _loopStart = 1200;

  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final initialTime = resolveReminderInitialTime(widget.initialTime);
    _hour = initialTime.hour;
    _minute = initialTime.minute;
    _hourController = FixedExtentScrollController(
      initialItem: _loopStart - (_loopStart % 24) + _hour,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _loopStart - (_loopStart % 60) + _minute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _selectPreset(int hour) {
    setState(() {
      _hour = hour;
      _minute = 0;
    });
    _hourController.animateToItem(
      _loopStart - (_loopStart % 24) + hour,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
    );
    _minuteController.animateToItem(
      _loopStart - (_loopStart % 60),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final primary = ThemeColors.primary;
    final colors = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxWidth: 440,
        maxHeight: MediaQuery.sizeOf(context).height * .88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 36,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.notifications_active_rounded,
                      color: primary, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.reminderTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.35,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.reminderSubtitle,
                        style: const TextStyle(
                          color: Color(0xFF858B96),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.surfaceContainerHighest,
                    foregroundColor: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 34),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .055),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withValues(alpha: .12)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: primary.withValues(alpha: .22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: .10),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeWheel(
                          controller: _hourController,
                          divisor: 24,
                          isDesktop: widget.isDesktop,
                          semanticsLabel: strings.hours,
                          onChanged: (value) => setState(() => _hour = value),
                        ),
                      ),
                      Text(
                        ':',
                        style: TextStyle(
                          color: primary,
                          fontSize: 35,
                          height: .9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: _TimeWheel(
                          controller: _minuteController,
                          divisor: 60,
                          isDesktop: widget.isDesktop,
                          semanticsLabel: strings.minutes,
                          onChanged: (value) => setState(() => _minute = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _PresetButton(
                    icon: Icons.wb_twilight_rounded,
                    label: strings.morning,
                    time: '08:00',
                    selected: _hour == 8 && _minute == 0,
                    onTap: () => _selectPreset(8),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PresetButton(
                    icon: Icons.wb_sunny_rounded,
                    label: strings.daytime,
                    time: '15:00',
                    selected: _hour == 15 && _minute == 0,
                    onTap: () => _selectPreset(15),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PresetButton(
                    icon: Icons.nights_stay_rounded,
                    label: strings.evening,
                    time: '20:00',
                    selected: _hour == 20 && _minute == 0,
                    onTap: () => _selectPreset(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(
                  context,
                  ReminderPickerResult.selected(
                    TimeOfDay(hour: _hour, minute: _minute),
                  ),
                ),
                icon: const Icon(Icons.check_rounded),
                label: Text(strings.saveReminder),
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: colors.onPrimary,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
            if (widget.initialTime != null) ...[
              const SizedBox(height: 7),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  const ReminderPickerResult.remove(),
                ),
                child: Text(
                  strings.removeReminder,
                  style: const TextStyle(
                    color: Color(0xFFE14D4D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.controller,
    required this.divisor,
    required this.isDesktop,
    required this.semanticsLabel,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int divisor;
  final bool isDesktop;
  final String semanticsLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = ThemeColors.primary;
    final wheel = ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 58,
      diameterRatio: 1.55,
      perspective: .0035,
      physics: const FixedExtentScrollPhysics(),
      overAndUnderCenterOpacity: .28,
      onSelectedItemChanged: (index) => onChanged(index % divisor),
      childDelegate: ListWheelChildLoopingListDelegate(
        children: List.generate(
          divisor,
          (value) => Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                color: primary,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      label: semanticsLabel,
      // A looping wheel reuses the same finite set of children. Excluding
      // their individual semantics prevents duplicate SemanticsNode
      // attachment while the dialog route is opening or closing.
      excludeSemantics: true,
      child: isDesktop
          ? ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: const {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.touch,
                },
              ),
              child: Listener(
                onPointerSignal: (event) {
                  if (event is! PointerScrollEvent ||
                      event.scrollDelta.dy == 0 ||
                      !controller.hasClients) {
                    return;
                  }
                  GestureBinding.instance.pointerSignalResolver.register(
                    event,
                    (resolvedEvent) {
                      final scrollEvent = resolvedEvent as PointerScrollEvent;
                      final direction = scrollEvent.scrollDelta.dy > 0 ? 1 : -1;
                      controller.animateToItem(
                        controller.selectedItem + direction,
                        duration: const Duration(milliseconds: 110),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  );
                },
                child: wheel,
              ),
            )
          : wheel,
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.icon,
    required this.label,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = ThemeColors.primary;
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: .11)
              : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? primary.withValues(alpha: .48)
                : colors.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? primary : const Color(0xFF8C929D)),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? primary : const Color(0xFF333841),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF9297A0), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
