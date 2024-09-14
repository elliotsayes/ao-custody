#!/bin/bash

if [[ "$(uname)" == "Linux" ]]; then
    BIN_PATH="$HOME/.luarocks/bin"
else
    BIN_PATH="/opt/homebrew/bin"
fi

# GENERATE LUA in /build-lua
mkdir -p ./build
mkdir -p ./build-lua

# build teal
cyan build -u

cd build-lua

amalg.lua -s custody-creator/main.lua -o ../build/custody-creator.lua \
    custody-creator.const custody-creator.parse custody-creator.index custody-creator.subprocess custody-creator.handlers \

amalg.lua -s custody/main.lua -o ../build/custody.lua \
    utils.bint utils.tl-utils \
    dummy.dummy

cd ../build
lua ../scripts/build_send_custody_src.lua

# FINAL RESULT is build/main.lua