# set_pub_cache scripts (local-dev convenience)

These small scripts let a developer easily point the `PUB_CACHE` environment variable at the global
pub cache on their Windows machine. This is intended for local convenience only and is *not* a
substitute for vendorizing the cache if you need reproducible builds or CI stability.

Files added
- `set_pub_cache.cmd` - cmd.exe script that detects the typical Windows pub-cache locations and
  sets `PUB_CACHE` for the current `cmd.exe` session. If you call the script directly in an
  interactive `cmd` shell, the variable will be set for that shell. The script prints a `setx`
  suggestion if you want to make it permanent.
- `set_pub_cache.ps1` - PowerShell script that detects typical locations and sets `$env:PUB_CACHE`
  for the current PowerShell session. Note: to have the script modify your current interactive
  session you must dot-source it:

  ```powershell
  . .\set_pub_cache.ps1
  ```
  Example (dot-source explicitly):

  ```powershell
  # From the scripts folder
  . .\set_pub_cache.ps1
  # Then run dart pub get --offline
  dart pub get --offline
  ```
  If you run it without dot-sourcing, it will still set `$env:PUB_CACHE` for the process that
  executed it, but your interactive session may not inherit the change. The script prints guidance
  to either dot-source or persist using `setx`.

Why this exists
- On a single developer machine you might not want to copy the entire vendor cache into the repo.
  Pointing `PUB_CACHE` at the global cache avoids duplication and speeds local setup.

Important cautions
- This is a local convenience only. Do not commit changes to environment variables or expect this
  to be available in CI or on other developer machines.
- The global pub cache is mutable. Running `dart pub upgrade`, `pub global activate`, or
  `dart pub cache repair` can change its contents, which reduces reproducibility.
- If you rely on a vendored cache for CI or to pin exact artifacts, keep using the vendored copy
  (for example `repo/vendor/pub-cache`).

Suggested workflow
1. For local experimentation:
   - In `cmd.exe`: run `set_pub_cache.cmd` (or pass a path) to set `PUB_CACHE` for that shell.
   - In PowerShell: dot-source `set_pub_cache.ps1`:
     ```powershell
     . .\set_pub_cache.ps1
     ```
2. Run your usual `dart pub get` or other commands in the same shell.
3. If you want to make the variable persistent on your user account, use the printed `setx` command.
  Note this affects new shells only (it does not modify the current session).

  Example (persist for future cmd shells):

  ```cmd
  setx PUB_CACHE "C:\Users\ericd\AppData\Local\Pub\Cache"
  ```

If you want, I can also add an optional mode to create a junction from `repo/vendor/pub-cache` to
the global cache instead of copying; that avoids duplication but is not portable and still relies
on your machine's state.

Offline testing and build steps
--------------------------------

If you want to run tests fully offline you need to ensure dependencies are present in the cache
and then tell the test runner not to call pub again. Example workflow (Windows):

cmd.exe:
```cmd
REM set PUB_CACHE for the current window (example detected path for this machine)
set "PUB_CACHE=C:\Users\ericd\AppData\Local\Pub\Cache"
cd C:\path\to\repo
dart pub get --offline
cd packages\sltt_core
dart test --no-pub
```

PowerShell (dot-source script to set env):
```powershell
. .\scripts\set_pub_cache.ps1
Set-Location -Path 'C:\path\to\repo'
# ensure dependencies are present in cache
dart pub get --offline
Set-Location -Path 'packages/sltt_core'
dart test --no-pub
```

build_runner notes
------------------
If your package uses code generation (common in this repo), build artifacts may be required before
running tests. Typical commands:

- Generate code once (online or with a cache containing the builder packages):
  ```cmd
  dart run build_runner build --delete-conflicting-outputs
  ```

- Run an incremental watcher (dev loop):
  ```cmd
  dart run build_runner watch
  ```

- Clean generated outputs:
  ```cmd
  dart run build_runner clean
  ```

When running offline, `build_runner` still needs the builder packages available in the cache. If those
builder packages are missing, `build_runner` will try to download them (and fail offline). Populate your
cache first (or run the above commands once online to get the generated files checked into git if that
fits your workflow).

---
Generated on: 2025-10-01
