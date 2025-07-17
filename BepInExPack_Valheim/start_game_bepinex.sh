#!/bin/bash
# Universal BepInEx launcher for both Linux-native and Proton versions of Valheim

# BepInEx running script
#
# HOW TO USE:
# 1. Make this script executable with `chmod u+x ./start_game_bepinex.sh`
# 2. In Steam, go to game's preferences and change game's launch args to:
#    ./start_game_bepinex.sh %command%
# 3. Start the game via Steam
#
# To get a console output thats sorta of like the regular one use ./debug_console.sh ./start_game_bepinex.sh %command%
#
# NOTE: Edit the script only if you know what you're doing!

# Resolve base directory relative to this script
# Hopefully this resolves relative paths and links
a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)

isSteamLaunch=false
launch_args=()

export DOORSTOP_ENABLE=TRUE
export DOORSTOP_INVOKE_DLL_PATH="$BASEDIR/BepInEx/core/BepInEx.Preloader.dll"
export DOORSTOP_CORLIB_OVERRIDE_PATH="$BASEDIR/unstripped_corlib"


launch_linux_native() {


    export LD_LIBRARY_PATH="$BASEDIR/doorstop_libs:$LD_LIBRARY_PATH"
    export LD_PRELOAD="libdoorstop_x64.so:$LD_PRELOAD"


    if [ "$isSteamLaunch" = true ]; then
        "${launch_args[@]}"
    else
        exec "$BASEDIR/valheim.x86_64"
    fi


}

launch_proton() {

    export DOORSTOP_INVOKE_DLL_PATH="Z:\\$(echo "$DOORSTOP_INVOKE_DLL_PATH" | sed 's|/|\\|g')"
    export DOORSTOP_CORLIB_OVERRIDE_PATH="Z:\\$(echo "$DOORSTOP_CORLIB_OVERRIDE_PATH" | sed 's|/|\\|g')"
    export WINEDLLOVERRIDES="winhttp=n,b"


    if [ "$isSteamLaunch" = true ]; then
        "${launch_args[@]}"
    else
        exec "$BASEDIR/valheim.exe"
    fi
}




while [ $# -gt 0 ]; do
  case $1 in
    --doorstop-enable)
      export DOORSTOP_ENABLE=$(echo "$2" | tr a-z A-Z)
      shift 2
      ;;
    --doorstop-target)
      export DOORSTOP_INVOKE_DLL_PATH="$2"
      shift 2
      ;;
    --doorstop-dll-search-override)
      export DOORSTOP_CORLIB_OVERRIDE_PATH="$2"
      shift 2
      ;;
    SteamLaunch)
      isSteamLaunch=true
      launch_args+=("$1")
      shift 1
      ;;
    *)
      launch_args+=("$1")
      shift 1
      ;;
  esac
done




# --- Auto-select ---
if [ -f "$BASEDIR/valheim.x86_64" ]; then
    launch_linux_native
elif [ -f "$BASEDIR/valheim.exe" ]; then
    launch_proton
else
    echo "Could not find valheim.x86_64 or valheim.exe in $BASEDIR" >&2
    exit 1
fi
