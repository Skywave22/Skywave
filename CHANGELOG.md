# Changelogs - v2.6.0

### ✨ *New Features*
- 🎨 *Glassmorphic Glow Player Redesign* – The player's touch controls now use a frosted-glass + gradient-glow visual style: a gradient (blue → magenta) center play/pause button with a soft glow, new frosted "skip ±10s" buttons flanking it, a gradient-filled scrubber for the played portion, and restyled frosted Skip Intro/Outro/Recap pills. Desktop and TV control layouts are unchanged.
- ⬇️ *Download Queue Manager* – Downloads now go through a configurable queue:
  - **Simultaneous Downloads** setting (1–5 at once), backed by the native OS-level holding queue so the limit is enforced even while the app is backgrounded.
  - **Pause All / Resume All / Cancel All** controls (with a confirmation dialog for Cancel All) directly in the Downloads tab.
  - Setting is accessible from the Downloads tab and persists across restarts.
- 🧩 *Fully Customizable Home Screen* – New **Settings > Customize Home** screen:
  - Drag-to-reorder the built-in Home sections (Featured Carousel, Continue Watching, Synced Progress).
  - Show/hide any of those sections independently.
  - Choose a global card size (**Compact / Comfortable / Large**) applied across every Home row.
  - Choose a global card shape (**Auto / Always Portrait / Always Landscape**) instead of per-item auto-detection.
  - **Reset to Defaults** button to restore the original layout at any time.
  - Provider category rows (from your active extension) are unaffected — they always render after the built-in sections in their existing order.

### 🐞 *Bug Fixes (Android)*
- 🔒 *PiP media-control broadcast hardened* – The Picture-in-Picture play/pause/seek broadcast receiver was previously registered as `RECEIVER_EXPORTED` with no guard, meaning any other installed app could send it a forged broadcast and remote-control playback. It's now registered `RECEIVER_NOT_EXPORTED` on Android 13+, restricting delivery to this app's own PendingIntents only.
- 💥 *Fixed a rare PiP-mode crash* – `onPictureInPictureModeChanged` force-unwrapped `flutterEngine!!`, which could crash the app if the callback fired during activity teardown. It now safely no-ops if the engine reference is momentarily unavailable.
- 🧹 *Manifest cleanup* – Removed a redundant duplicate `xmlns:tools` namespace declaration in `AndroidManifest.xml`.

### ⚙️ Improvements
- All new functionality is additive and opt-in by default — every new setting defaults to the app's existing pre-upgrade behavior (default card density/shape/order match today's layout exactly; default download concurrency is 3), so nothing changes for existing users until they open the new customization screens.
- No changes were made to the underlying playback engines (`media_kit` / `video_view`/ExoPlayer), the JS extension runtime, or the torrent server — this release is a pure UI/UX and download-management upgrade.

---

# Changelogs - v2.5.0

### ✨ *New Features*
- 🔗 *Multi-tracker Integration* – Full synchronization support for **Trakt**, **Simkl**, **MyAnimeList (MAL)**, and **AniList** to keep your watch progress in sync across platforms.
- ⏭️ *Intro & Outro Skip* – Integrated **IntroDB** and **Anime Skip** databases to seamlessly skip intros and outros.
- 🖥️ *Desktop UI Redesign* – A brand new, responsive desktop layout optimized for large screens, keyboards, and mouse interactions.
- 📺 *TV UI & D-Pad Navigation* – Redesigned television interface with full D-Pad navigation support for smooth remote-control-driven browsing.
- 🎬 *Player UI Redesign* – Modernized media player interface with clean controls, quick-access settings, and a sleek visual style.

---

### 🐞 *Bug Fixes*
- 🛠️ Fixed various minor bugs, including playback errors, provider resolving, and UI crashes.

---

### ⚙️ Improvements & Performance
- ⚡ *Performance Optimizations* – Faster list rendering, improved image caching, and general responsiveness improvements across the entire app.

---
