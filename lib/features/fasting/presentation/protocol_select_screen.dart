import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../domain/fasting_protocol.dart';
import 'custom_protocol_screen.dart';
import 'protocol_controller.dart';
import 'widgets/fasting_window_bar.dart';

/// Pick one of the presets or define a custom protocol.
///
/// Nothing is persisted until the user taps Save. The custom editor only
/// returns the chosen hours and marks the custom option as selected.
class ProtocolSelectScreen extends ConsumerStatefulWidget {
  const ProtocolSelectScreen({super.key});

  @override
  ConsumerState<ProtocolSelectScreen> createState() =>
      _ProtocolSelectScreenState();
}

class _ProtocolSelectScreenState extends ConsumerState<ProtocolSelectScreen> {
  /// Selection made on this screen. Null means "whatever is saved".
  FastingProtocol? _selected;

  /// Custom hours chosen in the editor during this visit, not yet saved.
  FastingProtocol? _pendingCustom;

  var _saving = false;

  Future<void> _openCustom(FastingProtocol? current) async {
    final hours = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            CustomProtocolScreen(initialFastingHours: current?.fastingHours),
      ),
    );
    if (hours == null || !mounted) return;
    setState(() {
      _pendingCustom = FastingProtocol.custom(hours);
      _selected = _pendingCustom;
    });
  }

  Future<void> _save(FastingProtocol protocol) async {
    setState(() => _saving = true);
    try {
      final controller = ref.read(protocolControllerProvider.notifier);
      if (protocol.isCustom) {
        await controller.useCustom(protocol.fastingHours);
      } else {
        await controller.selectPreset(protocol);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the protocol. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(protocolControllerProvider).value ??
        ProtocolSettings.defaults;
    final selected = _selected ?? settings.selected;
    final custom = _pendingCustom ?? settings.custom;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Find your rhythm.')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  Text(
                    'A fasting window that fits your day. Change it whenever '
                    'you need.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: MambaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final preset in FastingProtocol.presets) ...[
                    _ProtocolOption(
                      name: preset.name,
                      tag: preset.tag,
                      description: preset.description,
                      fastingHours: preset.fastingHours,
                      selected: selected == preset,
                      trailing: _CheckMark(selected: selected == preset),
                      semanticsLabel: '${preset.name}, ${preset.tag}',
                      onTap: () => setState(() => _selected = preset),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const _SectionDivider(label: 'Or set your own'),
                  const SizedBox(height: 10),
                  _ProtocolOption(
                    name: custom?.name ?? 'Custom',
                    tag: custom == null ? 'Custom' : 'Custom, tap to edit',
                    description: custom == null
                        ? 'Set your own fasting and eating hours.'
                        : 'Your own hours.',
                    fastingHours:
                        custom?.fastingHours ??
                        FastingProtocol.defaultCustomFastingHours,
                    selected: selected.isCustom,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: selected.isCustom
                          ? MambaColors.textPrimary
                          : MambaColors.textSecondary,
                    ),
                    semanticsLabel: custom == null
                        ? 'Custom protocol, set your own hours'
                        : 'Custom protocol ${custom.name}, tap to edit',
                    onTap: () => _openCustom(custom),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: MambaColors.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: FilledButton(
                  onPressed: _saving ? null : () => _save(selected),
                  child: Text(_saving ? 'Saving...' : 'Save protocol'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtocolOption extends StatelessWidget {
  const _ProtocolOption({
    required this.name,
    required this.tag,
    required this.description,
    required this.fastingHours,
    required this.selected,
    required this.trailing,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String name;
  final String tag;
  final String description;
  final int fastingHours;
  final bool selected;
  final Widget trailing;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = selected
        ? const Color(0xFFE3D6EF)
        : MambaColors.textSecondary;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: semanticsLabel,
      child: Material(
        color: selected ? MambaColors.purpleDeep : MambaColors.surface,
        borderRadius: BorderRadius.circular(MambaRadius.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MambaRadius.medium),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 34,
                        letterSpacing: -1,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      const _BrandDot(),
                    ],
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tag,
                        style: textTheme.labelSmall?.copyWith(color: secondary),
                      ),
                    ),
                    trailing,
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(color: secondary),
                ),
                const SizedBox(height: 12),
                FastingWindowBar(
                  fastingHours: fastingHours,
                  fillColor: selected
                      ? MambaColors.textPrimary
                      : MambaColors.purple,
                  trackColor: selected
                      ? MambaColors.purple.withValues(alpha: 0.35)
                      : MambaColors.surfaceElevated,
                  eatingLabelColor: secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin rule with a label, separating the presets from the custom option.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _BrandDot extends StatelessWidget {
  const _BrandDot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 6,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MambaColors.yellow,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? MambaColors.textPrimary : null,
        border: selected
            ? null
            : Border.all(color: MambaColors.textSecondary, width: 1.5),
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: MambaColors.purpleDeep)
          : null,
    );
  }
}
