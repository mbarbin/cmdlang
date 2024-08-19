
  $ ./main_cmdliner.exe --help=plain
  NAME
         ./main_cmdliner.exe - Hello
  
  SYNOPSIS
         ./main_cmdliner.exe COMMAND …
  
  COMMANDS
         cmd1 [OPTION]…
             Hello command
  
         cmd2 [--verbose] [OPTION]…
             Hello let%bind command
  
         cmd3 [--bool=MYBOOL] [--int=INT] [--verbose] [OPTION]…
             Hello cmd3
  
         cmd4 [-n FLOAT] [OPTION]…
             Hello let%bind command
  
         cmd5 [OPTION]… A B [C]
             Hello positional
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  $ ./main_cmdliner.exe cmd1 --help=plain
  NAME
         ./main_cmdliner.exe-cmd1 - Hello command
  
  SYNOPSIS
         ./main_cmdliner.exe cmd1 [OPTION]…
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe cmd1 exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_cmdliner.exe cmd1
  Hello Wold

  $ ./main_cmdliner.exe cmd2 --help=plain
  NAME
         ./main_cmdliner.exe-cmd2 - Hello let%bind command
  
  SYNOPSIS
         ./main_cmdliner.exe cmd2 [--verbose] [OPTION]…
  
  OPTIONS
         -v, --verbose
             be more verbose.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe cmd2 exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_cmdliner.exe cmd2
  verbose = false

  $ ./main_cmdliner.exe cmd2 -v
  verbose = true

  $ ./main_cmdliner.exe cmd2 --verbose
  verbose = true

  $ ./main_cmdliner.exe cmd2 -verb
  ./main_cmdliner.exe: unknown option '-e'.
  Usage: ./main_cmdliner.exe cmd2 [--verbose] [OPTION]…
  Try './main_cmdliner.exe cmd2 --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_cmdliner.exe cmd3 --help=plain
  NAME
         ./main_cmdliner.exe-cmd3 - Hello cmd3
  
  SYNOPSIS
         ./main_cmdliner.exe cmd3 [--bool=MYBOOL] [--int=INT] [--verbose]
         [OPTION]…
  
  OPTIONS
         -b MYBOOL, --bool=MYBOOL
             Specify a value.
  
         -i INT, --int=INT (absent=42)
             Specify an int.
  
         -v, --verbose
             be more verbose.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe cmd3 exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_cmdliner.exe cmd3
  ((verbose false))
  ()
  42

  $ ./main_cmdliner.exe cmd3 --int=37 --bool=true
  ((verbose false))
  (true)
  37

  $ ./main_cmdliner.exe cmd3 --int 14
  ((verbose false))
  ()
  14

  $ ./main_cmdliner.exe cmd3 --in=37 --bo=true
  ((verbose false))
  (true)
  37

  $ ./main_cmdliner.exe cmd3 --i=37 --b=true
  ((verbose false))
  (true)
  37

  $ ./main_cmdliner.exe cmd3 -vb=true
  ./main_cmdliner.exe: option '-b': invalid value '=true', either 'true' or
                       'false'
  Usage: ./main_cmdliner.exe cmd3 [--bool=MYBOOL] [--int=INT] [--verbose] [OPTION]…
  Try './main_cmdliner.exe cmd3 --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_cmdliner.exe cmd3 -vb true
  ((verbose true))
  (true)
  42

  $ ./main_cmdliner.exe cmd3 -vbtrue
  ((verbose true))
  (true)
  42

  $ ./main_cmdliner.exe cmd4 --help=plain
  NAME
         ./main_cmdliner.exe-cmd4 - Hello let%bind command
  
  SYNOPSIS
         ./main_cmdliner.exe cmd4 [-n FLOAT] [OPTION]…
  
  OPTIONS
         -n FLOAT (required)
             a float to print.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe cmd4 exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_cmdliner.exe cmd4
  ./main_cmdliner.exe: required option -n is missing
  Usage: ./main_cmdliner.exe cmd4 [-n FLOAT] [OPTION]…
  Try './main_cmdliner.exe cmd4 --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_cmdliner.exe cmd4 -n 3
  3.

  $ ./main_cmdliner.exe cmd4 --n=3.14
  ./main_cmdliner.exe: unknown option '--n', did you mean '-n'?
  Usage: ./main_cmdliner.exe cmd4 [-n FLOAT] [OPTION]…
  Try './main_cmdliner.exe cmd4 --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_cmdliner.exe cmd4 -n3.14
  3.14

  $ ./main_cmdliner.exe cmd4 -n=3.14
  ./main_cmdliner.exe: option '-n': invalid value '=3.14', expected a floating
                       point number
  Usage: ./main_cmdliner.exe cmd4 [-n FLOAT] [OPTION]…
  Try './main_cmdliner.exe cmd4 --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_cmdliner.exe cmd4 -n 3.14
  3.14

  $ ./main_cmdliner.exe cmd5 --help=plain
  NAME
         ./main_cmdliner.exe-cmd5 - Hello positional
  
  SYNOPSIS
         ./main_cmdliner.exe cmd5 [OPTION]… A B [C]
  
  ARGUMENTS
         A (required)
             a first float.
  
         B (required)
             a second float.
  
         C (absent=3.14)
             another float.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe cmd5 exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_cmdliner.exe cmd5 1.2 3.4
  ((a 1.2) (b 3.4) (c 3.14))

  $ ./main_cmdliner.exe cmd5 1.2 3.4 5.6
  ((a 1.2) (b 3.4) (c 5.6))
