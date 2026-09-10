import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/protocol_repository.dart';
import '../domain/fasting_protocol.dart';

class ProtocolController extends AsyncNotifier<ProtocolSettings> {
  @override
  Future<ProtocolSettings> build() {
    return ref.watch(protocolRepositoryProvider).load();
  }

  Future<void> selectPreset(FastingProtocol preset) async {
    assert(!preset.isCustom, 'use useCustom for custom protocols');
    await _save(_current.copyWith(selectedId: preset.id));
  }

  /// Stores the custom hours and makes the custom protocol the selected one.
  Future<void> useCustom(int fastingHours) async {
    await _save(
      _current.copyWith(
        selectedId: FastingProtocol.customId,
        customFastingHours: fastingHours,
      ),
    );
  }

  ProtocolSettings get _current => state.value ?? ProtocolSettings.defaults;

  Future<void> _save(ProtocolSettings settings) async {
    await ref.read(protocolRepositoryProvider).save(settings);
    state = AsyncData(settings);
  }
}

final protocolControllerProvider =
    AsyncNotifierProvider<ProtocolController, ProtocolSettings>(
      ProtocolController.new,
    );

/// The protocol the next fast will use. Defaults to 16:8 while loading.
final selectedProtocolProvider = Provider<FastingProtocol>((ref) {
  return ref.watch(protocolControllerProvider).value?.selected ??
      ProtocolSettings.defaults.selected;
});
