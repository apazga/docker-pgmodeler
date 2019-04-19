FROM debian:stretch-slim
LABEL Author="@apazga"

# pgModeler version to use
ENV PG_VERSION 0.9.1

ADD https://codeload.github.com/pgmodeler/pgmodeler/tar.gz/v${PG_VERSION} /usr/local/src/
WORKDIR /usr/local/src/

# Install dependencies
RUN BUILD_PKGS="make g++ qt5-qmake libxml2-dev \
  libpq-dev pkg-config libqt5svg5-dev" \
  && RUNTIME_PKGS="qt5-default libqt5svg5 postgresql-server-dev-9.6" \
  && DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install ${BUILD_PKGS} ${RUNTIME_PKGS}

# Compile pgmodeler
RUN tar xvzf v${PG_VERSION} \
  && cd pgmodeler-${PG_VERSION} \
  && qmake pgmodeler.pro \
  && make && make install \
  && mkdir -p /usr/local/lib/pgmodeler/plugins \
  && chmod 777 /usr/local/lib/pgmodeler/plugins

# Clean unnecessary packages
RUN apt-get remove --purge -y $BUILD_PKGS \
  && rm -rf /var/lib/apt/lists/*

# Run pgModeler
ENTRYPOINT ["/usr/local/bin/pgmodeler"]