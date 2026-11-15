FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends bash gawk passwd \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --system logtool \
    && useradd --system --gid logtool --home-dir /nonexistent \
       --shell /usr/sbin/nologin logtool

WORKDIR /app

COPY logtool.sh /usr/local/bin/logtool
RUN chmod 755 /usr/local/bin/logtool

USER logtool

ENTRYPOINT ["/usr/local/bin/logtool"]
