#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: scripts/run-windows-simulator.sh <device-id>" >&2
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE="$1"
PRG="$ROOT/build/PrideDashboard-${DEVICE}.prg"
POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
SDK_WIN="C:\\Users\\patri\\AppData\\Roaming\\Garmin\\ConnectIQ\\Sdks\\connectiq-sdk-win-9.1.0-2026-03-09-6a872a80b"
JAVA_BIN_WIN="C:\\Program Files\\Microsoft\\jdk-21.0.11.10-hotspot\\bin"

if [[ ! -f "$PRG" ]]; then
  scripts/build.sh "$DEVICE"
fi

WIN_PRG="$(wslpath -w "$PRG")"

"$POWERSHELL" -NoProfile -Command "\
\$sim=Get-Process simulator -ErrorAction SilentlyContinue | Select-Object -First 1; \
if (-not \$sim) { Start-Process -FilePath '$SDK_WIN\\bin\\simulator.exe'; Start-Sleep -Seconds 2; } \
\$env:Path='$JAVA_BIN_WIN;' + \$env:Path; \
& '$SDK_WIN\\bin\\monkeydo.bat' '$WIN_PRG' '$DEVICE'"
