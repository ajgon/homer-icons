#!/usr/bin/env sh

for icon in /icons/svg/*.svg; do
  for dim in 16 24 32 48 64 128 256; do
    rsvg-convert -w ${dim} -h $dim ${icon} > $(echo ${icon} | sed "s@svg/@png/${dim}x${dim}/@g" | sed "s@\.svg@.png@g")
  done
done

exec "$@"
