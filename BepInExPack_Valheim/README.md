The two files in here are an improved launcher setup that checks if its run native or with proton via the file extension.


to use, you would replace `start_game_bepinex.sh` in the Valheim install directory from BepInExPack Valheim with this 
`start_game_bepinex.sh` version and then you would add `debug_console.sh` to the same directory


The console almost emulates the output you might expect, but not all colors are the same, its good enough to do the job of debugging.



example command 
```
./debug_console.sh ./start_game_bepinex.sh %command%
```

