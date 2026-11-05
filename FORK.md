# Fork releases

This fork tags its own builds so they never clash with upstream's.

| | Upstream | This fork |
|---|---|---|
| Tag | `v1.2.0-122` | `fork-v1.2.0-122.1` |
| `CFBundleVersion` | `122` | `122.1` |
| What's New key | `"1.2.0 (122)"` | `"1.2.0 (122.1)"` |

The fork build is `<upstream build>.<fork revision>`: the upstream build it sits on, then a
counter that restarts at 1 for each new upstream base (`122.1`, `122.2`, then `123.1` after
syncing upstream 123).

- The `fork-` prefix keeps fork tags out of upstream's `v*` namespace, so they don't collide
  with upstream tags, and upstream's Codemagic trigger (`v*`) ignores them.
- The decimal build can never equal an upstream build number, so a fork changelog entry never
  matches (or is shadowed by) an upstream one. `CFBundleVersion` allows up to three
  dot-separated integers, so `122.1` is valid.

## Releasing

1. Add an entry at the top of `changelogs` in `Rivulet/Views/Components/WhatsNewView.swift`,
   keyed `"<version> (<build>)"`, e.g. `"1.2.0 (122.1)"`.
2. Commit, then tag: `Scripts/fork-tag.sh fork-v1.2.0-122.1`. It checks the format, the
   marketing version and that the changelog entry exists.
3. Before archiving, stamp the build number: `xcrun agvtool new-version -all 122.1`. Don't
   commit that change. Upstream also leaves `CURRENT_PROJECT_VERSION` stale in git and stamps
   it in CI. Without this step the fresh-launch What's New never shows.

Upstream's Codemagic workflow only accepts integer builds, so it can't build these tags.
A fork CI workflow would need its own `fork-v*` trigger and build-number step.
