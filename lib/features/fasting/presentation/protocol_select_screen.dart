import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/screen_header.dart';
import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/fasting_protocol.dart';
import 'custom_protocol_screen.dart';
import 'protocol_controller.dart';
import 'widgets/fasting_window_bar.dart';

const _onSelected = Color(0xFFE3D6EF);

/// Tag and description of a preset, which the domain identifies by id.
(String, String) presetText(AppLocalizations l10n, FastingProtocol preset) {
  return switch (preset.id) {
    '12:12' => (l10n.protocolTagGentle, l10n.protocolDescriptionGentle),
    '18:6' => (l10n.protocolTagAdvanced, l10n.protocolDescriptionAdvanced),
    _ => (l10n.protocolTagPopular, l10n.protocolDescriptionPopular),
  };
}

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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.protocolSaveError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings =
        ref.watch(protocolControllerProvider).value ??
        ProtocolSettings.defaults;
    final selected = _selected ?? settings.selected;
    final custom = _pendingCustom ?? settings.custom;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.findYourRhythm, showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                children: [
                  Text(
                    l10n.protocolLead,
                    style: const TextStyle(
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
                    name: custom?.name ?? l10n.protocolCustomName,
                    description: custom == null
                        ? l10n.protocolCustomEmptyDescription
                        : l10n.protocolCustomDescription,
                    selected: selected.isCustom,
                    semanticsLabel: custom == null
                        ? l10n.protocolSemanticsCustomEmpty
                        : l10n.protocolSemanticsCustom(custom.name),
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
                  child: Text(_saving ? l10n.saving : l10n.saveProtocol),
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
    final l10n = AppLocalizations.of(context)!;
    final (tag, description) = presetText(l10n, protocol);
    final secondary = selected ? _onSelected : MambaColors.textSecondary;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: l10n.protocolSemanticsPreset(protocol.name, tag),
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
                        tag,
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
                  description,
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
                  fastingLabel: l10n.fastHoursShort(protocol.fastingHours),
                  eatingLabel: l10n.eatingHoursLabel(protocol.eatingHours),
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
