In this test we monitor the global help page that is generated at the root of
the executable for each backend.

  $ ./main_base.exe --help
  Cram Test Commands.
  
    main_base.exe SUBCOMMAND
  
  === subcommands ===
  
    basic                      . Basic types.
    doc                        . Testing documentation features.
    enum                       . Enum types.
    flags                      . Flags.
    group                      . A group command with a default.
    named                      . Named arguments
    return                     . An empty command.
    version                    . print version information
    help                       . explain a given subcommand (perhaps recursively)
  

  $ ./main_climate.exe --help
  Cram Test Commands.
  
  Usage: ./main_climate.exe [COMMAND]
         ./main_climate.exe [OPTION]…
  
  Options:
    -h, --help  Show this help message.
  
  Commands:
    basic   Basic types.
    doc     Testing documentation features.
  This group is dedicated to testing documentation features.
    enum    Enum types.
    flags   Flags.
    group   A group command with a default.
    named   Named arguments
    return  An empty command.

  $ ./main_cmdliner.exe --help=plain
  NAME
         ./main_cmdliner.exe - Cram Test Commands.
  
  SYNOPSIS
         ./main_cmdliner.exe COMMAND …
  
  COMMANDS
         basic COMMAND …
             Basic types.
  
         doc COMMAND …
             Testing documentation features.
  
         enum COMMAND …
             Enum types.
  
         flags COMMAND …
             Flags.
  
         group [COMMAND] …
             A group command with a default.
  
         named COMMAND …
             Named arguments
  
         return [OPTION]…
             An empty command.
  
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
  

  $ ./main_stdlib_runner.exe --help
  Usage: ./main_stdlib_runner.exe [OPTIONS]
  
  Cram Test Commands.
  
  Subcommands:
    basic      Basic types.
    doc        Testing documentation features.
    enum       Enum types.
    flags      Flags.
    group      A group command with a default.
    named      Named arguments
    return     An empty command.
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
