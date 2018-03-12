FROM alpine:3.7

RUN set -ex; \
    addgroup -S pgbouncer; \
    adduser -S -G pgbouncer pgbouncer

ENV VERSION_TAG=pgbouncer_1_8_1

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        autoconf \
        autoconf-doc \
        automake \
        c-ares-dev \
        gcc \
        git \
        libc-dev \
        libevent-dev \
        libtool \
        make \
        openssl-dev \
        py-docutils \
    ; \
    apk add --no-cache --virtual .run-deps \
        c-ares \
        libevent \
        openssl \
        su-exec \
    ; \
    git clone --branch ${VERSION_TAG} --depth 1 https://github.com/pgbouncer/pgbouncer.git; \
    cd ../pgbouncer; \
    git submodule init; \
    git submodule update; \
    ./autogen.sh; \
    ./configure --prefix=/usr/local --with-libevent=/usr/lib; \
    make; \
    make install; \
    apk del --purge \
        .build-deps \
    ; \
    cd ..; \
    rm -Rf pgbouncer

EXPOSE 6432

COPY pg_hba.conf /etc/pgbouncer/config/
COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["pgbouncer", "/run/secrets/pgbouncer_config.ini"]
