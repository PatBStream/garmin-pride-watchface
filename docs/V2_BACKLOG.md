# V2 Backlog

These are future ideas, not v1 blockers.

## V2 Baseline Completed

- Created branch `v2/x1-venu-sq2-support`.
- Added Garmin Venu X1 target: `venux1`.
- Added generated 448x486 X1 artwork and 65x65 launcher icon resources.
- Converted active and always-on layout positioning from fixed 320x360 constants to scaled coordinates so Venu Sq 2 and X1 can share the same visual design.
- Added `scripts/build-release.sh` to build all v2 targets sequentially and print artifact paths.
- Added WSL helpers for Windows simulator launch and screenshot capture.
- Smoke-tested `venux1` and `venusq2` in the Windows simulator.

## Visual Design

- Try a custom bitmap font for the main time.
- Add more drop shadow to all elements to improve legibility on the busy background.
- Consider alternate metric icon shapes if the line icons feel too abstract on-device.
- Add an optional no-divider layout now that the background itself carries the Pride identity.

## Data and Settings

- Add optional weather as a replacement metric slot if the Venu Sq 2 API path is reliable.
- Add configurable metric slot ordering.
- Add optional step goal progress.
- Add a low-battery layout treatment beyond just warning color.

## Device and Release

- Build for **Garmin X1** device, as well as Venu Sq 2 and Venu Sq 2 Music.
- Test on physical Venu Sq 2 hardware.
- Continue visual tuning on Venu X1 after Pat reviews the first simulator pass.
- Evaluate broader device support only after Venu Sq 2 is stable.

## Tooling

- Add a screenshot capture helper script for Windows simulator iteration. `(done)`
- Add a small release script that builds all targets and prints sideload paths. `(done for current targets)`
- Consider a reproducible x86_64 build container after device definitions are already installed.
