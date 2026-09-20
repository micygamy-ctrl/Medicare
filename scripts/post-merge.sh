#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

if command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK detected; resolving Dart dependencies."
  flutter pub get
else
  echo "Flutter SDK is not available; skipping Flutter dependency resolution."
fi

if [[ -f functions/package-lock.json ]]; then
  echo "Installing Firebase Functions dependencies from package-lock.json."
  npm --prefix functions ci --no-audit --no-fund
fi