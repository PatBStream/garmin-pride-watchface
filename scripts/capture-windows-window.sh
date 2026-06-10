#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: scripts/capture-windows-window.sh <process-name> <output.png> [title-regex]" >&2
  exit 2
fi

PROCESS="$1"
OUT="$2"
TITLE_REGEX="${3:-.*}"
WINDOW_X="${WINDOW_X:-}"
WINDOW_Y="${WINDOW_Y:-0}"
POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
WIN_TMP="C:\\Users\\patri\\AppData\\Local\\Temp\\watchface-window.png"
WSL_TMP="/mnt/c/Users/patri/AppData/Local/Temp/watchface-window.png"

mkdir -p "$(dirname "$OUT")"

"$POWERSHELL" -NoProfile -Command "\
Add-Type -AssemblyName System.Drawing; \
Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Win32 { [DllImport(\"user32.dll\")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect); [DllImport(\"user32.dll\")] public static extern bool SetForegroundWindow(IntPtr hWnd); [DllImport(\"user32.dll\")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); [DllImport(\"user32.dll\")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags); } public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }'; \
\$proc = Get-Process '$PROCESS' | Where-Object { \$_.MainWindowHandle -ne 0 -and \$_.MainWindowTitle -match '$TITLE_REGEX' } | Select-Object -First 1; \
if (-not \$proc) { throw 'No matching window found for process $PROCESS / $TITLE_REGEX'; } \
[Win32]::ShowWindow(\$proc.MainWindowHandle, 9) | Out-Null; \
if ('$WINDOW_X' -ne '') { [Win32]::SetWindowPos(\$proc.MainWindowHandle, [IntPtr](-1), $WINDOW_X, $WINDOW_Y, 0, 0, 0x0001) | Out-Null; } \
[Win32]::SetWindowPos(\$proc.MainWindowHandle, [IntPtr](-1), 0, 0, 0, 0, 0x0001 -bor 0x0002) | Out-Null; \
[Win32]::SetForegroundWindow(\$proc.MainWindowHandle) | Out-Null; \
Start-Sleep -Milliseconds 300; \
[Win32]::SetWindowPos(\$proc.MainWindowHandle, [IntPtr](-2), 0, 0, 0, 0, 0x0001 -bor 0x0002) | Out-Null; \
\$rect = New-Object RECT; \
[Win32]::GetWindowRect(\$proc.MainWindowHandle, [ref]\$rect) | Out-Null; \
\$width = \$rect.Right - \$rect.Left; \
\$height = \$rect.Bottom - \$rect.Top; \
\$bitmap = New-Object System.Drawing.Bitmap \$width,\$height; \
\$graphics = [System.Drawing.Graphics]::FromImage(\$bitmap); \
\$graphics.CopyFromScreen(\$rect.Left,\$rect.Top,0,0,\$bitmap.Size); \
\$bitmap.Save('$WIN_TMP',[System.Drawing.Imaging.ImageFormat]::Png); \
\$graphics.Dispose(); \
\$bitmap.Dispose(); \
Write-Output \$proc.MainWindowTitle"

cp "$WSL_TMP" "$OUT"
echo "Captured $OUT"
