#!/bin/bash
set -euo pipefail

# Runs pana in a temporary sandbox so unpublished workspace packages can be
# scored before they exist on pub.dev.
#
# Sandbox setup:
# - Copies packages with dereferenced LICENSE/CHANGELOG symlinks (rsync -aL),
#   otherwise pana misses those files and loses convention points.
# - Rewrites workspace version constraints to path deps so resolution works
#   before publish, and strips `resolution: workspace`.
# - Ignores `invalid_dependency` only in the sandbox so temporary path deps
#   do not tank the analysis score (published packages use hosted deps).
#
# Usage:
#   ./verify_pub_score_workspace.sh <min_score> <package_directory>
#   ./verify_pub_score_workspace.sh 160 packages/shape_generator

MIN_SCORE="${1:-}"
TARGET_REL="${2:?package directory relative to repo root is required}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$REPO_ROOT/$TARGET_REL"
PACKAGE_NAME="$(awk '/^name:/{print $2; exit}' "$TARGET/pubspec.yaml")"

TEMP="$(mktemp -d)"
cleanup() {
  rm -rf "$TEMP"
}
trap cleanup EXIT

copy_package() {
  local source_rel="$1"
  local dest_name="$2"
  # -aL: archive mode + dereference symlinks so LICENSE/CHANGELOG (which point
  # at the repo root) become real files inside the sandbox.
  rsync -aL \
    --exclude=.dart_tool \
    --exclude=build \
    --exclude=coverage \
    --exclude='melos_*.iml' \
    "$REPO_ROOT/$source_rel/" "$TEMP/$dest_name/"

  # Belt-and-suspenders: always materialize root LICENSE/CHANGELOG as files.
  cp "$REPO_ROOT/LICENSE" "$TEMP/$dest_name/LICENSE"
  cp "$REPO_ROOT/CHANGELOG.md" "$TEMP/$dest_name/CHANGELOG.md"
}

copy_package packages/shape shape
copy_package packages/shape_starter_kit shape_starter_kit
copy_package packages/shape_generator shape_generator

# Preserve workspace analysis options; package includes point at ../../ which
# would miss from the sandbox layout (packages are siblings under $TEMP).
cp "$REPO_ROOT/analysis_options.yaml" "$TEMP/analysis_options.yaml"

patch_path_dependency() {
  local pubspec="$1"
  local dependency="$2"
  local path="$3"
  python3 - "$pubspec" "$dependency" "$path" <<'PY'
import re
import sys

pubspec_path, dependency, path = sys.argv[1:4]
text = open(pubspec_path, encoding="utf-8").read()
pattern = rf"^  {re.escape(dependency)}: \^[^\n]+$"
replacement = f"  {dependency}:\n    path: {path}"
updated, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
if count != 1:
    sys.exit(f"Failed to patch {dependency} in {pubspec_path}")
open(pubspec_path, "w", encoding="utf-8").write(updated)
PY
}

patch_path_dependency "$TEMP/shape_starter_kit/pubspec.yaml" shape "$TEMP/shape"
patch_path_dependency "$TEMP/shape_generator/pubspec.yaml" shape "$TEMP/shape"
patch_path_dependency "$TEMP/shape_generator/pubspec.yaml" shape_starter_kit "$TEMP/shape_starter_kit"

for pkg in shape shape_starter_kit shape_generator; do
  pubspec="$TEMP/$pkg/pubspec.yaml"
  python3 - "$pubspec" <<'PY'
import sys

pubspec_path = sys.argv[1]
lines = []
for line in open(pubspec_path, encoding="utf-8"):
    if line.strip() == "resolution: workspace":
        continue
    lines.append(line)
open(pubspec_path, "w", encoding="utf-8").writelines(lines)
PY

  # Fix analysis_options include for sandbox layout and suppress path-dep
  # warnings that only exist because of the temporary path patches above.
  cat > "$TEMP/$pkg/analysis_options.yaml" <<'AOE'
include: ../analysis_options.yaml

analyzer:
  errors:
    # Sandbox-only: path deps stand in for unpublished hosted packages.
    invalid_dependency: ignore
AOE
done

cd "$TEMP/$PACKAGE_NAME"

PANA="$(pana . --no-warning)"
PANA_SCORE="$(echo "$PANA" | sed -n "s/.*Points: \([0-9]*\)\/\([0-9]*\)./\1\/\2/p")"

if [ -z "$PANA_SCORE" ]; then
  echo "Failed to parse pana score from output:"
  echo "$PANA"
  exit 1
fi

echo "score: $PANA_SCORE"
IFS='/'
read -r -a SCORE_ARR <<< "$PANA_SCORE"
SCORE="${SCORE_ARR[0]}"
TOTAL="${SCORE_ARR[1]}"

if ! [[ "$SCORE" =~ ^[0-9]+$ ]] || ! [[ "$TOTAL" =~ ^[0-9]+$ ]]; then
  echo "Invalid score format: $PANA_SCORE"
  exit 1
fi

if [ -z "$MIN_SCORE" ]; then
  MINIMUM_SCORE="$TOTAL"
else
  MINIMUM_SCORE="$MIN_SCORE"
fi

if (( SCORE < MINIMUM_SCORE )); then
  echo "minimum score $MINIMUM_SCORE was not met!"
  exit 1
fi
