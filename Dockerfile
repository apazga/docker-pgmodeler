# syntax=docker/dockerfile:1

# Ubuntu release used to build and run pgModeler: 2.x needs Qt >= 6.6 (ubuntu:26.04),
# 1.x builds on ubuntu:24.04 (Qt 6.4). Override with --build-arg BASE_IMAGE=...
ARG BASE_IMAGE=ubuntu:26.04

FROM ${BASE_IMAGE} AS build

# pgModeler version to build (required), e.g. --build-arg PG_VERSION=2.0.0-beta1
ARG PG_VERSION
ARG DEBIAN_FRONTEND=noninteractive

RUN test -n "$PG_VERSION" \
  || { echo "PG_VERSION is required, e.g. --build-arg PG_VERSION=2.0.0-beta1" >&2; exit 1; }

# libxext-dev is needed by qmake builds (1.x), Qt's mkspec links against -lXext
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential ca-certificates clang cmake curl libpq-dev libxext-dev libxml2-dev \
    pkg-config qmake6 qt6-base-dev qt6-svg-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src/pgmodeler
RUN curl -fsSL "https://codeload.github.com/nullptrlabs/pgmodeler/tar.gz/v${PG_VERSION}" \
  | tar xz --strip-components=1

# Compile pgModeler (2.x uses CMake, 1.x uses qmake) and install it under /out
RUN <<'EOF'
set -eu
if [ "${PG_VERSION%%.*}" -ge 2 ]; then
  echo "Building pgModeler ${PG_VERSION} with CMake..."
  cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
  cmake --build build --parallel "$(nproc)"
  DESTDIR=/out cmake --install build
else
  echo "Building pgModeler ${PG_VERSION} with qmake..."
  qmake6 pgmodeler.pro
  make -j"$(nproc)"
  make install INSTALL_ROOT=/out
fi
EOF

# Find the Ubuntu packages that provide the shared libraries pgModeler links against
RUN <<'EOF'
set -eu
find /out -type f \( -perm -u+x -o -name '*.so*' \) -exec ldd {} + 2>/dev/null \
  | awk '$2 == "=>" && $3 ~ /^\// { print $3 }' | sort -u > /tmp/libs.txt
: > /tmp/packages.txt
while read -r lib; do
  case "$lib" in /out/*) continue ;; esac
  owner=
  for path in "$lib" "$(readlink -f "$lib")" "/usr$lib"; do
    if owner=$(dpkg -S "$path" 2>/dev/null); then
      break
    fi
  done
  if [ -n "$owner" ]; then
    echo "${owner%%:*}" >> /tmp/packages.txt
  else
    echo "warning: no package provides $lib" >&2
  fi
done < /tmp/libs.txt
sort -u /tmp/packages.txt > /runtime-packages.txt
cat /runtime-packages.txt
EOF


FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive
LABEL org.opencontainers.image.authors="@apazga"
# Qt expects a UTF-8 locale and warns on every start without it
ENV LANG=C.UTF-8

COPY --from=build /runtime-packages.txt /tmp/runtime-packages.txt

# Libraries found above plus what Qt loads at runtime: X11 platform plugin, SVG plugins and fonts
RUN <<'EOF'
set -eu
apt-get update
extra="ca-certificates fontconfig fonts-dejavu-core qt6-qpa-plugins"
# Ubuntu 26.04 ships the SVG plugins in their own package, 24.04 inside libqt6svg6
if apt-cache show qt6-svg-plugins >/dev/null 2>&1; then
  extra="$extra qt6-svg-plugins"
fi
xargs -a /tmp/runtime-packages.txt apt-get install -y --no-install-recommends $extra
rm -rf /var/lib/apt/lists/* /tmp/runtime-packages.txt
EOF

COPY --from=build /out/usr/local/ /usr/local/
RUN mkdir -p /usr/local/lib/pgmodeler/plugins

# Run pgModeler
ENTRYPOINT ["/usr/local/bin/pgmodeler"]
