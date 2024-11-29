  $ ./main_base.exe doc --help
  Testing documentation features
  
    main_base.exe doc SUBCOMMAND
  
  This group is dedicated to testing documentation features.
  
  === subcommands ===
  
    args-doc-end-with-dots     . Args doc end with dots
    singleton-with-readme      . Singleton command with a readme
    help                       . explain a given subcommand (perhaps recursively)
  

  $ ./main_climate.exe doc --help
  Testing documentation features
  
  This group is dedicated to testing documentation features.
      
  
  Usage: ./main_climate.exe doc [COMMAND]
         ./main_climate.exe doc [OPTIONS]
  
  Options:
    -h, --help  Print help
  
  Commands:
    args-doc-end-with-dots  Args doc end with dots
    singleton-with-readme   Singleton command with a readme
  
  This is a readme.
  It can be written on multiple lines.
  

  $ ./main_cmdliner.exe doc --help=plain
  NAME
         ./main_cmdliner.exe-doc - Testing documentation features
  
  SYNOPSIS
         ./main_cmdliner.exe doc COMMAND …
  
          
  
         This group is dedicated to testing documentation features. 
  
  COMMANDS
         args-doc-end-with-dots [OPTION]… STRING STRING
             Args doc end with dots
  
         singleton-with-readme [OPTION]…
             Singleton command with a readme
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe doc exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe doc --help
  Usage: ./main_stdlib_runner.exe doc [OPTIONS]
  
  Testing documentation features
  
  
  This group is dedicated to testing documentation features.
      
  
  Subcommands:
    args-doc-end-with-dots     Args doc end with dots
    singleton-with-readme      Singleton command with a readme
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

A singleton command with a readme:

  $ ./main_base.exe doc singleton-with-readme --help
  Singleton command with a readme
  
    main_base.exe doc singleton-with-readme 
  
  This is a readme.
  It can be written on multiple lines.
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe doc singleton-with-readme --help
  Singleton command with a readme
  
  This is a readme.
  It can be written on multiple lines.
  
  
  Usage: ./main_climate.exe doc singleton-with-readme [OPTIONS]
  
  Options:
    -h, --help  Print help

  $ ./main_cmdliner.exe doc singleton-with-readme --help=plain
  NAME
         ./main_cmdliner.exe-doc-singleton-with-readme - Singleton command with
         a readme
  
  SYNOPSIS
         ./main_cmdliner.exe doc singleton-with-readme [OPTION]…
  
          
  
         This is a readme. It can be written on multiple lines.
  
          
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe doc singleton-with-readme exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe doc singleton-with-readme --help
  Usage: ./main_stdlib_runner.exe doc singleton-with-readme [OPTIONS]
  
  Singleton command with a readme
  
  
  This is a readme.
  It can be written on multiple lines.
  
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

Positional arguments are currently not documented in the help output of the base
commands. Cmdlang recommmand for arguments doc to be created without dots at the
end. A dot is systematically added when translating to cmdliner since this
integrates best with its formatting of help pages.

  $ ./main_base.exe doc args-doc-end-with-dots --help
  Args doc end with dots
  
    main_base.exe doc args-doc-end-with-dots STRING STRING
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe doc args-doc-end-with-dots --help
  Args doc end with dots
  
  Usage: ./main_climate.exe doc args-doc-end-with-dots [OPTIONS] <STRING> <STRING>
  
  Arguments:
    <STRING>  The doc for [a] in the code ends with a dot.
    <STRING>  The doc for [b] doesn't
  
  Options:
    -h, --help  Print help

  $ ./main_cmdliner.exe doc args-doc-end-with-dots --help=plain
  NAME
         ./main_cmdliner.exe-doc-args-doc-end-with-dots - Args doc end with
         dots
  
  SYNOPSIS
         ./main_cmdliner.exe doc args-doc-end-with-dots [OPTION]… STRING
         STRING
  
  ARGUMENTS
         STRING (required)
             The doc for [a] in the code ends with a dot.
  
         STRING (required)
             The doc for [b] doesn't.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe doc args-doc-end-with-dots exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe doc args-doc-end-with-dots --help
  Usage: ./main_stdlib_runner.exe doc args-doc-end-with-dots [OPTIONS] [ARGUMENTS]
  
  Args doc end with dots
  
  Arguments:
    <STRING>  The doc for [a] in the code ends with a dot (required)
    <STRING>  The doc for [b] doesn't (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

