# daily_cleanup

A personal macOS housekeeping script that moves Desktop and Downloads content
into dated folders and exports browser history. Review and customize it before
running; it has no dry-run or undo mode.

## Requirements and setup

- Bash 4.3 or later (`local -n` is used). macOS `/bin/bash` is too old; the
  script rejects it before making changes.
- `mmv` and `sqlite3` on `PATH`.
- Access to the configured Desktop, Downloads, and browser-profile directories.

With Homebrew installed, `brew install bash mmv` supplies the first two tools;
check that `sqlite3` is available separately.

Edit `username=changeme` in `daily_cleanup.bash` to your macOS account name.
Review `source_dirs`, `archive_location`, extension arrays, and `categories`.
Each extension category must have a matching array with the same name.

Run explicitly with the modern Bash:

```sh
"$(brew --prefix bash)/bin/bash" daily_cleanup.bash
```

## What a run changes

1. Attempts to lowercase top-level filenames in Desktop and Downloads.
2. Creates `~/Archives/YYYY.MM.DD/` and category subdirectories.
3. Sends SIGTERM to Google Chrome and Firefox and attempts history exports.
4. Moves top-level directories into the `directories` category, then moves
   recognized file extensions into their categories. Files are moved, not copied.

Browser exports contain browsing URLs and titles; treat the archive as private.
Chrome uses the `Default` profile; Firefox uses the first profile directory found,
which may not be the active profile. Browser database schemas are assumed and have
not been qualified against every current browser release. The Firefox output is
SQLite's default pipe-delimited text despite its `.csv` filename.

## Current limitations

- Same-named files from different sources or a repeated same-day run can collide;
  the script does not provide collision-safe archival or rollback. Review the
  destination and preserve an independent backup before use.
- Hidden entries and unrecognized file extensions remain in place.
- Browser termination waits at most ten seconds; history extraction may still
  fail if a process remains active. Warnings can leave an incomplete archive.
- No automated end-to-end fixture suite currently qualifies the cleanup behavior.
  Do not interpret the dated destination as a verified backup.
