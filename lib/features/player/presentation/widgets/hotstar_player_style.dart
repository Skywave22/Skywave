import 'package:flutter/material.dart';

/// Visual + layout tokens for the player chrome.
///
/// This is the single source of truth for player colors, motion, gradients,
/// and the layout metrics that the chrome, subtitle offset, and floating
/// prompts all share — so nothing relies on magic numbers scattered across
/// widgets.
class HotstarPlayerStyle {
  // --- Colors ---
  static const Color background = Color(0xFF000000);
  static const Color panel = Color(0xFF05070B);
  static const Color panelElevated = Color(0xFF090D14);
  static const Color accent = Color(0xFF0A84FF);
  static const Color accentAlt = Color(0xFFDD3EFF);
  static const Color primaryText = Color(0xF2FFFFFF);
  static const Color secondaryText = Color(0xA6FFFFFF);
  static const Color mutedText = Color(0x73FFFFFF);
  static const Color divider = Color(0x1FFFFFFF);
  static const Color track = Color(0x55FFFFFF);
  static const Color trackInactive = Color(0x35FFFFFF);
  static const Color focus = Color(0x660A84FF);
  static const Color liveRed = Color(0xFFE53935);

  /// Marker on the scrubber for skip segments (intro / recap / outro). A warm
  /// amber so it reads clearly against the blue progress and grey track.
  static const Color skipSegment = Color(0xFFFFC107);

  // --- Motion ---
  static const Duration controlFadeDuration = Duration(milliseconds: 220);
  static const Duration fastMotionDuration = Duration(milliseconds: 160);
  static const Duration panelMotionDuration = Duration(milliseconds: 240);

  // --- Layout tokens ---
  /// Horizontal edge inset for the chrome on touch/desktop.
  static const double edgeInset = 20;

  /// Larger inset on TV to clear the overscan-unsafe border (~5% of edges
  /// is clipped on many TVs). Keeps controls and focus rings fully visible.
  static const double tvEdgeInset = 48;

  /// Approximate height of the bottom chrome (scrubber row + controls row +
  /// internal padding), excluding the safe-area bottom inset. Used to offset
  /// subtitles and to anchor floating prompts above the scrubber. The bottom
  /// bar itself is content-sized; this is a layout estimate, not a clamp.
  static const double bottomChromeHeight = 132;

  /// Focus-ring treatment shared by every focusable control so play/pause,
  /// seek, scrubber, action, and utility buttons look identical when focused.
  static const double focusScale = 1.04;

  // --- Gradients (const scrims, dark at the edge → transparent at center) ---
  static const LinearGradient topGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xCC000000), Color(0x66000000), Color(0x00000000)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient bottomGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xE6000000), Color(0x99000000), Color(0x00000000)],
    stops: [0.0, 0.5, 1.0],
  );

  // --- "Glow" redesign tokens ---------------------------------------------
  // Purely additive visual tokens for the glassmorphic-glow player skin.
  // Nothing above this section is modified so any code still reading the
  // original tokens keeps working unchanged.

  /// Diagonal accent -> accentAlt gradient used on the primary (center)
  /// play/pause button and other "hero" circular controls.
  static const LinearGradient glowButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentAlt],
  );

  /// Horizontal accent -> accentAlt gradient used to fill the scrubber's
  /// played portion.
  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accent, accentAlt],
  );

  /// Soft outer glow placed behind hero circular buttons (play/pause,
  /// skip-10) so they read clearly over bright video without a hard edge.
  static List<BoxShadow> glowShadow({double opacity = 0.55, double blur = 24}) {
    return [
      BoxShadow(
        color: accent.withValues(alpha: opacity * 0.6),
        blurRadius: blur,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: accentAlt.withValues(alpha: opacity * 0.4),
        blurRadius: blur * 1.4,
        spreadRadius: 0,
      ),
    ];
  }

  /// Frosted-glass fill used behind secondary circular buttons (skip-10,
  /// edge-rail cells) so they sit above the video without a flat black disc.
  static const Color glassFill = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
}
