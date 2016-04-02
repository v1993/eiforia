#! /bin/bash

# A script for setting up environment for travis-ci testing.
# Sets up Lua and Luarocks.
# LUA must be "lua5.1", "lua5.2" or "luajit".
# luajit2.0 - master v2.0
# luajit2.1 - master v2.1

set -eufo pipefail

source .travis/platform.sh

LUA_HOME_DIR=$TRAVIS_BUILD_DIR/install/lua

mkdir $HOME/.lua

mkdir -p "$LUA_HOME_DIR"

if [ "$LUA" == "lua5.1" ]; then
  curl http://www.lua.org/ftp/lua-5.1.5.tar.gz | tar xz
  cd lua-5.1.5;
elif [ "$LUA" == "lua5.2" ]; then
  curl http://www.lua.org/ftp/lua-5.2.4.tar.gz | tar xz
  cd lua-5.2.4;
elif [ "$LUA" == "lua5.3" ]; then
  curl http://www.lua.org/ftp/lua-5.3.2.tar.gz | tar xz
  cd lua-5.3.2;
fi
# Build Lua without backwards compatibility for testing
perl -i -pe 's/-DLUA_COMPAT_(ALL|5_2)//' src/Makefile
make $PLATFORM
make INSTALL_TOP="$LUA_HOME_DIR" install;

ln -s $LUA_HOME_DIR/bin/lua $HOME/.lua/lua
ln -s $LUA_HOME_DIR/bin/luac $HOME/.lua/luac;

cd $TRAVIS_BUILD_DIR

lua -v

if [ "$LUA" == "lua5.1" ]; then
  rm -rf lua-5.1.5;
elif [ "$LUA" == "lua5.2" ]; then
  rm -rf lua-5.2.4;
elif [ "$LUA" == "lua5.3" ]; then
  rm -rf lua-5.3.2;
fi
