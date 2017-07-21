FROM arm32v6/alpine:3.6

ENV REDIS_VER=4.0.0

RUN addgroup -S redis && adduser -S -G redis redis && \
    apk add --no-cache "su-exec>=0.2" && \
    apk add --no-cache --virtual .deps gcc linux-headers make musl-dev tar curl && \
    curl https://raw.githubusercontent.com/antirez/redis-hashes/master/README | grep -F redis-$REDIS_VER.tar.gz > hash && \
    SHA=$(cut -d ' ' -f 4 hash) && URL=$(cut -d ' ' -f 5 hash) && rm hash && \
    curl $URL -o redis.tar.gz && \
    echo "$SHA *redis.tar.gz" | sha256sum -c - && \
    SRC_DIR="/usr/src/redis" && \
    mkdir -p $SRC_DIR && \
    tar xzvf redis.tar.gz --strip-components=1 -C $SRC_DIR && \
    make -C $SRC_DIR && make -C $SRC_DIR install && \
    rm redis.tar.gz $SRC_DIR -rf && \
    apk del .deps && \
    apk add --no-cache libgcc && \
    mkdir /data && chown redis:redis /data

EXPOSE 6379
VOLUME /data
WORKDIR /data

# forked from frozenfoxx/rpi-redis
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["redis-server"]
