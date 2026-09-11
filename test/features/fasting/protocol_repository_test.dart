import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/data/protocol_repository.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_protocol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  ProtocolSettings settingsFor(FastingProtocol preset) =>
      ProtocolSettings.defaults.copyWith(selectedId: preset.id);

  test('falls back to the defaults when nothing is stored', () async {
    expect(
      await ProtocolRepository(SharedPreferencesAsync()).load(),
      ProtocolSettings.defaults,
    );
  });

  test('each account keeps its own protocol', () async {
    final prefs = SharedPreferencesAsync();
    final mine = ProtocolRepository(prefs, userId: 'user-1');
    final other = ProtocolRepository(prefs, userId: 'user-2');

    await mine.save(settingsFor(FastingProtocol.advanced));

    expect((await mine.load()).selected, FastingProtocol.advanced);
    expect((await other.load()).selected, ProtocolSettings.defaults.selected);
  });

  test('a protocol saved before accounts goes to the first account', () async {
    final prefs = SharedPreferencesAsync();
    await ProtocolRepository(prefs).save(settingsFor(FastingProtocol.gentle));

    final first = ProtocolRepository(prefs, userId: 'user-1');
    expect((await first.load()).selected, FastingProtocol.gentle);
    expect(await prefs.getString(ProtocolRepository.baseKey), isNull);

    final second = ProtocolRepository(prefs, userId: 'user-2');
    expect((await second.load()).selected, ProtocolSettings.defaults.selected);
  });
}
