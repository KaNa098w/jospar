import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class ToggleSwitchButton extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
              return Colors.white;
            }),
            trackColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return ThemeColors.primary;
              }
              return Colors.grey.shade200;
            }),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            thumbIcon: MaterialStateProperty.all(null),
          ),
        ),
        child: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
