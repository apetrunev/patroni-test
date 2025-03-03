# docker build . -t patroni-pg:latest
# docker build --build-arg base_image="ubuntu:20.04" . -t patroni-pg-20.04:latest

ARG base_image="ubuntu:22.04"

FROM ${base_image}

ARG patroni_url="https://github.com/patroni/patroni/archive/refs/tags/v2.1.2.tar.gz"

RUN export DEBIAN_FRONTEND=noninteractive; \
    echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections; \
    echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y curl wget ca-certificates make lsb-release tzdata man-db vim git sudo \
    && install -d /usr/share/postgresql-common/pgdg \
    && curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    && sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && apt-get -y update \
    && apt install -y postgresql-common \
    && sed -i -E 's/^#create_main_cluster[[:space:]]+=[[:space:]]+.*$/create_main_cluster = false/g' /etc/postgresql-common/createcluster.conf \
    && apt-get install -y postgresql-14 pgbouncer postgresql-client-common postgresql-client-14 postgresql-client \
    && apt-get install -y python3-psycopg2 python3-pip \
    && apt-get install supervisor \
    && pip3 install cdiff patroni[psycopg3,etcd,etcd3,consul]==2.1.2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "\nexport PATH=$PATH:/usr/lib/postgresql/14/bin" >> /etc/profile
RUN mkdir -vp /patroni && chown -vR postgres:postgres /patroni
COPY patroni.yaml entrypoint.sh /patroni/
COPY patroni.yaml /var/lib/postgresql
COPY supervisord.conf /etc/supervisor/
COPY patroni.conf /etc/supervisor/conf.d/
WORKDIR /var/lib/postgresql
USER postgres
ENV PATH="$PATH:/usr/lib/postgresql/14/bin"
ENTRYPOINT ["supervisord"]
