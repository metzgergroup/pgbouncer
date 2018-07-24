FROM alpine:3.8

RUN set -ex; \
    addgroup -S pgbouncer; \
    adduser -D -S -s /sbin/nologin -G pgbouncer pgbouncer

# https://pgbouncer.github.io/downloads/
ENV PGBOUNCER_VERSION=1.8.1
ENV PGBOUNCER_SHA256=fa8bde2a2d2c8c80d53a859f8e48bc6713cf127e31c77d8f787bbc1d673e8dc8

RUN set -ex; \
    apk add --no-cache --virtual .run-deps \
        c-ares \
        libevent \
        libressl \
    ;

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        build-base \
        autoconf \
        wget \
        c-ares-dev \
        libevent-dev \
        libressl-dev \
    ; \
    wget https://pgbouncer.github.io/downloads/files/$PGBOUNCER_VERSION/pgbouncer-$PGBOUNCER_VERSION.tar.gz; \
    echo "$PGBOUNCER_SHA256  /pgbouncer-$PGBOUNCER_VERSION.tar.gz" | sha256sum -c - ; \
    tar -xzvf pgbouncer-$PGBOUNCER_VERSION.tar.gz; \
    cd pgbouncer-$PGBOUNCER_VERSION; \
    ./configure --prefix=/usr --disable-debug; \
    make; \
    make install; \
    mkdir /etc/pgbouncer; \
    cp ./etc/pgbouncer.ini /etc/pgbouncer/; \
    touch /etc/pgbouncer/userlist.txt; \
    sed -i -e "s|logfile = |#logfile = |" -e "s|pidfile = |#pidfile = |" -e "s|listen_addr = .*|listen_addr = 0.0.0.0|" -e "s|auth_type = .*|auth_type = md5|" /etc/pgbouncer/pgbouncer.ini; \
    cd ..; \
    rm pgbouncer-$PGBOUNCER_VERSION.tar.gz; \
    rm -rf pgbouncer-$PGBOUNCER_VERSION; \
    apk del .build-deps

CMD ["pgbouncer", "-u", "pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
