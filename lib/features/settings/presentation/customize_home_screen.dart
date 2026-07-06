import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skystream/l10n/generated/app_localizations.dart';
import '../../home/presentation/home_customization_provider.dart';
import 'widgets/settings_widgets.dart';

/// Settings > Customize Home — lets the user reorder / hide the built-in
/// home-screen sections (hero carousel, Continue Watching, synced progress)
/// and choose a global card density / shape for every media row on Home.
///
/// This screen only edits [HomeCustomizationNotifier] state; it doesn't
/// touch how home data is fetched or how plugins provide content — purely a
/// presentation-layer preference, applied live via [homeCustomizationProvider]
/// watchers in `home_screen.dart` and `media_horizontal_list.dart`.
class CustomizeHomeScreen extends ConsumerWidget {
  const CustomizeHomeScreen({super.key});

  String _sectionLabel(HomeSectionKind kind, AppLocalizations l10n) {
    return switch (kind) {
      HomeSectionKind.heroCarousel => l10n.sectionHeroCarousel,
      HomeSectionKind.continueWatching => l10n.sectionContinueWatching,
      HomeSectionKind.syncedProgress => l10n.sectionSyncedProgress,
    };
  }

  IconData _sectionIcon(HomeSectionKind kind) {
    return switch (kind) {
      HomeSectionKind.heroCarousel => Icons.view_carousel_rounded,
      HomeSectionKind.continueWatching => Icons.history_rounded,
      HomeSectionKind.syncedProgress => Icons.sync_rounded,
    };
  }

  String _densityLabel(HomeCardDensity density, AppLocalizations l10n) {
    return switch (density) {
      HomeCardDensity.compact => l10n.cardDensityCompact,
      HomeCardDensity.comfortable => l10n.cardDensityComfortable,
      HomeCardDensity.large => l10n.cardDensityLarge,
    };
  }

  String _styleLabel(HomeCardStyle style, AppLocalizations l10n) {
    return switch (style) {
      HomeCardStyle.asPublished => l10n.cardShapeAsPublished,
      HomeCardStyle.portrait => l10n.cardShapePortrait,
      HomeCardStyle.landscape => l10n.cardShapeLandscape,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final customization = ref.watch(homeCustomizationProvider);
    final notifier = ref.read(homeCustomizationProvider.notifier);

    // Sections not in sectionOrder are "hidden" but still need a toggle row
    // so the user can turn them back on. Build the full list in a stable
    // order: visible sections first (in their saved order), then hidden
    // ones (in enum declaration order) so nothing disappears from the UI.
    final hiddenSections = HomeSectionKind.values
        .where((k) => !customization.sectionOrder.contains(k))
        .toList();
    final allRows = [...customization.sectionOrder, ...hiddenSections];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customizeHome)),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          SettingsGroup(
            title: l10n.homeSections,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.homeSectionsSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allRows.length,
                onReorder: (oldIndex, newIndex) {
                  // Reordering is only meaningful within the visible
                  // (non-hidden) prefix — hidden rows are always pinned
                  // after visible ones, so translate indices accordingly.
                  final visibleCount = customization.sectionOrder.length;
                  if (oldIndex >= visibleCount || newIndex > visibleCount) {
                    return;
                  }
                  notifier.reorder(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final kind = allRows[index];
                  final isVisible = customization.isVisible(kind);
                  return ListTile(
                    key: ValueKey(kind),
                    leading: Icon(_sectionIcon(kind)),
                    title: Text(_sectionLabel(kind, l10n)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: isVisible,
                          onChanged: (v) => notifier.setVisible(kind, v),
                        ),
                        const SizedBox(width: 4),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.drag_handle_rounded),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SettingsGroup(
            title: l10n.cardAppearance,
            children: [
              SettingsTile(
                icon: Icons.photo_size_select_large_rounded,
                title: l10n.cardDensity,
                subtitle: _densityLabel(customization.cardDensity, l10n),
                onTap: () => _showDensityPicker(context, ref, l10n),
              ),
              SettingsTile(
                icon: Icons.crop_portrait_rounded,
                title: l10n.cardShape,
                subtitle: _styleLabel(customization.cardStyle, l10n),
                onTap: () => _showStylePicker(context, ref, l10n),
                isLast: true,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => notifier.resetToDefaults(),
              icon: const Icon(Icons.restore_rounded),
              label: Text(l10n.resetToDefaults),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDensityPicker(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final current = ref.read(homeCustomizationProvider).cardDensity;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.cardDensity),
        content: RadioGroup<HomeCardDensity>(
          groupValue: current,
          onChanged: (val) {
            if (val == null) return;
            ref.read(homeCustomizationProvider.notifier).setCardDensity(val);
            Navigator.pop<void>(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final density in HomeCardDensity.values)
                ListTile(
                  title: Text(_densityLabel(density, l10n)),
                  leading: Radio<HomeCardDensity>(value: density),
                  onTap: () {
                    ref
                        .read(homeCustomizationProvider.notifier)
                        .setCardDensity(density);
                    Navigator.pop<void>(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showStylePicker(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final current = ref.read(homeCustomizationProvider).cardStyle;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.cardShape),
        content: RadioGroup<HomeCardStyle>(
          groupValue: current,
          onChanged: (val) {
            if (val == null) return;
            ref.read(homeCustomizationProvider.notifier).setCardStyle(val);
            Navigator.pop<void>(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final style in HomeCardStyle.values)
                ListTile(
                  title: Text(_styleLabel(style, l10n)),
                  leading: Radio<HomeCardStyle>(value: style),
                  onTap: () {
                    ref
                        .read(homeCustomizationProvider.notifier)
                        .setCardStyle(style);
                    Navigator.pop<void>(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
