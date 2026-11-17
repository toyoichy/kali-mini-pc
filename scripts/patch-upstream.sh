#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="\${1:?Usage: patch-upstream.sh <tiny-container-source-dir>}"
python3 - "$SOURCE_DIR" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
gradle = root / "app/build.gradle.kts"
text = gradle.read_text()
text = text.replace('applicationId = "com.fct.tc4"', 'applicationId = "com.toyoichy.kaliminipc"')
text = re.sub(r'versionCode = \d+', 'versionCode = 1', text)
text = re.sub(r'versionName = "[^"]+"', 'versionName = "0.1.0-kali"', text)
gradle.write_text(text)

for strings in (root / "app/src/main/res").glob("values*/strings.xml"):
    data = strings.read_text()
    data = re.sub(
        r'(<string\s+name="tc4_app_name"\s*>).*?(</string>)',
        r'\1Kali Mini PC\2',
        data,
        count=1,
        flags=re.DOTALL,
    )
    strings.write_text(data)

(root / "app/src/main/assets").mkdir(parents=True, exist_ok=True)
PY
