#!/usr/bin/env python3
"""Add a default arm to xterm's platform switch so HarmonyOS can compile.

The existing Android and iOS cases stay unchanged. A default arm is valid on
the stock Flutter SDK as well.
"""

import pathlib
import sys

needle = """    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return _defaultAppleShortcuts;
  }
"""
replacement = """    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return _defaultAppleShortcuts;
    default:
      return _defaultShortcuts;
  }
"""

roots = [
    pathlib.Path.home() / ".pub-cache" / "git",
    pathlib.Path(__file__).resolve().parents[1] / ".dart_tool",
]
patched = 0
for root in roots:
    if not root.exists():
        continue
    for path in root.glob("xterm.dart-*/lib/src/ui/shortcut/shortcuts.dart"):
        text = path.read_text()
        if "default:" in text.split("switch (defaultTargetPlatform)", 1)[-1][:500]:
            continue
        if needle not in text:
            print(f"unexpected xterm shortcuts.dart: {path}", file=sys.stderr)
            sys.exit(1)
        path.write_text(text.replace(needle, replacement, 1))
        patched += 1
        print(f"patched {path}")

if patched == 0:
    print("xterm shortcuts.dart already accepts HarmonyOS")
