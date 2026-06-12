# Chrono Suite 1.0.0

Chrono Suite provides timing, audit, cleanup, data-import, and workflow tools.

Menu root: `Chrono Suite`

Namespace: `kite.ChronoSuite`

## Main areas

- Audit markers with presets and configurable thresholds.
- Utility groups for case, punctuation, tags, smart cleanup, split/join, timing, and karaoke.
- Data Import modes for Effects, Text, Actor, initial Tags, and Song Sync.
- Extra tools including AE Export, Actor Manager, Text Replacer, mpv QC, Remover Assistant, and Style Filter.

## Dedicated entries

- `Chrono Suite/Config`
- `Chrono Suite/Help`
- `Chrono Suite/Cue Timer`
- `Chrono Suite/Extract KF (SCXvid)`
- `Chrono Suite/Scream Detector`
- `Chrono Suite/Audit/Markers`

Additional utility and tool entries are registered beneath the same root for direct hotkey assignment.

## Configuration and external tools

Settings persist in the Aegisub user directory as `chrono_suite_config.lua`. FFmpeg, SCXvid, and external timing-analysis files are required only by the features that use them.

The script includes English, Spanish, and Portuguese interface text.
