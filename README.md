# gitpulse

A local, self-contained picture of when you actually shipped. It reads your
configured git repos and writes one standalone neon HTML dashboard — no server
or dependencies. Interactive runs refresh remotes first; background commit-hook
runs stay offline. It regenerates on every commit and opens every evening.

![Gitpulse V2 arcade dashboard with the 35-day activity array, streak, three-day output goal, and receipt](docs/preview.png)

## What you see

- **Hero output** — total authored lines shipped over the visible 35-day window.
  Generated and vendored junk is excluded so lockfiles do not fake momentum.
- **Streak core** — the current chain, 90-day personal best, and an at-risk
  countdown when an active streak has not been secured today.
- **Activity array** — 35 midnight-to-midnight tubes. Commits are positioned by
  time, colored by hour, and log-sized by churn; gap days leave red glitch scars.
- **Three-day output** — authored additions from the latest three calendar days
  against the average three-day output across the preceding six days.
- **Live receipt** — today's output, repositories, commit count, and time span,
  switching to a nightly receipt for the evening run.
- **Transmission log** — every commit from today with repository, churn, relative
  weight, and subject.

## Install

```bash
chmod +x install-gitpulse.sh
./install-gitpulse.sh
```

The installer does four things:

1. Copies the `gitpulse` script to `~/.local/bin/gitpulse`.
2. Writes a global `post-commit` hook (`~/.githooks/post-commit`, wired via
   `core.hooksPath`) so the page regenerates in the background after every commit.
   The hook chains to any repo-local `post-commit` you already have, so nothing
   breaks. If `core.hooksPath` is already set to something else, the installer
   bails with a warning instead of clobbering it.
3. Installs a launchd agent (`~/Library/LaunchAgents/com.gitpulse.nightly.plist`)
   that runs gitpulse and opens the page at **20:45** daily.
4. Runs it once and opens the result.

The page lives at `~/gitpulse.html`.

## Usage

```bash
gitpulse            # fetch remotes, regenerate, and open
gitpulse --no-fetch # use local refs, regenerate, and open
gitpulse --no-open  # fetch and regenerate without opening
gitpulse --quiet    # local-only, silent, and headless (used by the commit hook)
```

`~/.local/bin` must be on your `PATH` for the bare `gitpulse` command to work.

## Configuration

All at the top of the `gitpulse` script:

- `REPOS` — exact local repository paths included in the dashboard. The default
  configuration tracks `nila`, `kaguya`, and `nila-connector`.
- `AUTHOR_EMAILS` — author identities included in the dashboard. The current
  configuration includes both personal and Kaguya email addresses.
- `DAYS` — number of day-columns on the strip (default 35).
- `HISTORY_DAYS` — history used for personal bests and adaptive goals (default 90).
- `EXCLUDE` — git pathspecs whose line counts are ignored (lockfiles, fixtures,
  snapshots, minified/vendored/generated code) so churn reflects authored work.
  Add a glob here if a generated file in one of your repos is inflating the count.

### Change the nightly time

Edit `Hour` / `Minute` in
`~/Library/LaunchAgents/com.gitpulse.nightly.plist`, then reload:

```bash
launchctl unload ~/Library/LaunchAgents/com.gitpulse.nightly.plist
launchctl load   ~/Library/LaunchAgents/com.gitpulse.nightly.plist
```

## Uninstall

```bash
git config --global --unset core.hooksPath
launchctl unload ~/Library/LaunchAgents/com.gitpulse.nightly.plist
rm ~/Library/LaunchAgents/com.gitpulse.nightly.plist
rm -rf ~/.githooks ~/.local/bin/gitpulse ~/gitpulse.html
```

## Requirements

macOS (uses `launchctl` and `open`), `python3`, and `git`. No Python packages —
standard library only.
</content>
</invoke>
