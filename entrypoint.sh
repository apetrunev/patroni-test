#!/bin/sh

if [ "x$(whoami)" == "xroot" ]; then exit 1; fi

if ! test -f /var/lib/postgresq/patroni.yaml; then
  cp -av /patroni/patroni.yaml /var/lib/postgresql/patroni.yaml
fi

cd /var/lib/postgresql/ && patroni patroni.yaml
