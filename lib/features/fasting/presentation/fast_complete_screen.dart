import 'package:flutter/material.dart';

import '../../../app/brand_header.dart';
import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../core/formatting.dart';
import '../domain/fasting_protocol.dart';
import '../domain/fasting_session.dart';
import 'widgets/fasting_path.dart';

enum FastCompleteAction { backToToday, logMeal }

const _secondary = TextStyle(
  fontFamily: 'Manrope',
  color: MambaColors.textSecondary,
);

/// Summary shown right after a fast ends.
class FastCompleteScreen extends StatelessWidget {
  const FastCompleteScreen({
    super.key,
    required this.session,
    required this.now,
  });

  final FastingSession session;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final endedAt = session.endedAt!;
    final fasted = session.elapsedAt(endedAt);
    final reached = session.goalReachedAt(endedAt);
    final progress = (fasted.inMilliseconds / session.target.inMilliseconds)
        .clamp(0.0, 1.0);
    final goalHours = session.target.inHours;
    final eatingEnd = session.eatingWindowEndsAt!;
    final eatingDay = formatRelativeDay(eatingEnd, now);
    final unit = MambaTextStyles.heroNumber.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
      color: MambaColors.textSecondary,
    );

    void close(FastCompleteAction action) => Navigator.of(context).pop(action);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BrandHeader(
                actionIcon: MambaIcons.close,
                actionLabel: 'Close',
                onAction: () => close(FastCompleteAction.backToToday),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Fast complete.',
                      style: MambaTextStyles.screenTitle,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Your session is saved',
                      style: _secondary.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Time fasted',
                      style: _secondary.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${fasted.inHours}',
                            style: MambaTextStyles.heroNumber,
                          ),
                          const SizedBox(width: 6),
                          Text('h', style: unit),
                          const SizedBox(width: 14),
                          Text(
                            fasted.inMinutes
                                .remainder(60)
                                .toString()
                                .padLeft(2, '0'),
                            style: MambaTextStyles.heroNumber,
                          ),
                          const SizedBox(width: 6),
                          Text('m', style: unit),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        MambaIcon(
                          reached ? MambaIcons.check : MambaIcons.flag,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reached ? 'Goal reached' : 'Ended early',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: MambaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label:
                          '${formatHoursMinutes(fasted)} fasted of a '
                          '$goalHours-hour goal.',
                      child: ExcludeSemantics(
                        child: LayoutBuilder(
                          builder: (context, constraints) => FastingPath(
                            progress: progress,
                            height:
                                constraints.maxWidth *
                                FastingPathPainter.routeSize.height /
                                FastingPathPainter.routeSize.width,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _Detail(
                          icon: MambaIcons.timer,
                          label: FastingProtocol.nameFor(
                            session.protocolId,
                            session.target,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: MambaColors.border,
                        ),
                        _Detail(
                          icon: MambaIcons.target,
                          label: reached
                              ? '${goalHours}h goal'
                              : '${(progress * 100).round()}% of ${goalHours}h',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Fact(
                      label: 'Started',
                      value: _dayAndTime(session.startedAt),
                    ),
                    const Divider(),
                    _Fact(label: 'Ended', value: _dayAndTime(endedAt)),
                    const Divider(),
                    _Fact(
                      label: 'Eating window',
                      value:
                          'Until ${formatClockTime(eatingEnd)}'
                          '${eatingDay == 'Today' ? '' : ' ${eatingDay.toLowerCase()}'}',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: () => close(FastCompleteAction.backToToday),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Back to Today'),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => close(FastCompleteAction.logMeal),
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      textStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Log a meal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayAndTime(DateTime time) =>
      '${formatRelativeDay(time, now)}, ${formatClockTime(time)}';
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label});

  final MambaIcons icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MambaIcon(icon, size: 14, color: MambaColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: _secondary.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: _secondary.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: MambaColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
