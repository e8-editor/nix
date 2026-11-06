#!/bin/sh
# Writes release.json for a release of e8-editor/e8, the newest unless a tag
# is given: the version, and for each system the URL and hash of its archives,
# taken from the .sha256 files the release workflow publishes beside them.
# Needs gh, signed in, or GH_TOKEN.
set -eu

repo=e8-editor/e8
tag=${1:-$(gh release view --repo "$repo" --json tagName -q .tagName)}
version=${tag#v}
base="https://github.com/$repo/releases/download/$tag"

# The SRI hash Nix wants, from the hex digest in an asset's .sha256 file.
sri() {
  hex=$(gh release download "$tag" --repo "$repo" --pattern "$1.sha256" --output - | cut -d' ' -f1)
  printf 'sha256-%s' "$(printf '%s' "$hex" | xxd -r -p | base64)"
}

asset() {
  printf '{ "url": "%s/%s", "hash": "%s" }' "$base" "$1" "$(sri "$1")"
}

cat > release.json <<JSON
{
  "version": "$version",
  "systems": {
    "aarch64-darwin": {
      "cli": $(asset "e8-$version-aarch64-apple-darwin.tar.gz"),
      "app": $(asset "E8-$version-aarch64-apple-darwin.app.tar.gz")
    },
    "x86_64-linux": {
      "cli": $(asset "e8-$version-x86_64-unknown-linux-gnu.tar.gz")
    }
  }
}
JSON
echo "release.json: E8 $version"
