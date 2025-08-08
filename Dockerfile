FROM debian:12 AS build

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /src

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    devscripts \
    debhelper \
    equivs \
    fakeroot \
    dpkg-dev \
    file \
 && rm -rf /var/lib/apt/lists/*

COPY debian/control debian/
RUN apt-get update && \
    mk-build-deps -ir -t 'apt-get -y --no-install-recommends' debian/control && \
    rm -rf /var/lib/apt/lists/*

COPY . .
RUN dpkg-buildpackage -us -uc -b

RUN mkdir -p /out && \
    for f in ../*.deb ../*.changes ../*.buildinfo ../*.dsc ../*.tar.*; do \
      if [ -e "$f" ]; then cp -v "$f" /out/; fi; \
    done

FROM scratch
COPY --from=build /out/ /out/
