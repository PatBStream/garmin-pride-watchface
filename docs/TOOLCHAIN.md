# Garmin Connect IQ Toolchain Notes

Verified on 2026-06-08 in WSL2 Ubuntu 24.04 aarch64.

## ARM64 SDK Manager Constraint

Garmin's Linux SDK Manager download is available at:

`https://developer.garmin.com/downloads/connect-iq/sdk-manager/connectiq-sdk-manager-linux.zip`

The extracted `bin/sdkmanager` is an x86-64 Linux ELF binary:

`ELF 64-bit LSB executable, x86-64`

This WSL2 VM is `aarch64`, so the binary exits with:

`cannot execute binary file: Exec format error`

That means this local WSL2 ARM environment cannot run the Garmin Linux SDK Manager directly.

## Feasible Build Paths

Preferred:

1. Use an x86_64 Linux machine or x86_64 WSL2 Ubuntu install.
2. Download and unzip Garmin's Linux SDK Manager.
3. Run `bin/sdkmanager`.
4. Download Connect IQ 9.1.0 and Venu Sq 2 device definitions.
5. Add the active SDK to `PATH`:

   ```sh
   export PATH="$PATH:$(cat "$HOME/.Garmin/ConnectIQ/current-sdk.cfg")/bin"
   ```

6. Build from this repo:

   ```sh
   scripts/build.sh venusq2
   ```

7. Run in the simulator:

   ```sh
   connectiq
   monkeydo build/PrideDashboard.prg venusq2
   ```

Current preferred simulator path:

1. Use Garmin's Windows SDK Manager and VS Code Monkey C extension on the Windows host.
2. Open this repository from Windows-local VS Code through `\\wsl$\Ubuntu\home\pat\projects\watchface`.
3. Run without debugging against `Venu Sq 2`.
4. Rebuild target PRGs from WSL or Windows as needed.
5. Copy the resulting `.prg` to the watch's `GARMIN/APPS` directory for private sideload testing.

Possible but not recommended for v1:

- Use x86_64 emulation from ARM Linux. This would require a working x86_64 dynamic loader plus compatible glibc/libraries or a Box64-style runtime. It may still fail on simulator graphics dependencies, and it is more work than using an x86_64 WSL distro or Windows host.

## Current Local Build Status

The Java-based `monkeyc` compiler runs in this ARM64 WSL environment after directly downloading the Connect IQ 9.1.0 SDK zip.

Pat also installed the Windows-host Garmin SDK at:

```text
/mnt/c/Users/patri/AppData/Roaming/Garmin/ConnectIQ
```

That directory includes the Venu Sq 2 device definitions. WSL uses them through:

```text
/home/pat/.Garmin/ConnectIQ/Devices -> /mnt/c/Users/patri/AppData/Roaming/Garmin/ConnectIQ/Devices
```

The project now builds clean target-specific PRGs via:

```sh
scripts/build.sh venusq2
scripts/build.sh venusq2m
scripts/build.sh venux1
```

That produces:

```text
build/PrideDashboard-venusq2.prg
build/PrideDashboard-venusq2m.prg
build/PrideDashboard-venux1.prg
```

The Linux Garmin simulator still cannot run directly in this ARM64 WSL install because it is an x86-64 ELF binary. Use the Windows host simulator / VS Code Monkey C extension for simulator testing.

WSL helper scripts are available for the Windows simulator path on this machine:

```sh
scripts/run-windows-simulator.sh venusq2
scripts/run-windows-simulator.sh venux1
scripts/capture-windows-screen.sh tmp/simulator.png
```

`run-windows-simulator.sh` starts the Windows simulator if needed and then runs `monkeydo.bat` for the requested device. It is expected to stay attached while the simulated app is running.

## Release Build

For v2, rebuild all target PRGs sequentially:

```sh
scripts/build-release.sh
```

Do not run `monkeyc` builds in parallel in this repo. During development, parallel target builds intermittently produced a generic `critical error`; sequential builds are stable. `scripts/build.sh` uses `build/.build.lock` to serialize invocations.

Expected target artifacts:

```text
build/PrideDashboard-venusq2.prg
build/PrideDashboard-venusq2m.prg
build/PrideDashboard-venux1.prg
```

## VS Code Extension Notes

The Garmin Monkey C extension uses different configuration roots depending on where the extension is running:

- Windows-local VS Code uses `%APPDATA%\Garmin\ConnectIQ`, currently visible in WSL as `/mnt/c/Users/patri/AppData/Roaming/Garmin/ConnectIQ`.
- Remote WSL VS Code uses `$HOME/.Garmin/ConnectIQ`, currently `/home/pat/.Garmin/ConnectIQ`.

Configured paths:

- WSL current SDK: `/home/pat/.Garmin/ConnectIQ/current-sdk.cfg`
- Windows current SDK: `/mnt/c/Users/patri/AppData/Roaming/Garmin/ConnectIQ/current-sdk.cfg`
- WSL developer key: `/home/pat/.Garmin/ConnectIQ/developer_key.der`
- Windows developer key copy: `C:\Users\patri\AppData\Roaming\Garmin\ConnectIQ\developer_key.der`

The Windows SDK Manager executable is:

```text
C:\Program Files (x86)\connectiq-sdk-manager-windows\sdkmanager.exe
```

The Windows SDK Manager location file already points there:

```text
C:\Users\patri\AppData\Roaming\Garmin\ConnectIQ\sdkmanager-location.cfg
```

## Windows Java Note

Windows-local VS Code needs Windows-local Java for the Monkey C language server. If the extension reports `spawn java ENOENT`, install a Windows JDK, for example:

```powershell
winget install --id Microsoft.OpenJDK.21 -e --accept-package-agreements --accept-source-agreements
```

Then close and reopen Windows VS Code. If needed, set `monkeyC.javaPath` to the JDK root folder, not `bin\java.exe`.
