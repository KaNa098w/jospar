import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class ModernToggleSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const ModernToggleSwitch({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<ModernToggleSwitch> createState() => _ModernToggleSwitchState();
}

class _ModernToggleSwitchState extends State<ModernToggleSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedToggleSwitch<bool>.dual(
      current: _value,
      first: false,
      second: true,
      spacing: 0.0,
      height: 36.0,
      borderWidth: 0.0,
      onChanged: (val) {
        setState(() => _value = val);
        widget.onChanged(val);
      },
      style: ToggleStyle(
        backgroundColor: Colors.grey.shade300,
        indicatorColor: Colors.white,
        borderRadius: BorderRadius.circular(20),
        indicatorBorderRadius: BorderRadius.circular(20),
        // indicatorDecoration: BoxDecoration(
        //   color: Colors.white,
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.1),
        //       blurRadius: 4,
        //       offset: const Offset(0, 2),
        //     ),
        //   ],
        // ),
      ),
      styleBuilder: (val) => ToggleStyle(
        backgroundColor: val ? Colors.green : Colors.grey.shade300,
        indicatorColor: Colors.white,
      ),
      iconBuilder: (_) => const SizedBox(), // без иконок
    );
  }
}
