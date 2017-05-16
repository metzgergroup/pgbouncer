FROM alpine:latest

RUN set -x \
    && addgroup -S pgbouncer \
    && adduser -S -G pgbouncer pgbouncer
    # && adduser -u 1000 -G pgbouncer -s /bin/sh -D pgbouncer

RUN set -x \
    && apk add --no-cache su-exec

ENV VERSION_TAG pgbouncer_1_7_2

RUN set -x \
    && apk add --no-cache git build-base automake libtool m4 autoconf libevent-dev openssl-dev c-ares-dev patch python-dev \
    && git clone --branch ${VERSION_TAG} --depth 1 https://github.com/pgbouncer/pgbouncer.git \
    # Merge pgbouncer-rr extensions into pgbouncer code
    && git clone --depth 1 https://github.com/awslabs/pgbouncer-rr-patch.git \
    && cd pgbouncer-rr-patch \
    && ./install-pgbouncer-rr-patch.sh ../pgbouncer \
    # Continue with standard pgbouncer installation
    && cd ../pgbouncer \
    && git submodule init \
    && git submodule update \
    && ./autogen.sh \
    && ./configure --prefix=/usr/local --with-libevent=/usr/lib \
    && make \
    && make install \
    && apk del git build-base automake autoconf libtool m4 \
    && cd .. \
    && rm -Rf pgbouncer pgbouncer-rr-patch

EXPOSE 6432

COPY entrypoint.sh /usr/local/bin/
COPY config/development.ini config/production.ini config/pg_hba.conf /etc/pgbouncer/config/

RUN set -x \
    && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["pgbouncer", "/etc/pgbouncer/config/production.ini"]
