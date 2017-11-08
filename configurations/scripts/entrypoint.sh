#!/bin/sh

if [ ! -e /tmp/entrypoint.lock ]; then
  chown wildfly:wildfly /opt/wildfly/ -R
  touch /tmp/entrypoint.lock
fi
