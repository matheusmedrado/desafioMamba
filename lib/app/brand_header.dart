import 'package:flutter/material.dart';

import 'mamba_icon.dart';
import 'theme.dart';

/// The wordmark lockup with a round action button.
class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    required this.actionIcon,
    required this.actionLabel,
    required this.onAction,
  });

  final MambaIcons actionIcon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Image.asset(
            'assets/images/mamba-wordmark.webp',
            width: 104,
            semanticLabel: 'Mamba',
          ),
          const SizedBox(width: 12),
          const ExcludeSemantics(
            child: Text(
              'FAST\nTRACKER',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: MambaColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          RoundIconButton(
            icon: actionIcon,
            label: actionLabel,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final MambaIcons icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: MambaColors.surfaceElevated,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 44,
            child: Center(child: MambaIcon(icon)),
          ),
        ),
      ),
    );
  }
}
