FROM ubuntu:25.10
LABEL Author="@apazga"

# pgModeler version to use (can be overridden with --build-arg)
# Note: 2.0.0-alpha requires Qt 6.6+ which is available in Ubuntu 25.10
ARG PG_VERSION=2.0.0-alpha

ADD https://codeload.github.com/pgmodeler/pgmodeler/tar.gz/v${PG_VERSION} /usr/local/src/
WORKDIR /usr/local/src/

# Add universe repository
RUN apt-get update && apt-get install -y software-properties-common \
  && add-apt-repository universe

# Install dependencies
# Note: pgModeler 2.0.0-alpha requires Qt 6.6+ which is available in Ubuntu 25.10
RUN BUILD_PKGS="qmake6 build-essential libxml2-dev libpq-dev pkg-config cmake clang" \
  && RUNTIME_PKGS="qtdeclarative5-dev libqt6core6 libqt6svg6 qttools5-dev qttools5-dev-tools postgresql-server-dev-all qt6-base-dev libqt6svg6-dev" \
  && SECURITY_PKGS="ca-certificates" \
  && DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install --no-install-recommends ${BUILD_PKGS} ${RUNTIME_PKGS} ${SECURITY_PKGS}

ENV PATH="/usr/lib/qt6/bin:$PATH"

# Compile pgmodeler
# Version 2.x uses CMake build system, 1.x uses qmake
RUN tar xvzf v${PG_VERSION} \
  && cd pgmodeler-${PG_VERSION} \
  && MAJOR_VERSION=$(echo ${PG_VERSION} | cut -d. -f1) \
  && if [ "$MAJOR_VERSION" = "2" ]; then \
       echo "Building pgModeler 2.x with CMake..."; \
       cmake -S . -B ./cmake-build --fresh; \
       cmake --build ./cmake-build --target all; \
       cmake --install ./cmake-build; \
     else \
       echo "Building pgModeler 1.x with qmake..."; \
       qmake pgmodeler.pro; \
       make && make install; \
     fi \
  && mkdir -p /usr/local/lib/pgmodeler/plugins \
  && chmod 777 /usr/local/lib/pgmodeler/plugins

# Clean unnecessary packages
RUN apt-get remove --purge -y $BUILD_PKGS \
  && rm -rf /var/lib/apt/lists/*

# Run pgModeler
ENTRYPOINT ["/usr/local/bin/pgmodeler"]