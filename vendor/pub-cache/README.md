Pub Package Cache
=================

This folder is used by Pub to store cached packages used in Dart / Flutter
projects.

The contents of this folder should only be modified using the `dart pub` and
`flutter pub` commands.

Modifying this folder manually can lead to inconsistent behavior.

For details on how manage the `PUB_CACHE`, see:
https://dart.dev/go/pub-cache


how to use it offline
1. From a fresh shell in `sltt-dart` root, point Dart to the vendored cache:

```
set PUB_CACHE=%CD%\vendor\pub-cache
```
2. Run your usual commands with the `--offline` flag, e.g.:

```
dart pub get --offline
dart run --offline
dart build_runner build --offline --delete-conflicting-outputs
```
