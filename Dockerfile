FROM ubuntu:22.04
LABEL Author="@apazga"

# pgModeler version to use
ENV PG_VERSION 1.1.1

ADD https://codeload.github.com/pgmodeler/pgmodeler/tar.gz/v${PG_VERSION} /usr/local/src/
WORKDIR /usr/local/src/

# Add universe repository
RUN apt-get update && apt-get install -y software-properties-common \
  && add-apt-repository universe

# Install dependencies
RUN BUILD_PKGS="qmake6 build-essential libxml2-dev libpq-dev pkg-config cmake" \
  && RUNTIME_PKGS="qtdeclarative5-dev libqt6core6 libqt6svg6 qttools5-dev qttools5-dev-tools postgresql-server-dev-all qt6-base-dev libqt6svg6-dev" \
  && SECURITY_PKGS="ca-certificates" \
  && DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get -y install --no-install-recommends ${BUILD_PKGS} ${RUNTIME_PKGS} ${SECURITY_PKGS}

ENV PATH="/usr/lib/qt6/bin:$PATH"

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