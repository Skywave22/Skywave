import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/settings_repository.dart';

part 'home_customization_provider.g.dart';

/// Built-in home-screen sections that can be reordered / hidden independent
/// of the dynamic per-provider category rows (e.g. "Latest", "Trending" from
/// a plugin, which are always appended after these in provider order).
enum HomeSectionKind { heroCarousel, continueWatching, syncedProgress }

extension HomeSectionKindLabel on HomeSectionKind {
  /// Stable string id persisted to storage — do not rename existing values,
  /// only add new ones, so existing users' saved order doesn't break.
  String get storageId => switch (this) {
    HomeSectionKind.heroCarousel => 'hero_carousel',
    HomeSectionKind.continueWatching => 'continue_watching',
    HomeSectionKind.syncedProgress => 'synced_progress',
  };

  static HomeSectionKind? fromStorageId(String id) {
    for (final kind in HomeSectionKind.values) {
      if (kind.storageId == id) return kind;
    }
    return null;
  }
}

/// Visual density for horizontal media card rows on Home. Applies to every
/// row (Continue Watching, provider categories, etc.) via
/// [HomeCardDensity.scale] so it's one setting instead of per-row config.
enum HomeCardDensity {
  compact,
  comfortable,
  large;

  /// Multiplier applied to the existing base card width used throughout the
  /// home/explore card widgets (e.g. 130.0 on mobile, 200.0 on desktop).
  /// 1.0 keeps today's default sizing exactly as-is (comfortable).
  double get scale => switch (this) {
    HomeCardDensity.compact => 0.8,
    HomeCardDensity.comfortable => 1.0,
    HomeCardDensity.large => 1.25,
  };
}

/// Poster shape preference for media cards. "asPublished" keeps the existing
/// per-item portrait/landscape auto-detection (today's behavior); the other
/// two force every card in a row to one shape for a more uniform grid.
enum HomeCardStyle { asPublished, portrait, landscape }

class HomeCustomization {
  /// Ordered list of built-in section kinds. Sections not present are
  /// treated as hidden. Dynamic provider category rows always render after
  /// all built-in sections, in the provider's own order — they aren't part
  /// of this list since their set changes per-provider/session.
  final List<HomeSectionKind> sectionOrder;
  final HomeCardDensity cardDensity;
  final HomeCardStyle cardStyle;

  const HomeCustomization({
    this.sectionOrder = const [
      HomeSectionKind.heroCarousel,
      HomeSectionKind.continueWatching,
      HomeSectionKind.syncedProgress,
    ],
    this.cardDensity = HomeCardDensity.comfortable,
    this.cardStyle = HomeCardStyle.asPublished,
  });

  bool isVisible(HomeSectionKind kind) => sectionOrder.contains(kind);

  HomeCustomization copyWith({
    List<HomeSectionKind>? sectionOrder,
    HomeCardDensity? cardDensity,
    HomeCardStyle? cardStyle,
  }) {
    return HomeCustomization(
      sectionOrder: sectionOrder ?? this.sectionOrder,
      cardDensity: cardDensity ?? this.cardDensity,
      cardStyle: cardStyle ?? this.cardStyle,
    );
  }

  Map<String, dynamic> toJson() => {
    'sectionOrder': sectionOrder.map((k) => k.storageId).toList(),
    'cardDensity': cardDensity.name,
    'cardStyle': cardStyle.name,
  };

  factory HomeCustomization.fromJson(Map<String, dynamic> json) {
    final rawOrder = (json['sectionOrder'] as List<dynamic>?) ?? const [];
    final order = rawOrder
        .map((e) => HomeSectionKindLabel.fromStorageId(e.toString()))
        .whereType<HomeSectionKind>()
        .toList();

    final density = HomeCardDensity.values.firstWhere(
      (d) => d.name == json['cardDensity'],
      orElse: () => HomeCardDensity.comfortable,
    );
    final style = HomeCardStyle.values.firstWhere(
      (s) => s.name == json['cardStyle'],
      orElse: () => HomeCardStyle.asPublished,
    );

    return HomeCustomization(
      // Fall back to the full default order if storage had an empty/corrupt
      // list, so a parsing hiccup can't accidentally hide the whole home
      // screen.
      sectionOrder: order.isEmpty
          ? const [
              HomeSectionKind.heroCarousel,
              HomeSectionKind.continueWatching,
              HomeSectionKind.syncedProgress,
            ]
          : order,
      cardDensity: density,
      cardStyle: style,
    );
  }
}

@Riverpod(keepAlive: true)
class HomeCustomizationNotifier extends _$HomeCustomizationNotifier {
  static const _storageKey = 'home_customization_v1';

  @override
  HomeCustomization build() {
    final repository = ref.watch(settingsRepositoryProvider);
    final raw = repository.getPlayerSetting<String>(_storageKey);
    if (raw == null || raw.isEmpty) return const HomeCustomization();
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return HomeCustomization.fromJson(decoded);
    } catch (_) {
      return const HomeCustomization();
    }
  }

  Future<void> _persist(HomeCustomization value) async {
    state = value;
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setPlayerSetting(_storageKey, jsonEncode(value.toJson()));
  }

  /// Moves the section at [oldIndex] to [newIndex] within the visible
  /// section order (used by the reorderable list in Settings).
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = List<HomeSectionKind>.from(state.sectionOrder);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await _persist(state.copyWith(sectionOrder: list));
  }

  /// Shows or hides a built-in section. Hiding removes it from
  /// [HomeCustomization.sectionOrder]; showing re-appends it at the end so
  /// re-enabling a section doesn't require remembering its old position.
  Future<void> setVisible(HomeSectionKind kind, bool visible) async {
    final list = List<HomeSectionKind>.from(state.sectionOrder);
    if (visible) {
      if (!list.contains(kind)) list.add(kind);
    } else {
      list.remove(kind);
    }
    await _persist(state.copyWith(sectionOrder: list));
  }

  Future<void> setCardDensity(HomeCardDensity density) async {
    await _persist(state.copyWith(cardDensity: density));
  }

  Future<void> setCardStyle(HomeCardStyle style) async {
    await _persist(state.copyWith(cardStyle: style));
  }

  Future<void> resetToDefaults() async {
    await _persist(const HomeCustomization());
  }
}
