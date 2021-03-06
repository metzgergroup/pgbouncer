FROM alpine:3.10

RUN set -ex; \
    addgroup -S pgbouncer; \
    adduser -D -S -s /sbin/nologin -G pgbouncer pgbouncer

# https://pgbouncer.github.io/downloads/
ENV PGBOUNCER_VERSION=1.12.0
ENV PGBOUNCER_SHA256=1b3c6564376cafa0da98df3520f0e932bb2aebaf9a95ca5b9fa461e9eb7b273e
ENV CONFIG_DIR=/etc/pgbouncer

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
    mkdir ${CONFIG_DIR}; \
    cp ./etc/pgbouncer.ini ${CONFIG_DIR}/; \
    touch ${CONFIG_DIR}/userlist.txt; \
    sed -i \
      -e "s|logfile =|#logfile = |" \
      -e "s|pidfile =|#pidfile = |" \
      -e "s|listen_addr =.*|listen_addr = 0.0.0.0|" \
      -e "s|auth_type =.*|auth_type = hba|" \
      -e "s|;auth_hba_file =.*|auth_hba_file = ${CONFIG_DIR}/pg_hba.conf|" \
      -e "s|pool_mode =.*|pool_mode = transaction|" \
      ${CONFIG_DIR}/pgbouncer.ini; \
    cd ..; \
    rm pgbouncer-$PGBOUNCER_VERSION.tar.gz; \
    rm -rf pgbouncer-$PGBOUNCER_VERSION; \
    apk del .build-deps

COPY pg_hba.conf ${CONFIG_DIR}/

EXPOSE 6432

CMD ["pgbouncer", "-u", "pgbouncer", "${CONFIG_DIR}/pgbouncer.ini"]
