#!/usr/bin/env bash
# Tags a release of this fork: fork-v<version>-<upstream build>.<fork revision>,
# e.g. fork-v1.2.0-122.1 is the first fork build on top of upstream build 122.
# See FORK.md. The prefix keeps fork tags out of upstream's v* namespace (and
# its Codemagic trigger); the decimal build keeps the What's New key,
# "1.2.0 (122.1)", from ever matching an upstream entry.
set -euo pipefail

fail() { echo "fork-tag: $*" >&2; exit 1; }

tag="${1:-}"
[[ "$tag" =~ ^fork-v([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+\.[0-9]+)$ ]] \
    || fail "usage: Scripts/fork-tag.sh fork-vX.Y.Z-<upstream build>.<revision>  (e.g. fork-v1.2.0-122.1)"
version="${BASH_REMATCH[1]}"
build="${BASH_REMATCH[2]}"

root="$(git rev-parse --show-toplevel)"
marketing="$(grep -m1 -o 'MARKETING_VERSION = [0-9.]*' "$root/Rivulet.xcodeproj/project.pbxproj" | sed 's/.*= //')"
[ "$marketing" = "$version" ] || fail "tag says $version but MARKETING_VERSION is $marketing"

# The fresh-launch What's New looks the key up exactly, with no fallback.
grep -qF "(\"$version ($build)\"" "$root/Rivulet/Views/Components/WhatsNewView.swift" \
    || fail "no What's New entry keyed \"$version ($build)\" in WhatsNewView.swift"

[ -z "$(git status --porcelain)" ] || fail "commit your changes first; the tag marks HEAD"
! git rev-parse -q --verify "refs/tags/$tag" >/dev/null || fail "$tag already exists"

git tag -a "$tag" -m "Rivulet fork $version ($build)"
echo "Tagged $tag at $(git rev-parse --short HEAD). Push it with: git push origin $tag"
echo "Before archiving, stamp the build number (do not commit it): xcrun agvtool new-version -all $build"
