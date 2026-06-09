# Pride Dashboard Development Spec

## Release Status

Version 1 is a private sideload Garmin Connect IQ watch face for:

- Venu Sq 2: `venusq2`
- Venu Sq 2 Music: `venusq2m`

The design was tuned against the Windows Garmin simulator on 2026-06-08.

Version 2 development started from the approved v1 release point. The first v2 target expansion adds:

- Venu X1: `venux1`
- Device-specific generated artwork for the 448x486 X1 display
- Runtime layout scaling from the approved 320x360 Venu Sq 2 geometry
- Initial Windows simulator smoke checks for `venusq2` and `venux1`

## V1 Product Intent

Pride Dashboard should show off a full-screen Progress Pride background while staying useful as a daily watch face. The face favors a bright expressive canvas with a small number of glanceable fields rather than a dense utility dashboard.

V1 priorities:

- Time remains the primary read target.
- Date is visible at the top.
- Four secondary metrics sit in a compact 2x2 grid.
- The Pride artwork fills the entire 320x360 display.
- No opaque cards or boxes cover the background in active mode.
- Always-on mode is simplified and dimmer.

## Device Target

- Venu Sq 2 canvas: 320 x 360
- Venu X1 canvas: 448 x 486
- Shape: rectangular
- Display: AMOLED
- Minimum API: 5.0.0
- Supported product ids: `venusq2`, `venusq2m`, `venux1`

## V1 Visual Design

Active mode:

- Full-screen generated Progress Pride bitmap.
- Diagonal/waved bands so the background has motion and avoids plain horizontal striping.
- Top date, large centered digital time, small AM/PM suffix in 12-hour mode.
- Thin segmented rainbow divider under the time.
- 2x2 transparent metric layout.
- Metric rows have no background boxes.
- Metric text uses shadows instead of panels for contrast.
- Icons are hand-drawn in Monkey C with simple line/shape primitives.

Final active data slots:

- Steps
- Heart rate
- Battery percentage
- Calories

The current v1 look intentionally uses Garmin built-in fonts. Custom bitmap font work is deferred to v2.

## Typography

Current active-mode choices:

- Date: `Graphics.FONT_SMALL`
- Time: `Graphics.FONT_NUMBER_MEDIUM`
- AM/PM: `Graphics.FONT_XTINY`
- Metric values: `Graphics.FONT_SMALL`

Text contrast is handled with 2px black shadow offsets over the full-color bitmap. This avoids covering the Pride background with dark UI cards.

## Data Behavior

Data source helpers live in `source/DataModel.mc`.

Fallback behavior:

- Missing numeric metric: `--`
- Steps: compact number formatting
- Battery: percent suffix
- Low battery: warning accent color at or below 15%

The top bar does not duplicate battery. Battery appears only in the metric grid.

## Settings

V1 exposes:

- 12h / 24h time format
- Show seconds
- Show date
- Show steps
- Show battery
- Show heart rate
- Show calories
- Primary text color
- Secondary text color

Fixed in v1:

- Background art
- Rainbow/accent palette
- Low-battery warning color
- Metric slot order

## Always-On Mode

Always-on mode uses:

- Dimmed generated Pride background
- Time
- Date
- Minute-based positional offset to reduce static burn-in risk

The metric grid is hidden in always-on mode.

## Project Structure

Core files:

- `manifest.xml`
- `monkey.jungle`
- `source/PrideDashboardApp.mc`
- `source/PrideDashboardView.mc`
- `source/DataModel.mc`
- `source/Format.mc`
- `source/Theme.mc`
- `resources/properties.xml`
- `resources/strings/strings.xml`
- `resources/drawables/drawables.xml`
- `scripts/generate_assets.js`
- `scripts/build.sh`

Generated assets:

- `resources/drawables/pride_bg_active.png`
- `resources/drawables/pride_bg_aod.png`
- `resources/drawables/launcher_icon.png`
- `resources-venux1/drawables/pride_bg_active.png`
- `resources-venux1/drawables/pride_bg_aod.png`
- `resources-venux1/drawables/launcher_icon.png`

Build outputs are generated under `build/` and ignored by git.

## Build

Use sequential builds:

```sh
scripts/build-release.sh
```

Expected output:

```text
build/PrideDashboard-venusq2.prg
build/PrideDashboard-venusq2m.prg
build/PrideDashboard-venux1.prg
```

The build script uses a lock file because parallel `monkeyc` invocations produced intermittent critical errors during development.

See `docs/TOOLCHAIN.md` for Windows/WSL SDK paths and simulator notes.

## V2 Simulation Notes

Initial v2 simulator smoke checks were run from WSL through the Windows Garmin SDK helpers:

```sh
scripts/run-windows-simulator.sh venux1
scripts/run-windows-simulator.sh venusq2
```

Both targets launched and displayed the watch face. Screenshots were captured with `scripts/capture-windows-screen.sh` into ignored `tmp/` files for local visual inspection.
