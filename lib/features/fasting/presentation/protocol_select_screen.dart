import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../domain/fasting_protocol.dart';
import 'custom_protocol_screen.dart';
import 'protocol_controller.dart';
import 'widgets/fasting_window_bar.dart';

/// Pick one of the presets or open the custom editor.
///
/// Preset choices are saved when the user taps Save. A custom protocol is
/// saved as soon as the editor returns, matching the mockup flow.
class ProtocolSelectScreen extends ConsumerStatefulWidget {
  const ProtocolSelectScreen({super.key});

  @override
  ConsumerState<ProtocolSelectScreen> createState() =>
      _ProtocolSelectScreenState();
}

class _ProtocolSelectScreenState extends ConsumerState<ProtocolSelectScreen> {
  FastingProtocol? _selected;
  var _saving = false;

  Future<void> _openCustom(FastingProtocol? current) async {
    final hours = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            CustomProtocolScreen(initialFastingHours: current?.fastingHours),
      ),
    );
    if (hours == null || !mounted) return;
    await _persist(
      () => ref.read(protocolControllerProvider.notifier).useCustom(hours),
    );
  }

  Future<void> _save(FastingProtocol protocol) async {
    await _persist(
      () =>
          ref.read(protocolControllerProvider.notifier).selectPreset(protocol),
    );
  }

  Future<void> _persist(Future<void> Function() action) async {
    setState(() => _saving = true);
    try {
      await action();
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
    final custom = settings.custom;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Find your rhythm.')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                children: [
                  Text(
                    'A fasting window that fits your day. Change it whenever '
                    'you need.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: MambaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final preset in FastingProtocol.presets) ...[
                    _ProtocolOption(
                      protocol: preset,
                      selected: selected == preset,
                      onTap: () => setState(() => _selected = preset),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _CustomOption(
                    custom: custom,
                    selected: selected.isCustom,
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
                  onPressed: _saving || selected.isCustom
                      ? null
                      : () => _save(selected),
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
    required this.protocol,
    required this.selected,
    required this.onTap,
  });

  final FastingProtocol protocol;
  final bool selected;
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
      label: '${protocol.name}, ${protocol.tag}',
      child: Material(
        color: selected ? MambaColors.purpleDeep : MambaColors.surface,
        borderRadius: BorderRadius.circular(MambaRadius.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MambaRadius.medium),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      protocol.name,
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
                    Text(
                      protocol.tag,
                      style: textTheme.labelSmall?.copyWith(color: secondary),
                    ),
                    const Spacer(),
                    _CheckMark(selected: selected),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  protocol.description,
                  style: textTheme.bodySmall?.copyWith(color: secondary),
                ),
                const SizedBox(height: 12),
                FastingWindowBar(
                  fastingHours: protocol.fastingHours,
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

class _CustomOption extends StatelessWidget {
  const _CustomOption({
    required this.custom,
    required this.selected,
    required this.onTap,
  });

  final FastingProtocol? custom;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final custom = this.custom;
    final secondary = selected
        ? const Color(0xFFE3D6EF)
        : MambaColors.textSecondary;

    return Semantics(
      button: true,
      label: custom == null
          ? 'Custom protocol, set your own hours'
          : 'Custom protocol ${custom.name}, tap to edit',
      child: Material(
        color: selected ? MambaColors.purpleDeep : MambaColors.surface,
        borderRadius: BorderRadius.circular(MambaRadius.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MambaRadius.medium),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      custom?.name ?? 'Custom',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      const _BrandDot(),
                    ],
                    const SizedBox(width: 10),
                    Text(
                      custom == null
                          ? 'Set your own hours'
                          : 'Custom, tap to edit',
                      style: textTheme.labelSmall?.copyWith(color: secondary),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: secondary),
                  ],
                ),
                if (custom != null) ...[
                  const SizedBox(height: 12),
                  FastingWindowBar(
                    fastingHours: custom.fastingHours,
                    fillColor: selected
                        ? MambaColors.textPrimary
                        : MambaColors.purple,
                    trackColor: selected
                        ? MambaColors.purple.withValues(alpha: 0.35)
                        : MambaColors.surfaceElevated,
                    eatingLabelColor: secondary,
                  ),
                ],
              ],
            ),
          ),
        ),
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
