# Pride Watch Face

Garmin Connect IQ watch face for Venu Sq 2 family watches and Garmin Venu X1.

Build with [OpenClaw](https://openclaw.ai/) connected to (https://chatgpt.com/) ChatGPT Codex, no hand-coding.  See docs for prompts and MD files used in development.

## Targets

- Garmin Venu Sq 2: `venusq2`
- Garmin Venu Sq 2 Music: `venusq2m`
- Garmin Venu X1: `venux1`

## V1 / V2 Baseline

V1 is a Pride dashboard watch face with:

- Full-screen generated Progress Pride background
- Large digital time with AM/PM suffix
- Date
- Steps
- Heart rate
- Battery percentage
- Calories

V1 was approved on the 320x360 Venu Sq 2 simulator. The v2 branch adds a first dual-size baseline for the 448x486 Venu X1 while preserving the approved Venu Sq 2 layout.

## Build

```sh
scripts/build-release.sh
```

Outputs:

```text
build/PrideDashboard-venusq2.prg
build/PrideDashboard-venusq2m.prg
build/PrideDashboard-venux1.prg
```

Individual targets can still be built with `scripts/build.sh <device-id>`.

Use Windows-local VS Code and the Garmin Monkey C extension for simulator testing on this machine.
From WSL, the helper below can launch the Windows simulator for an already-built target:

```sh
scripts/run-windows-simulator.sh venux1
```

## Docs

- `docs/DEVELOPMENT_SPEC.md`: current implementation spec
- `docs/RELEASE_V1.md`: release notes and validation state
- `docs/TOOLCHAIN.md`: Garmin SDK / Windows / WSL notes
- `docs/V2_BACKLOG.md`: future work ideas
- `docs/INITIAL_REQUEST.md`: original user request context
