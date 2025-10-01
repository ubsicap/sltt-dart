SLTT Core logging
==================

This project includes a small logging wrapper `SlttLogger` in
`lib/src/logging.dart`. It uses the Dart `logging` package and defaults
to `Level.WARNING` so test output remains quiet.

Controlling the log level
-------------------------

- Environment variable: set `SLTT_LOG_LEVEL` before running tests.
  Supported values: `ALL`, `FINE` (or `DEBUG`), `INFO`, `WARNING` (or `WARN`),
  `SEVERE` (or `ERROR`), `OFF`.

  Example (Windows cmd.exe):

  ```cmd
  set SLTT_LOG_LEVEL=FINE
  dart test packages\sltt_core
  ```

  Example (PowerShell):

  ```powershell
  $env:SLTT_LOG_LEVEL = 'FINE'
  dart test packages/sltt_core
  ```

- Programmatic: tests can call `SlttLogger.init(level: Level.FINE)` or
  `SlttLogger.setLevel(Level.FINE)` to temporarily increase verbosity.

Notes
-----
- `SlttLogger.init()` is called automatically at library load time, and
  `SlttLogger.init()` also reads `SLTT_LOG_LEVEL` when invoked. If an
  environment blocks `Platform.environment`, you can call
  `SlttLogger.init(level: ...)` directly from tests.
SLTT Core logging

The SLTT Core test suite uses a small logging wrapper (`SlttLogger`) to
keep test output quiet by default while allowing you to enable verbose
logs when debugging.

Quick usage

- Environment variable (recommended for CI/local runs):

  On Windows CMD:

  ```cmd
  set SLTT_LOG_LEVEL=FINE
  dart test packages\sltt_core
  ```

  On PowerShell:

  ```powershell
  $env:SLTT_LOG_LEVEL = 'FINE'
  dart test packages/sltt_core
  ```

- Programmatic (per-test):

  ```dart
  import 'package:logging/logging.dart';
  import 'test/test_logging_util.dart';

  void main() {
    enableTestLogging(level: Level.FINE);
    // ...tests...
  }
  ```

Supported levels: ALL, FINE (DEBUG), INFO, WARNING (default), SEVERE (ERROR), OFF

Notes
- The logger attempts to read `SLTT_LOG_LEVEL` during library init. If your test
  runner restricts environment access, you can set the level programmatically
  as shown above.
- The wrapper also sets `Logger.root.level` so third-party logs respect the
  configured level.
