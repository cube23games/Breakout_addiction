# BA-70 Shadow CI scope

This validation branch is temporary and must never be merged into `main`.

It tests every incremental source tree from BA-70A5R3 through BA-70A13 using the same Flutter commands as production CI:

- `flutter pub get`
- `flutter analyze --no-fatal-infos`
- `flutter test`
- every cumulative accepted Python verifier

It also reruns the final A13 combined tree and performs an Android generation/patch simulation. No APK or AAB is built.

V4 also validates the consolidated constructor repairs and corrected Android patch ordering environment.
