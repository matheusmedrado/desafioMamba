import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../domain/fasting_protocol.dart';
import 'widgets/fasting_window_bar.dart';

/// Lets the user pick custom fasting hours. Pops with the chosen hours.
class CustomProtocolScreen extends StatefulWidget {
  const CustomProtocolScreen({super.key, this.initialFastingHours});

  final int? initialFastingHours;

  @override
  State<CustomProtocolScreen> createState() => _CustomProtocolScreenState();
}

class _CustomProtocolScreenState extends State<CustomProtocolScreen> {
  static const _min = FastingProtocol.minCustomFastingHours;
  static const _max = FastingProtocol.maxCustomFastingHours;

  late int _fastingHours =
      widget.initialFastingHours ?? FastingProtocol.defaultCustomFastingHours;

  void _set(int hours) {
    setState(() => _fastingHours = hours.clamp(_min, _max));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final eatingHours = 24 - _fastingHours;

    return Scaffold(
      appBar: AppBar(title: const Text('Custom protocol')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '$_fastingHours'),
                        TextSpan(
                          text: ':',
                          style: TextStyle(
                            color: MambaColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '$eatingHours'),
                      ],
                    ),
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 76,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -3,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A day is 24 hours. Set one side and the other adjusts.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: MambaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FastingWindowBar(
                    fastingHours: _fastingHours,
                    height: 18,
                    fillColor: MambaColors.purpleDeep,
                    trackColor: MambaColors.surfaceHover,
                    fastingLabel: '${_fastingHours}h fasting',
                    eatingLabel: '${eatingHours}h eating',
                  ),
                  const SizedBox(height: 8),
                  _StepperRow(
                    title: 'Fasting',
                    subtitle: '$_min to $_max hours',
                    value: _fastingHours,
                    onDecrease: _fastingHours > _min
                        ? () => _set(_fastingHours - 1)
                        : null,
                    onIncrease: _fastingHours < _max
                        ? () => _set(_fastingHours + 1)
                        : null,
                  ),
                  const Divider(),
                  _StepperRow(
                    title: 'Eating',
                    subtitle: '${24 - _max} to ${24 - _min} hours',
                    value: eatingHours,
                    onDecrease: _fastingHours < _max
                        ? () => _set(_fastingHours + 1)
                        : null,
                    onIncrease: _fastingHours > _min
                        ? () => _set(_fastingHours - 1)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Icons.info_outline, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fasts longer than 20 hours are not recommended '
                          'without medical guidance. The app will still '
                          'track them.',
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Footer(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_fastingHours),
                child: const Text('Use this protocol'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String title;
  final String subtitle;
  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: MambaColors.surface,
              borderRadius: BorderRadius.circular(MambaRadius.small),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _StepButton(
                    icon: Icons.remove,
                    label: 'Decrease $title hours',
                    onPressed: onDecrease,
                  ),
                  SizedBox(
                    width: 52,
                    child: Text(
                      '$value',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  _StepButton(
                    icon: Icons.add,
                    label: 'Increase $title hours',
                    onPressed: onIncrease,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: MambaColors.surfaceElevated,
        disabledBackgroundColor: MambaColors.surfaceElevated,
        foregroundColor: MambaColors.textPrimary,
        disabledForegroundColor: MambaColors.textSecondary.withValues(
          alpha: 0.5,
        ),
        minimumSize: const Size(44, 44),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: MambaColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        child: child,
      ),
    );
  }
}
