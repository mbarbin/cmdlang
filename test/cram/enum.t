Characterizing translation and behavior of enumerated types.

Base.

  $ ./main_base.exe enum pos --help
  print color
  
    main_base.exe enum pos COLOR
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_base.exe enum pos red
  red

  $ ./main_base.exe enum pos INVALID
  Error parsing command line:
  
    failed to parse COLOR value "INVALID"
    (Failure "valid arguments: {blue,green,red}")
  
  For usage information, run
  
    main_base.exe enum pos -help
  
  [1]

  $ ./main_base.exe enum named --help
  print color
  
    main_base.exe enum named 
  
  === flags ===
  
    --color COLOR              . color
    [-help], -?                . print this help text and exit
  

  $ ./main_base.exe enum named --color red
  red

  $ ./main_base.exe enum named --color INVALID
  Error parsing command line:
  
    failed to parse --color value "INVALID".
    (Failure "valid arguments: {blue,green,red}")
  
  For usage information, run
  
    main_base.exe enum named -help
  
  [1]

Climate.

  $ ./main_climate.exe enum pos --help
  print color
  
  Usage: ./main_climate.exe enum pos [OPTIONS] <COLOR>
  
  Arguments:
    <COLOR>  color
  
  Options:
    -h, --help  Print help

  $ ./main_climate.exe enum pos red
  red

  $ ./main_climate.exe enum pos INVALID
  Failed to parse the argument at position 0: invalid value: "INVALID" (valid values are: red, green, blue)
  [124]

  $ ./main_climate.exe enum named --help
  print color
  
  Usage: ./main_climate.exe enum named [OPTIONS]
  
  Options:
        --color <COLOR>  color
    -h, --help           Print help

  $ ./main_climate.exe enum named --color red
  red

  $ ./main_climate.exe enum named --color INVALID
  Failed to parse the argument to "--color": invalid value: "INVALID" (valid values are: red, green, blue)
  [124]

Cmdliner.

  $ ./main_cmdliner.exe enum pos --help=plain
  NAME
         ./main_cmdliner.exe-enum-pos - print color
  
  SYNOPSIS
         ./main_cmdliner.exe enum pos [OPTION]… COLOR
  
  ARGUMENTS
         COLOR (required)
             color. COLOR must be one of 'red', 'green' or 'blue'.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe enum pos exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_cmdliner.exe enum pos red
  red

  $ ./main_cmdliner.exe enum pos INVALID
  ./main_cmdliner.exe: COLOR argument: invalid value 'INVALID', expected one of
                       'red', 'green' or 'blue'
  Usage: ./main_cmdliner.exe enum pos [OPTION]… COLOR
  Try './main_cmdliner.exe enum pos --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_cmdliner.exe enum named --help=plain
  NAME
         ./main_cmdliner.exe-enum-named - print color
  
  SYNOPSIS
         ./main_cmdliner.exe enum named [--color=COLOR] [OPTION]…
  
  OPTIONS
         --color=COLOR (required)
             color. COLOR must be one of 'red', 'green' or 'blue'.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe enum named exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_cmdliner.exe enum named --color red
  red

  $ ./main_cmdliner.exe enum named --color INVALID
  ./main_cmdliner.exe: option '--color': invalid value 'INVALID', expected one
                       of 'red', 'green' or 'blue'
  Usage: ./main_cmdliner.exe enum named [--color=COLOR] [OPTION]…
  Try './main_cmdliner.exe enum named --help' or './main_cmdliner.exe --help' for more information.
  [124]

Stdlib runner.

  $ ./main_stdlib_runner.exe enum pos --help
  Usage: ./main_stdlib_runner.exe enum pos [OPTIONS] [ARGUMENTS]
  
  print color
  
  Arguments:
    <COLOR>  color (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

  $ ./main_stdlib_runner.exe enum pos red
  red

  $ ./main_stdlib_runner.exe enum pos INVALID
  pos: Failed to parse the argument at position 0: invalid value "INVALID" (not a valid choice).
  Usage: ./main_stdlib_runner.exe enum pos [OPTIONS] [ARGUMENTS]
  
  print color
  
  Arguments:
    <COLOR>  color (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
  [2]

  $ ./main_stdlib_runner.exe enum named --help
  Usage: ./main_stdlib_runner.exe enum named [OPTIONS]
  
  print color
  
  Options:
    --color {red|green|blue}
     <COLOR> color (required)
    -help   Display this list of options
    --help  Display this list of options

  $ ./main_stdlib_runner.exe enum named --color red
  red

  $ ./main_stdlib_runner.exe enum named --color INVALID
  named: wrong argument 'INVALID'; option '--color' expects one of: red green blue.
  Usage: ./main_stdlib_runner.exe enum named [OPTIONS]
  
  print color
  
  Options:
    --color {red|green|blue}
     <COLOR> color (required)
    -help   Display this list of options
    --help  Display this list of options
  [2]
