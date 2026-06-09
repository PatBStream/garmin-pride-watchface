#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/tmp/screen.png}"
POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
WIN_TMP="C:\\Users\\patri\\AppData\\Local\\Temp\\watchface-screen.png"
WSL_TMP="/mnt/c/Users/patri/AppData/Local/Temp/watchface-screen.png"

mkdir -p "$(dirname "$OUT")"

"$POWERSHELL" -NoProfile -Command "\
Add-Type -AssemblyName System.Windows.Forms; \
Add-Type -AssemblyName System.Drawing; \
\$out='$WIN_TMP'; \
\$bounds=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds; \
\$bitmap=New-Object System.Drawing.Bitmap \$bounds.Width,\$bounds.Height; \
\$graphics=[System.Drawing.Graphics]::FromImage(\$bitmap); \
\$graphics.CopyFromScreen(\$bounds.Location,[System.Drawing.Point]::Empty,\$bounds.Size); \
\$bitmap.Save(\$out,[System.Drawing.Imaging.ImageFormat]::Png); \
\$graphics.Dispose(); \
\$bitmap.Dispose(); \
Write-Output \$out"

cp "$WSL_TMP" "$OUT"
echo "Captured $OUT"
