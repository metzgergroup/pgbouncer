FROM alpine:3.6

RUN set -ex; \
    addgroup -S pgbouncer; \
    adduser -S -G pgbouncer pgbouncer

RUN apk add --no-cache su-exec

ENV VERSION_TAG pgbouncer_1_7_2

RUN set -ex; \
    apk add --no-cache git build-base automake libtool m4 autoconf libevent-dev openssl-dev c-ares-dev patch python-dev; \
    git clone --branch ${VERSION_TAG} --depth 1 https://github.com/pgbouncer/pgbouncer.git; \
    # Merge pgbouncer-rr extensions into pgbouncer code
    git clone --depth 1 https://github.com/awslabs/pgbouncer-rr-patch.git; \
    cd pgbouncer-rr-patch; \
    ./install-pgbouncer-rr-patch.sh ../pgbouncer; \
    # Continue with standard pgbouncer installation
    cd ../pgbouncer; \
    git submodule init; \
    git submodule update; \
    ./autogen.sh; \
    ./configure --prefix=/usr/local --with-libevent=/usr/lib; \
    make; \
    make install; \
    apk del git build-base automake autoconf libtool m4; \
    cd ..; \
    rm -Rf pgbouncer pgbouncer-rr-patch

EXPOSE 6432

COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["pgbouncer", "/run/secrets/pgbouncer_config"]

