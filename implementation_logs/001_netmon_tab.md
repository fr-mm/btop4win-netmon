# Walkthrough: Network Monitor Tab in btop4win

**Date:** 2026-04-10  
**Scope:** Add full-screen Network Monitor tab with Tab key switching

## Summary

Added a full-screen **Network Monitor** tab to btop4win, switchable via the `Tab` key. The default system monitor view (cpu/mem/net/proc boxes) is untouched. The new tab takes the entire terminal and shows placeholder text, ready for future network monitoring features.

## Files Changed

### `src/btop_shared.hpp`
- Added `Global::active_tab` — integer tracking current tab (0=default, 1=netmon)
- Added `NetMon` namespace — declares `box`, `shown`, `redraw`, and `draw()` interface

### `src/btop_draw.cpp`
- Added `NetMon` namespace implementation with `draw()` that renders a full-screen bordered box with centered placeholder text
- Modified `calcSizes()` to branch on `active_tab`:
  - Tab 0: original 4-box layout (unchanged)
  - Tab 1: full-screen NetMon box, all default boxes hidden

### `src/btop.cpp`
- Defined `Global::active_tab = 0`
- Wrapped the runner thread's collect/draw loop in `if (active_tab == 0)` with an `else if (active_tab == 1)` for NetMon
- Guarded initial box outline print to output the correct tab's boxes

### `src/btop_input.cpp`
- Added `Tab` key handler as the first global input action — toggles `active_tab` between 0 and 1, recalculates sizes, and triggers a full redraw

## How It Works

1. Press **Tab** on the default view → switches to full-screen "Network Monitor" tab
2. Press **Tab** again → returns to the default 4-box system monitor
3. **q** quits from either tab
4. All existing keybindings (1-4, m, escape, etc.) work normally on the default tab

## Build Verification

- Built with MSBuild (VS2019 BuildTools, v142 toolset, Debug x64)
- All files compiled cleanly, linked successfully
- Binary at `x64\Debug\btop4win.exe`

## Design Decisions

- **Tab system is orthogonal to the box system** — zero impact on existing layout, config, or collect logic
- **No new source files** — changes are minimal additions to existing files, following upstream patterns
- **NetMon uses `net_box` theme color** for its border to stay visually consistent
- **`Tab` key was unused** — it was recognized in `Key_escapes` but never processed, making it a clean choice
