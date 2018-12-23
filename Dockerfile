FROM postgres:10

ENV PGHOST localhost
ENV PGPORT 5432
ENV PGUSER postgres
ENV PGPASSWORD secure
ENV PGDATABASE postgres
ENV DUMPPATH /dumps
ENV DUMPGLOBALS 0

RUN mkdir /dumps && chown postgres:postgres /dumps

VOLUME ["/dumps"]

USER postgres

COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh