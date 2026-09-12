import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Horizontal bar showing the fasting share of a 24 hour day.
class FastingWindowBar extends StatelessWidget {
  const FastingWindowBar({
    super.key,
    required this.fastingHours,
    required this.fastingLabel,
    required this.eatingLabel,
    this.height = 6,
    this.fillColor = MambaColors.purple,
    this.trackColor = MambaColors.surfaceElevated,
    this.fastingLabelColor = MambaColors.textPrimary,
    this.eatingLabelColor = MambaColors.textSecondary,
  });

  final int fastingHours;
  final String fastingLabel;
  final String eatingLabel;
  final double height;
  final Color fillColor;
  final Color trackColor;
  final Color fastingLabelColor;
  final Color eatingLabelColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final eatingHours = 24 - fastingHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Row(
              // Childless ColoredBoxes take no height unless stretched.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: fastingHours,
                  child: ColoredBox(color: fillColor),
                ),
                Expanded(
                  flex: eatingHours,
                  child: ColoredBox(color: trackColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fastingLabel,
              style: labelStyle?.copyWith(
                fontWeight: FontWeight.w700,
                color: fastingLabelColor,
              ),
            ),
            Text(
              eatingLabel,
              style: labelStyle?.copyWith(color: eatingLabelColor),
            ),
          ],
        ),
      ],
    );
  }
}
