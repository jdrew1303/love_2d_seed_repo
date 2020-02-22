#!/usr/bin/env bash

set -x

PACKAGE_NAME="love2d_demo"

LOVE2D_VERSION="0.10.2"
LOVE2D_WINDOWS_ZIP="https://bitbucket.org/rude/love/downloads/love-${LOVE2D_VERSION}-win32.zip"
LOVE2D_MAC_ZIP="https://bitbucket.org/rude/love/downloads/love-${LOVE2D_VERSION}-macosx-x64.zip"

### clean
if [ "$1" == "clean" ]; then
 rm -rf "target"
 exit;
fi


### deploy web version to github pages
if [ "$1" == "deploy" ]; then
 cd "target/${PACKAGE_NAME}-web"
 git init
 git config user.name "autodeploy"
 git config user.email "autodeploy"
 touch .
 git add .
 git commit -m "deploy to github pages"
 git push --force --quiet "https://${GH_TOKEN}@github.com/${$2}.git" master:gh-pages

 exit;
fi



##### build #####

find . -iname "*.lua" | xargs luac -p || { echo 'luac parse test failed' ; exit 1; }

mkdir "target"


### .love

cp -r src target/src
cd target/src

# # compile .ink story into lua table so the runtime will not need lpeg dep.
# lua lib/pink/pink/pink.lua parse game.ink > game.lua

zip -q -9 -r - . > "../dist/${PACKAGE_NAME}.love"
cd -

### windows .exe
if [ "$1" == "windows" ]; then 
    wget "$LOVE2D_WINDOWS_ZIP" -O "target/love-win.zip"; 
    unzip -o "target/love-win.zip" -d "target"

    tmp="target/tmp/"
    mkdir -p "$tmp$PACKAGE_NAME"
    
    cat "target/love-${LOVE2D_VERSION}-win32/love.exe" "target/${PACKAGE_NAME}.love" > "$tmp${PACKAGE_NAME}/${PACKAGE_NAME}.exe"
    cp  target/love-"${LOVE2D_VERSION}"-win32/*dll target/love-"${LOVE2D_VERSION}"-win32/license* "$tmp$PACKAGE_NAME"
    cd "$tmp"
    zip -q -9 -r - "$PACKAGE_NAME" > "${PACKAGE_NAME}-win.zip"
    cd -
    cp "$tmp${PACKAGE_NAME}-win.zip" "target/dist"
    rm -r "$tmp"
fi

### try building app for the web
if [ "$1" == "web" ]; then
    cd target
    rm -rf love.js *-web*
    git clone https://github.com/TannerRogalsky/love.js.git
    cd love.js
    git checkout 6fa910c2a28936c3ec4eaafb014405a765382e08
    git submodule update --init --recursive

    cd release-compatibility
    python ../emscripten/tools/file_packager.py game.data --preload ../../../target/src/@/ --js-output=game.js
    python ../emscripten/tools/file_packager.py game.data --preload ../../../target/src/@/ --js-output=game.js
    #yes, two times!
    # python -m SimpleHTTPServer 8000
    cd ../..
    cp -r love.js/release-compatibility "$PACKAGE_NAME-web"
    zip -q -9 -r - "$PACKAGE_NAME-web" > "dist/${PACKAGE_NAME}-web.zip"
fi

### mac dmg build
if [ "$1" == "macos" ]; then 
    wget "$LOVE2D_MAC_ZIP" -O "target/love-${LOVE2D_VERSION}-macos.zip"; 
    unzip -o "target/love-macos.zip" -d "target"

    tmp="target/tmp/"
    mkdir -p "$tmp$PACKAGE_NAME"

    cp "target/love-${LOVE2D_VERSION}-macos/love.app" "$tmp$PACKAGE_NAME"
    cp "target/${PACKAGE_NAME}.love" "$tmp$PACKAGE_NAME/love-${LOVE2D_VERSION}-macos/love.app/Contents/Resources/${PACKAGE_NAME}.love"
    cp  target/love-"${LOVE2D_VERSION}"-macos/*dll target/love-"${LOVE2D_VERSION}"-macos/license* "$tmp$PACKAGE_NAME"
    cd "$tmp"
    zip -q -9 -r - "$PACKAGE_NAME" > "${PACKAGE_NAME}-macos.zip"
    cd -
    cp "$tmp${PACKAGE_NAME}-macos.zip" "target/dist"
    rm -r "$tmp"
fi