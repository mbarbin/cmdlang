Checking the help when there are no arguments.

  $ ./main_base.exe return --help
  An empty command
  
    main_base.exe return 
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe return --help
  Usage: ./main_climate.exe return [OPTIONS]
  
  An empty command
  
  Options:
   --help, -h   Print help

  $ ./main_cmdliner.exe return --help=plain
  NAME
         ./main_cmdliner.exe-return - An empty command
  
  SYNOPSIS
         ./main_cmdliner.exe return [OPTION]…
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe return exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_stdlib_runner.exe return --help
  Usage: ./main_stdlib_runner.exe return [OPTIONS]
  
  An empty command
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

And run it too.

  $ ./main_base.exe return
  ()

  $ ./main_climate.exe return
  ()

  $ ./main_cmdliner.exe return
  ()

  $ ./main_stdlib_runner.exe return
  ()
