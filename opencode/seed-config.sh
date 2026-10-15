#!/bin/sh
set -e
if [ ! -e /root/.config/opencode/opencode.json ]; then
  mkdir -p /root/.config/opencode
  cp -a /opt/opencode-config-template/. /root/.config/opencode/
fi
exec "$@"
