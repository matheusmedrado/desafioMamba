import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Horizontal bar showing the fasting share of a 24 hour day.
class FastingWindowBar extends StatelessWidget {
  const FastingWindowBar({
    super.key,
    required this.fastingHours,
    this.height = 6,
    this.fillColor = MambaColors.purple,
    this.trackColor = MambaColors.surfaceElevated,
    this.fastingLabelColor = MambaColors.textPrimary,
    this.eatingLabelColor = MambaColors.textSecondary,
    this.fastingLabel,
    this.eatingLabel,
  });

  final int fastingHours;
  final double height;
  final Color fillColor;
  final Color trackColor;
  final Color fastingLabelColor;
  final Color eatingLabelColor;
  final String? fastingLabel;
  final String? eatingLabel;

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
              fastingLabel ?? '${fastingHours}h fast',
              style: labelStyle?.copyWith(
                fontWeight: FontWeight.w700,
                color: fastingLabelColor,
              ),
            ),
            Text(
              eatingLabel ?? '${eatingHours}h eating',
              style: labelStyle?.copyWith(color: eatingLabelColor),
            ),
          ],
        ),
      ],
    );
  }
}
