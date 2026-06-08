# Pride Watch Face

Garmin Connect IQ watch face for Venu Sq 2 family watches.  

Build with [OpenClaw](https://openclaw.ai/) connected to (https://chatgpt.com/) ChatGPT Codex, no hand-coding.  See docs for prompts and MD files used in development.

## Targets

- Garmin Venu Sq 2: `venusq2`
- Garmin Venu Sq 2 Music: `venusq2m`

## V1

V1 is a Pride dashboard watch face with:

- Full-screen generated Progress Pride background
- Large digital time with AM/PM suffix
- Date
- Steps
- Heart rate
- Battery percentage
- Calories

The current design is intentionally tuned for the 320x360 Venu Sq 2 screen only.

## Build

```sh
scripts/build.sh venusq2
scripts/build.sh venusq2m
```

Outputs:

```text
build/PrideDashboard-venusq2.prg
build/PrideDashboard-venusq2m.prg
```

Use Windows-local VS Code and the Garmin Monkey C extension for simulator testing on this machine.

## Docs

- `docs/DEVELOPMENT_SPEC.md`: current v1 implementation spec
- `docs/RELEASE_V1.md`: release notes and validation state
- `docs/TOOLCHAIN.md`: Garmin SDK / Windows / WSL notes
- `docs/V2_BACKLOG.md`: future work ideas
- `docs/INITIAL_REQUEST.md`: original user request context

