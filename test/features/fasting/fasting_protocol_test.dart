import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/fasting_protocol.dart';

void main() {
  group('FastingProtocol', () {
    test('presets split 24 hours', () {
      expect(FastingProtocol.gentle.name, '12:12');
      expect(FastingProtocol.popular.name, '16:8');
      expect(FastingProtocol.advanced.name, '18:6');
      for (final preset in FastingProtocol.presets) {
        expect(preset.fastingHours + preset.eatingHours, 24);
        expect(preset.target, Duration(hours: preset.fastingHours));
        expect(preset.isCustom, isFalse);
      }
    });

    test('custom protocol derives its name and target', () {
      final custom = FastingProtocol.custom(14);
      expect(custom.name, '14:10');
      expect(custom.eatingHours, 10);
      expect(custom.target, const Duration(hours: 14));
      expect(custom.isCustom, isTrue);
    });

    test('presetById finds presets only', () {
      expect(FastingProtocol.presetById('18:6'), FastingProtocol.advanced);
      expect(FastingProtocol.presetById('custom'), isNull);
      expect(FastingProtocol.presetById('nope'), isNull);
    });
  });

  group('ProtocolSettings', () {
    test('defaults to 16:8 with no custom protocol', () {
      expect(ProtocolSettings.defaults.selected, FastingProtocol.popular);
      expect(ProtocolSettings.defaults.custom, isNull);
    });

    test('selects the custom protocol when hours exist', () {
      const settings = ProtocolSettings(
        selectedId: 'custom',
        customFastingHours: 20,
      );
      expect(settings.selected, FastingProtocol.custom(20));
    });

    test('falls back to 16:8 for unknown ids or missing custom hours', () {
      expect(
        const ProtocolSettings(selectedId: 'custom').selected,
        FastingProtocol.popular,
      );
      expect(
        const ProtocolSettings(selectedId: '20:4').selected,
        FastingProtocol.popular,
      );
    });

    test('keeps custom hours when switching to a preset', () {
      const settings = ProtocolSettings(
        selectedId: 'custom',
        customFastingHours: 14,
      );
      final switched = settings.copyWith(selectedId: '12:12');
      expect(switched.selected, FastingProtocol.gentle);
      expect(switched.custom, FastingProtocol.custom(14));
    });

    test('json round trip', () {
      const settings = ProtocolSettings(
        selectedId: 'custom',
        customFastingHours: 17,
      );
      expect(ProtocolSettings.fromJson(settings.toJson()), settings);
    });

    test('fromJson drops out of range custom hours', () {
      final settings = ProtocolSettings.fromJson({
        'selectedId': 'custom',
        'customFastingHours': 30,
      });
      expect(settings.custom, isNull);
      expect(settings.selected, FastingProtocol.popular);
    });
  });
}
