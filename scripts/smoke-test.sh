#!/usr/bin/env bash
# Smoke test for a pgModeler image, run before publishing it:
#  1. every shared library of pgModeler resolves (ldd)
#  2. pgmodeler-cli starts and prints its version
#  3. the GUI starts on an X server (Xvfb in a helper container) and keeps running
#
# Usage: scripts/smoke-test.sh <image> [expected-version]
set -euo pipefail

# Git Bash on Windows would rewrite the container paths below into Windows paths
export MSYS_NO_PATHCONV=1

IMAGE=${1:?usage: smoke-test.sh <image> [expected-version]}
EXPECTED_VERSION=${2:-}
XVFB_IMAGE=${XVFB_IMAGE:-ubuntu:24.04}
GUI_WAIT=${GUI_WAIT:-15}

suffix="$$-$RANDOM"
network="pgm-smoke-$suffix"
xvfb="pgm-xvfb-$suffix"
app="pgm-app-$suffix"

cleanup() {
  docker rm -f "$app" "$xvfb" >/dev/null 2>&1 || true
  docker network rm "$network" >/dev/null 2>&1 || true
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

echo "==> [1/3] Shared libraries"
missing=$(docker run --rm --entrypoint sh "$IMAGE" -c '
  test -x /usr/local/bin/pgmodeler || echo "/usr/local/bin/pgmodeler is missing"
  find /usr/local/bin /usr/local/lib/pgmodeler -type f \( -name "pgmodeler*" -o -name "*.so*" \) \
    -exec ldd {} + 2>/dev/null | grep "not found" || true
')
if [ -n "$missing" ]; then
  echo "$missing" >&2
  fail "unresolved libraries in $IMAGE"
fi

echo "==> [2/3] pgmodeler-cli"
# 2.x prints its version with --help, 1.x only when it runs an operation like --list-plugins
version_line=
for option in --help --list-plugins; do
  if ! cli_output=$(docker run --rm --entrypoint pgmodeler-cli "$IMAGE" "$option" 2>&1); then
    echo "$cli_output" >&2
    fail "pgmodeler-cli $option exited with an error"
  fi
  version_line=$(grep -m1 -E "Version [0-9]" <<<"$cli_output" || true)
  if [ -n "$version_line" ]; then
    break
  fi
done
if [ -z "$version_line" ]; then
  echo "$cli_output" >&2
  fail "pgmodeler-cli did not print its version"
fi
echo "$version_line"
if [ -n "$EXPECTED_VERSION" ] && [[ "$version_line" != *"Version $EXPECTED_VERSION "* ]]; then
  echo "::warning::$IMAGE reports '$version_line', expected version $EXPECTED_VERSION"
fi

echo "==> [3/3] GUI start-up under Xvfb"
docker network create "$network" >/dev/null
docker run -d --name "$xvfb" --network "$network" "$XVFB_IMAGE" sh -c '
  apt-get update -qq &&
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends xvfb >/dev/null &&
  exec Xvfb :99 -screen 0 1280x1024x24 -listen tcp -ac' >/dev/null
for _ in $(seq 1 90); do
  if docker exec "$xvfb" test -e /tmp/.X11-unix/X99 2>/dev/null; then
    break
  fi
  sleep 2
done
if ! docker exec "$xvfb" test -e /tmp/.X11-unix/X99 2>/dev/null; then
  docker logs "$xvfb" >&2
  fail "Xvfb did not start"
fi

docker run -d --name "$app" --network "$network" -e DISPLAY="$xvfb:99" "$IMAGE" >/dev/null
sleep "$GUI_WAIT"
app_logs=$(docker logs "$app" 2>&1)
if [ "$(docker inspect -f '{{.State.Running}}' "$app")" != true ]; then
  echo "$app_logs" >&2
  fail "pgmodeler exited during start-up"
fi
if grep -qiE "could not (load|connect)|qt\.qpa\.plugin|segmentation fault" <<<"$app_logs"; then
  echo "$app_logs" >&2
  fail "Qt reported a display or plugin problem"
fi
if [ -n "$app_logs" ]; then
  echo "$app_logs"
fi
echo "OK: $IMAGE passed the smoke test"
