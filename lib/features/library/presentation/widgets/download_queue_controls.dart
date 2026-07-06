import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../downloads_provider.dart';

/// Queue-wide controls shown above the downloads list: Pause All / Resume
/// All / Cancel All, plus a "Simultaneous Downloads" selector that controls
/// how many downloads the native holding queue runs at once (1-5).
///
/// This widget is purely additive UI on top of the existing per-item
/// download flow — it doesn't change how individual downloads are enqueued
/// or tracked, only how many are allowed to run concurrently and whether the
/// whole queue can be paused/resumed/cancelled in one action.
class DownloadQueueControls extends ConsumerWidget {
  final bool hasActive;
  final bool hasPaused;

  const DownloadQueueControls({
    super.key,
    required this.hasActive,
    required this.hasPaused,
  });

  Future<void> _confirmCancelAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelAllDownloadsConfirmTitle),
        content: Text(l10n.cancelAllDownloadsConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.cancelAll),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(downloadsProvider.notifier).cancelAll();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final concurrency = ref.watch(downloadConcurrencyProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (hasActive)
                    _QueueActionChip(
                      icon: Icons.pause_rounded,
                      label: l10n.pauseAll,
                      onTap: () =>
                          ref.read(downloadsProvider.notifier).pauseAll(),
                    ),
                  if (hasPaused) ...[
                    const SizedBox(width: 8),
                    _QueueActionChip(
                      icon: Icons.play_arrow_rounded,
                      label: l10n.resumeAll,
                      onTap: () =>
                          ref.read(downloadsProvider.notifier).resumeAll(),
                    ),
                  ],
                  if (hasActive || hasPaused) ...[
                    const SizedBox(width: 8),
                    _QueueActionChip(
                      icon: Icons.close_rounded,
                      label: l10n.cancelAll,
                      isDestructive: true,
                      onTap: () => _confirmCancelAll(context, ref),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ConcurrencySelector(value: concurrency),
        ],
      ),
    );
  }
}

class _QueueActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _QueueActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.red
        : Theme.of(context).colorScheme.primary;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      onPressed: onTap,
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }
}

/// Compact popup that lets the user pick how many downloads run at once.
/// Shown as a small icon button so it doesn't compete for space with the
/// action chips on narrow screens.
class _ConcurrencySelector extends ConsumerWidget {
  final int value;

  const _ConcurrencySelector({required this.value});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: l10n.simultaneousDownloads,
      child: PopupMenuButton<int>(
        initialValue: value,
        onSelected: (v) =>
            ref.read(downloadConcurrencyProvider.notifier).setValue(v),
        itemBuilder: (context) => [
          for (final n in [1, 2, 3, 4, 5])
            PopupMenuItem<int>(
              value: n,
              child: Row(
                children: [
                  if (n == value)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Text(n == 1 ? '1 at a time' : '$n at a time'),
                ],
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, size: 16),
              const SizedBox(width: 6),
              Text(
                '$value',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
