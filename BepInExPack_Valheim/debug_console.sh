#!/bin/bash

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BASEDIR=$(cd "$a"; pwd -P)

LOGFILE="$BASEDIR/BepInEx/LogOutput.log"

open_terminal() {
  LOGFILE="$1"

# TAILCMD=$(cat <<EOF
# tail -f "$LOGFILE" | awk '
# {
#   line = \$0
#   lower = tolower(line)
#
#   if (lower ~ /error/) {
#     print "\033[31m" line "\033[0m"; next
#   } else if (lower ~ /warn/) {
#     print "\033[33m" line "\033[0m"; next
#   } else if (lower ~ /info/ || lower ~ /message/) {
#     print line; next
#   }
#   print "\033[34m" line "\033[0m"
# }'
# EOF
# )

TAILCMD=$(cat <<EOF
tail -f "$LOGFILE" | awk '
BEGIN { in_error = 0 }

{
  line = \$0
  lower = tolower(line)

  # Start error block
  if (lower ~ /error/) {
    print "\033[31m" line "\033[0m"
    in_error = 1
    next
  }

  # Stay red while in error block
  if (in_error) {
    # End error block if we hit an info, warn, or message line
    if (lower ~ /info/ || lower ~ /warn/ || lower ~ /message/) {
      in_error = 0
    } else {
      print "\033[31m" line "\033[0m"
      next
    }
  }

  # Now normal logic
  if (lower ~ /warn/) {
    print "\033[33m" line "\033[0m"; next
  }

  if (lower ~ /info/ || lower ~ /message/) {
    print line; next
  }

  # All other lines — blue
  print "\033[34m" line "\033[0m"
}'
EOF
)


  if command -v x-terminal-emulator >/dev/null; then
    x-terminal-emulator -e bash -c "$TAILCMD" &
  elif command -v konsole >/dev/null; then
    konsole -e bash -c "$TAILCMD" &
  elif command -v gnome-terminal >/dev/null; then
    gnome-terminal -- bash -c "$TAILCMD" &
  elif command -v xfce4-terminal >/dev/null; then
    xfce4-terminal -e bash -c "$TAILCMD" &
  elif command -v xterm >/dev/null; then
    xterm -hold -e bash -c "$TAILCMD" &
  else
    echo "No supported terminal found to display log."
    return
  fi
}

if [ ! -f "$LOGFILE" ]; then
  touch "$LOGFILE"
fi


# --- Start the game ---
"$@" &
GAME_PID=$!

# --- Start the log terminal ---
open_terminal "$LOGFILE"
CONSOLE_PID=$!

# --- Wait for the game to exit ---
wait "$GAME_PID"

# --- Kill the terminal ---
kill "$CONSOLE_PID" 2>/dev/null

exit 0
