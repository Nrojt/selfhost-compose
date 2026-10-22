#!/bin/sh
set -e
if [ ! -e /root/.config/opencode/opencode.json ]; then
  mkdir -p /root/.config/opencode
  cp -a /opt/opencode-config-template/. /root/.config/opencode/
fi
# Skills ship in the image; a persisted config volume only gets the new ones.
mkdir -p /root/.config/opencode/skills
for d in /opt/opencode-config-template/skills/*/; do
  [ -e "/root/.config/opencode/skills/$(basename "$d")" ] ||
    cp -a "$d" /root/.config/opencode/skills/
done
exec "$@"
