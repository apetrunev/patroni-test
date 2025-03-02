#!/bin/sh

WDIR=/var/lib/postgresql

if [ "x$(whoami)" == "xroot" ]; then exit 1; fi

if ! test -f $WDIR/patroni.yaml; then
  cp -av /patroni/patroni.yaml $WDIR/patroni.yaml
fi

cd $WDIR/ && patroni patroni.yaml
