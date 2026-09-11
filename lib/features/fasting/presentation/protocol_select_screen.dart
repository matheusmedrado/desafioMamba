import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/screen_header.dart';
import '../../../app/theme.dart';
import '../domain/fasting_protocol.dart';
import 'custom_protocol_screen.dart';
import 'protocol_controller.dart';
import 'widgets/fasting_window_bar.dart';

const _onSelected = Color(0xFFE3D6EF);

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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Find your rhythm.', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                children: [
                  const Text(
                    'A fasting window that fits your day. Change it whenever '
                    'you need.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      height: 1.4,
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
                    name: custom?.name ?? 'Custom',
                    description: custom == null
                        ? 'Set your own fasting and eating hours.'
                        : 'Your own hours, tap to edit',
                    selected: selected.isCustom,
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
    required this.protocol,
    required this.selected,
    required this.onTap,
  });

  final FastingProtocol protocol;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final secondary = selected ? _onSelected : MambaColors.textSecondary;

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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      protocol.name,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1,
                        color: MambaColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      const _BrandDot(),
                    ],
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        protocol.tag,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: secondary,
                        ),
                      ),
                    ),
                    _CheckMark(selected: selected),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  protocol.description,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    height: 1.4,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 12),
                FastingWindowBar(
                  fastingHours: protocol.fastingHours,
                  fillColor: selected
                      ? MambaColors.textPrimary
                      : MambaColors.purple,
                  trackColor: MambaColors.surfaceElevated,
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
    required this.name,
    required this.description,
    required this.selected,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String name;
  final String description;
  final bool selected;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
            child: Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.66,
                    height: 1,
                    color: MambaColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (selected) ...[const SizedBox(width: 8), const _BrandDot()],
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: selected ? _onSelected : MambaColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                MambaIcon(
                  MambaIcons.chevronRight,
                  size: 20,
                  color: selected
                      ? MambaColors.textPrimary
                      : MambaColors.textSecondary,
                ),
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
          ? const Center(
              child: MambaIcon(
                MambaIcons.check,
                size: 14,
                color: MambaColors.purpleDeep,
                strokeWidth: 2.5,
              ),
            )
          : null,
    );
  }
}
