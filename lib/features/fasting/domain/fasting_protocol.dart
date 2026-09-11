/// A fasting window inside a 24 hour day.
class FastingProtocol {
  const FastingProtocol._({
    required this.id,
    required this.fastingHours,
    required this.tag,
    required this.description,
  });

  /// Custom protocols always use this id. Their hours live in
  /// [ProtocolSettings.customFastingHours].
  static const customId = 'custom';
  static const minCustomFastingHours = 8;
  static const maxCustomFastingHours = 23;
  static const defaultCustomFastingHours = 14;

  static const gentle = FastingProtocol._(
    id: '12:12',
    fastingHours: 12,
    tag: 'Gentle',
    description: 'A gentle start. Skip late-night snacks and eat normally during the day.',
  );
  static const popular = FastingProtocol._(
    id: '16:8',
    fastingHours: 16,
    tag: 'Popular',
    description: 'Skip breakfast or dinner. The most common daily rhythm.',
  );
  static const advanced = FastingProtocol._(
    id: '18:6',
    fastingHours: 18,
    tag: 'Advanced',
    description: 'A tighter window for experienced fasters.',
  );

  static const presets = [gentle, popular, advanced];

  factory FastingProtocol.custom(int fastingHours) {
    assert(
      fastingHours >= minCustomFastingHours &&
          fastingHours <= maxCustomFastingHours,
      'custom fasting hours out of range: $fastingHours',
    );
    return FastingProtocol._(
      id: customId,
      fastingHours: fastingHours,
      tag: 'Custom',
      description: 'Your own hours.',
    );
  }

  static FastingProtocol? presetById(String id) {
    for (final preset in presets) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  /// Display name for a stored fast, such as `16:8`.
  static String nameFor(String protocolId, Duration target) {
    final preset = presetById(protocolId);
    if (preset != null) return preset.name;
    final fastingHours = target.inHours;
    return '$fastingHours:${24 - fastingHours}';
  }

  final String id;
  final int fastingHours;
  final String tag;
  final String description;

  int get eatingHours => 24 - fastingHours;
  Duration get target => Duration(hours: fastingHours);
  bool get isCustom => id == customId;

  /// Display name such as `16:8`.
  String get name => '$fastingHours:$eatingHours';

  @override
  bool operator ==(Object other) =>
      other is FastingProtocol &&
      other.id == id &&
      other.fastingHours == fastingHours;

  @override
  int get hashCode => Object.hash(id, fastingHours);

  @override
  String toString() => 'FastingProtocol($name)';
}

/// What the user chose, as persisted. Small enough to keep as one record.
class ProtocolSettings {
  const ProtocolSettings({required this.selectedId, this.customFastingHours});

  static const defaults = ProtocolSettings(selectedId: '16:8');

  final String selectedId;
  final int? customFastingHours;

  /// The custom protocol, if the user has ever defined one.
  FastingProtocol? get custom {
    final hours = customFastingHours;
    return hours == null ? null : FastingProtocol.custom(hours);
  }

  /// Falls back to the popular preset if the stored id is unknown or points
  /// to a custom protocol that no longer has hours.
  FastingProtocol get selected {
    if (selectedId == FastingProtocol.customId) {
      return custom ?? FastingProtocol.popular;
    }
    return FastingProtocol.presetById(selectedId) ?? FastingProtocol.popular;
  }

  ProtocolSettings copyWith({String? selectedId, int? customFastingHours}) {
    return ProtocolSettings(
      selectedId: selectedId ?? this.selectedId,
      customFastingHours: customFastingHours ?? this.customFastingHours,
    );
  }

  Map<String, Object?> toJson() => {
    'selectedId': selectedId,
    'customFastingHours': customFastingHours,
  };

  factory ProtocolSettings.fromJson(Map<String, Object?> json) {
    final hours = json['customFastingHours'] as int?;
    final validHours =
        hours != null &&
            hours >= FastingProtocol.minCustomFastingHours &&
            hours <= FastingProtocol.maxCustomFastingHours
        ? hours
        : null;
    return ProtocolSettings(
      selectedId: json['selectedId'] as String? ?? defaults.selectedId,
      customFastingHours: validHours,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProtocolSettings &&
      other.selectedId == selectedId &&
      other.customFastingHours == customFastingHours;

  @override
  int get hashCode => Object.hash(selectedId, customFastingHours);
}
