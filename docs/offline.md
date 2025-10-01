Offline build with vendored Dart pub cache
=========================================

This repository includes a vendored pub cache at `vendor/pub-cache/` (not committed to git by default).
The provided script `scripts/use_vendored_pubcache.sh` reproduces an offline `pub get` and codegen run
for the two packages that require it: `packages/sltt_core` and `packages/sync_manager`.

How to use
----------

1. Ensure you have a vendored pub-cache present at `vendor/pub-cache/`. Create it while online with:

```bash
# from repo root (while online)
rsync -a --delete "$HOME/.pub-cache/" vendor/pub-cache/
```

2. Run the helper script (works offline):

```bash
./scripts/use_vendored_pubcache.sh
# or specify a vendored cache path and packages (space-separated):
./scripts/use_vendored_pubcache.sh vendor/pub-cache "packages/sltt_core" "packages/sync_manager"
```

What the script does
--------------------
- Validates the vendored cache exists
- Exports `PUB_CACHE` pointing at the vendored cache
- Runs `dart pub get --offline` in each package
- Runs `dart run build_runner build --delete-conflicting-outputs` if `build_runner` is referenced

Notes
-----
- Do not commit vendor/pub-cache to git; instead publish as a release asset or store externally.
- If a package is missing from the vendored cache, populate it while online and update `vendor/pub-cache`.

Windows (copying the pub-cache)
-----------------------------------------

For Windows users a helper batch script is provided that automates copying the pub cache into `vendor\pub-cache` and prints the command to set `PUB_CACHE` for your shell session.

Use the batch script from the repository root while online:

```cmd
scripts\use_vendored_pubcache.bat
```

The script uses robocopy under the hood and includes sensible defaults and safety checks. If you prefer to run the commands manually, see `scripts/use_vendored_pubcache.bat --help` for the exact flags and examples.
