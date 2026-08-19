#!/usr/bin/env bash
# Installs gitpulse: regenerates on every commit, opens itself at 21:30 daily.
set -euo pipefail

BIN="$HOME/.local/bin"
HOOKS="$HOME/.githooks"
PLIST="$HOME/Library/LaunchAgents/com.gitpulse.nightly.plist"
SRC="$(cd "$(dirname "$0")" && pwd)/gitpulse"

mkdir -p "$BIN" "$HOOKS" "$HOME/Library/LaunchAgents"

# 1. the script itself
install -m 755 "$SRC" "$BIN/gitpulse"
echo "installed  $BIN/gitpulse"

# 2. regenerate after every commit, in every repo
existing="$(git config --global core.hooksPath || true)"
if [ -n "$existing" ] && [ "$existing" != "$HOOKS" ]; then
  echo "warning: core.hooksPath is already set to $existing — not touching it."
  echo "         add this line to that hooks dir's post-commit instead:"
  echo "           $BIN/gitpulse --quiet >/dev/null 2>&1 &"
else
  cat > "$HOOKS/post-commit" <<HOOK
#!/usr/bin/env bash
# chain to a repo-local hook if one exists
local_hook="\$(git rev-parse --git-path hooks/post-commit 2>/dev/null || true)"
if [ -n "\$local_hook" ] && [ -x "\$local_hook" ] && [ "\$local_hook" != "\$0" ]; then
  "\$local_hook" "\$@" || true
fi
"$BIN/gitpulse" --quiet >/dev/null 2>&1 &
HOOK
  chmod +x "$HOOKS/post-commit"
  git config --global core.hooksPath "$HOOKS"
  echo "installed  $HOOKS/post-commit  (core.hooksPath -> $HOOKS)"
fi

# 3. open it every evening at 20:45
cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.gitpulse.nightly</string>
  <key>ProgramArguments</key>
  <array>
    <string>$BIN/gitpulse</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>20</integer><key>Minute</key><integer>45</integer></dict>
  <key>RunAtLoad</key><false/>
</dict></plist>
PLISTEOF

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "installed  $PLIST  (fires 20:45 daily)"

# 4. first run
"$BIN/gitpulse"
echo
echo "done. page lives at ~/gitpulse.html"
echo "run it any time with: gitpulse   (add ~/.local/bin to PATH if needed)"
