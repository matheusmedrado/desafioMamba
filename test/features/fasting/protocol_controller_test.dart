import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_protocol.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/protocol_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  ProviderContainer newContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('starts with 16:8 when nothing is stored', () async {
    final container = newContainer();

    final settings = await container.read(protocolControllerProvider.future);
    expect(settings, ProtocolSettings.defaults);
    expect(container.read(selectedProtocolProvider), FastingProtocol.popular);
  });

  test('preset selection survives a restart', () async {
    final first = newContainer();
    await first.read(protocolControllerProvider.future);
    await first
        .read(protocolControllerProvider.notifier)
        .selectPreset(FastingProtocol.advanced);

    final second = newContainer();
    await second.read(protocolControllerProvider.future);

    expect(second.read(selectedProtocolProvider), FastingProtocol.advanced);
  });

  test('custom protocol survives a restart', () async {
    final first = newContainer();
    await first.read(protocolControllerProvider.future);
    await first.read(protocolControllerProvider.notifier).useCustom(20);

    final second = newContainer();
    await second.read(protocolControllerProvider.future);

    expect(second.read(selectedProtocolProvider), FastingProtocol.custom(20));
    expect(
      second.read(selectedProtocolProvider).target,
      const Duration(hours: 20),
    );
  });

  test('custom hours are kept after switching back to a preset', () async {
    final container = newContainer();
    await container.read(protocolControllerProvider.future);
    final controller = container.read(protocolControllerProvider.notifier);

    await controller.useCustom(15);
    await controller.selectPreset(FastingProtocol.gentle);

    final settings = container.read(protocolControllerProvider).value!;
    expect(settings.selected, FastingProtocol.gentle);
    expect(settings.custom, FastingProtocol.custom(15));
  });
}
