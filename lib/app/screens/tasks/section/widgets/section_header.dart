import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class TaskSectionHeader extends StatelessWidget {
  final GlobalKey? diaryTargetKey;
  final ValueNotifier<int>? diaryArrivals;
  final String title;
  final int completed;
  final int total;
  final bool expanded;
  final bool showCount;
  final bool showCompletedCount;
  final Color? titleColor;
  final Color? countColor;
  final VoidCallback onToggle;
  final VoidCallback? onCountTap;

  const TaskSectionHeader({
    super.key,
    this.diaryTargetKey,
    this.diaryArrivals,
    required this.title,
    required this.completed,
    required this.total,
    required this.expanded,
    required this.onToggle,
    this.showCount = true,
    this.showCompletedCount = true,
    this.titleColor,
    this.countColor,
    this.onCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              letterSpacing: -0.5,
              color: titleColor ??
                  (expanded
                      ? ThemeColors.primary
                      : ThemeColors.primary.withValues(alpha: 0.6)),
            ),
          ),
          if (showCount)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCountTap,
              child: DiaryArrivalFeedback(
                arrivals: diaryArrivals,
                child: Container(
                  key: diaryTargetKey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    showCompletedCount ? '$completed/$total' : '$total',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: countColor ?? ThemeColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A brief, restartable acknowledgement when a completed task arrives.
class DiaryArrivalFeedback extends StatefulWidget {
  const DiaryArrivalFeedback({super.key, this.arrivals, required this.child});
  final ValueNotifier<int>? arrivals;
  final Widget child;

  @override
  State<DiaryArrivalFeedback> createState() => _DiaryArrivalFeedbackState();
}

class _DiaryArrivalFeedbackState extends State<DiaryArrivalFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 440),
  );

  void _arrive() {
    if (!MediaQuery.disableAnimationsOf(context)) _pulse.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    widget.arrivals?.addListener(_arrive);
  }

  @override
  void didUpdateWidget(covariant DiaryArrivalFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.arrivals != widget.arrivals) {
      oldWidget.arrivals?.removeListener(_arrive);
      widget.arrivals?.addListener(_arrive);
    }
  }

  @override
  void dispose() {
    widget.arrivals?.removeListener(_arrive);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _pulse,
        child: widget.child,
        builder: (context, child) {
          final t = _pulse.value;
          final strength = t < .25
              ? Curves.easeOut.transform(t / .25)
              : 1 - Curves.easeInOut.transform((t - .25) / .75);
          final color = Theme.of(context).colorScheme.primary;
          return Transform.scale(
            scale: 1 + .09 * strength,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withValues(alpha: .14 * strength),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: .30 * strength),
                    blurRadius: 16 * strength,
                    spreadRadius: 2 * strength,
                  )
                ],
              ),
              child: child,
            ),
          );
        },
      );
}
