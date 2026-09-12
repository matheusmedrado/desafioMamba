import 'package:flutter/material.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/screen_header.dart';
import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/fasting_protocol.dart';
import 'widgets/fasting_window_bar.dart';

const _secondary = TextStyle(
  fontFamily: 'Manrope',
  color: MambaColors.textSecondary,
);

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
    final l10n = AppLocalizations.of(context)!;
    final eatingHours = 24 - _fastingHours;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.customProtocolTitle, showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '$_fastingHours'),
                        const TextSpan(
                          text: ':',
                          style: TextStyle(
                            color: MambaColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '$eatingHours'),
                      ],
                    ),
                    style: MambaTextStyles.heroNumber.copyWith(
                      letterSpacing: -3,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.customProtocolLead,
                    style: _secondary.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  FastingWindowBar(
                    fastingHours: _fastingHours,
                    height: 18,
                    fillColor: MambaColors.purpleDeep,
                    trackColor: MambaColors.surfaceHover,
                    fastingLabel: l10n.fastingHoursLabel(_fastingHours),
                    eatingLabel: l10n.eatingHoursLabel(eatingHours),
                  ),
                  const SizedBox(height: 8),
                  _StepperRow(
                    title: l10n.fasting,
                    subtitle: l10n.hoursRange(_min, _max),
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
                    title: l10n.eating,
                    subtitle: l10n.hoursRange(24 - _max, 24 - _min),
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
                        child: MambaIcon(
                          MambaIcons.info,
                          size: 18,
                          color: MambaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.longFastNote,
                          style: _secondary.copyWith(
                            fontSize: 13,
                            height: 1.45,
                          ),
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
                child: Text(l10n.useThisProtocol),
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
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: MambaColors.textPrimary,
                  ),
                ),
                Text(subtitle, style: _secondary.copyWith(fontSize: 13)),
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
                    icon: MambaIcons.minus,
                    label: l10n.decreaseHours(title),
                    onPressed: onDecrease,
                  ),
                  SizedBox(
                    width: 52,
                    child: Text(
                      '$value',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: MambaColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  _StepButton(
                    icon: MambaIcons.plus,
                    label: l10n.increaseHours(title),
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

  final MambaIcons icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: MambaIcon(
        icon,
        size: 20,
        color: onPressed == null
            ? MambaColors.textSecondary.withValues(alpha: 0.5)
            : MambaColors.textPrimary,
      ),
      style: IconButton.styleFrom(
        backgroundColor: MambaColors.surfaceElevated,
        disabledBackgroundColor: MambaColors.surfaceElevated,
        minimumSize: const Size(44, 44),
        shape: const CircleBorder(),
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
