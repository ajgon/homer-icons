#!/usr/bin/env sh

VERSION="$(git tag -l | sort -Vr | head -n 1 | awk -F'[.-]' '{$(NF - 1) = $(NF - 1) + 1; $NF = 0; print $0}' | sed 's/ /./g')"

function optimizesvg() {
  echo -n "Optimizing SVGs...   "
  svgo /icons/svg/*.svg > /tmp/svgo.log 2>&1
  if [ $? != 0 ]; then
    echo -e "ERROR!\n"
    cat /tmp/svgo.log
    exit 1
  fi
  echo "OK"
}


function generatepng() {
  echo -n "Generating PNGs...   "
  for icon in /icons/svg/*.svg; do
    for dim in 16 24 32 48 64 128 256; do
      rsvg-convert -w ${dim} -h ${dim} ${icon} > $(echo ${icon} | sed "s@svg/@png/${dim}x${dim}/@g" | sed "s@\.svg@.png@g")
      if [ $? != 0 ]; then
        echo -e "ERROR!\n"
        echo "problematic command: rsvg-convert -w ${dim} -h ${dim} ${icon} > $(echo ${icon} | sed "s@svg/@png/${dim}x${dim}/@g" | sed "s@\.svg@.png@g")"
        exit 1
      fi
    done
  done
  echo "OK"
}

function ziprelease() {
  echo -n "Building release...  "
  zip -r releases/icons-${VERSION}.zip svg/*.svg png/*/*.png > /tmp/zip.log 2>&1
  if [ $? != 0 ]; then
    echo -e "ERROR!\n"
    cat /tmp/zip.log
    exit 1
  fi
  tar -czvf releases/icons-${VERSION}.tar.gz svg/*.svg png/*/*.png > /tmp/tar.log 2>&1
  if [ $? != 0 ]; then
    echo -e "ERROR!\n"
    cat /tmp/tar.log
    exit 1
  fi
  echo "OK"
}

function release() {
  echo -n "Releasing package... "
  git fetch --all > /tmp/git.log 2>&1 && \
  git add -A >> /tmp/git.log 2>&1 && \
  (git commit -m "release: ${VERSION}" -an || true) >> /tmp/git.log 2>&1 && \
  git tag ${VERSION} >> /tmp/git.log 2>&1 && \
  git push origin master --tags >> /tmp/git.log 2>&1 && \
  gh release create ${VERSION} releases/icons-${VERSION}.zip releases/icons-${VERSION}.tar.gz >> /tmp/git.log 2>&1
  if [ $? != 0 ]; then
    echo -e "ERROR!\n"
    cat /tmp/git.log
    exit 1
  fi
  echo "OK"
}

case "$1" in
  optimize)
    optimizesvg
    ;;
  generate)
    optimizesvg
    generatepng
    ;;
  build|"")
    optimizesvg
    generatepng
    ziprelease
    ;;
  release)
    optimizesvg
    generatepng
    ziprelease
    release
    ;;
  *)
    exec "$@"
    ;;
esac
