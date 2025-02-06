# docker build . -t patroni-pg:latest
# docker build --build-arg base_image="ubuntu:20.04" . -t patroni-pg-20.04:latest

ARG base_image="ubuntu:22.04"

FROM ${base_image}

RUN export DEBIAN_FRONTEND=noninteractive; \
    echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections; \
    echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y curl wget ca-certificates make lsb-release tzdata \
    && install -d /usr/share/postgresql-common/pgdg \
    && curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    && sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && apt-get -y update \
    && apt install -y postgresql-common \
    && sed -i -E 's/^#create_main_cluster[[:space:]]+=[[:space:]]+.*$/create_main_cluster = false/g' /etc/postgresql-common/createcluster.conf \
    && apt-get install -y postgresql-14 \
    && apt-get install -y python3-psycopg2 python3-pip \
    && pip3 install patroni[psycopg3,etcd3,consul]==2.1.2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
