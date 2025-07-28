Characterizing translation and behavior of various flag types.

  $ ./main_base.exe flags names --help
  Various flags.
  
    main_base.exe flags names 
  
  === flags ===
  
    [--long]                   . A long flag.
    [-a]                       . A short flag.
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe flags names --help
  Various flags.
  
  Usage: ./main_climate.exe flags names [OPTION]…
  
  Options:
    -a          A short flag.
        --long  A long flag.
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe flags names --help=plain
  NAME
         ./main_cmdliner.exe-flags-names - Various flags.
  
  SYNOPSIS
         ./main_cmdliner.exe flags names [-a] [--long] [OPTION]…
  
  OPTIONS
         -a  A short flag.
  
         --long
             A long flag.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe flags names exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe flags names --help
  Usage: ./main_stdlib_runner.exe flags names [OPTIONS]
  
  Various flags.
  
  Options:
    --long  A long flag. (optional)
    -a      A short flag. (optional)
    -help   Display this list of options
    --help  Display this list of options

Cover the execution:

  $ ./main_stdlib_runner.exe flags names
