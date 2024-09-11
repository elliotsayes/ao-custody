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

amalg.lua -s stake/main.lua -o ../build/stake.lua \
    stake.const stake.parse stake.index stake.subprocess stake.handlers \
    utils.bint utils.tl-utils \
    dummy.dummy


# FINAL RESULT is build/main.lua