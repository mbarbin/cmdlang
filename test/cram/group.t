Characterizing the help of a group:

  $ ./main_base.exe basic --help
  Basic types
  
    main_base.exe basic SUBCOMMAND
  
  === subcommands ===
  
    bool                       . print bool
    file                       . print file
    float                      . print float
    int                        . print int
    string                     . print string
    help                       . explain a given subcommand (perhaps recursively)
  

  $ ./main_climate.exe basic --help
  Basic types
  
  Usage: ./main_climate.exe basic [COMMAND]
         ./main_climate.exe basic [OPTIONS]
  
  Options:
    -h, --help  Print help
  
  Commands:
    string  print string
    int     print int
    float   print float
    bool    print bool
    file    print file

  $ ./main_cmdliner.exe basic --help=plain
  NAME
         ./main_cmdliner.exe-basic - Basic types
  
  SYNOPSIS
         ./main_cmdliner.exe basic COMMAND …
  
  COMMANDS
         bool [OPTION]… BOOL
             print bool
  
         file [OPTION]… FILE
             print file
  
         float [OPTION]… FLOAT
             print float
  
         int [OPTION]… INT
             print int
  
         string [OPTION]… STRING
             print string
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe basic exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe basic --help
  Usage: ./main_stdlib_runner.exe basic [OPTIONS]
  
  Basic types
  
  Subcommands:
    string     print string
    int        print int
    float      print float
    bool       print bool
    file       print file
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

What happens when that group is run:

  $ ./main_base.exe basic
  Basic types
  
    main_base.exe basic SUBCOMMAND
  
  === subcommands ===
  
    bool                       . print bool
    file                       . print file
    float                      . print float
    int                        . print int
    string                     . print string
    help                       . explain a given subcommand (perhaps recursively)
  
  missing subcommand for command main_base.exe basic
  [1]

  $ ./main_climate.exe basic
  Basic types
  
  Usage: ./main_climate.exe basic [COMMAND]
         ./main_climate.exe basic [OPTIONS]
  
  Options:
    -h, --help  Print help
  
  Commands:
    string  print string
    int     print int
    float   print float
    bool    print bool
    file    print file

  $ ./main_cmdliner.exe basic
  ./main_cmdliner.exe: required COMMAND name is missing, must be one of 'bool', 'file', 'float', 'int' or 'string'.
  Usage: ./main_cmdliner.exe basic COMMAND …
  Try './main_cmdliner.exe basic --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic
  Usage: ./main_stdlib_runner.exe basic [OPTIONS]
  
  Basic types
  
  Subcommands:
    string     print string
    int        print int
    float      print float
    bool       print bool
    file       print file
  
  Options:
    -help  Display this list of options
    --help  Display this list of options
  [2]

Same with a group that has a default command:

  $ ./main_base.exe group --help
  A group command with a default
  
    main_base.exe group SUBCOMMAND
  
  === subcommands ===
  
    a                          . do nothing
    help                       . explain a given subcommand (perhaps recursively)
  

  $ ./main_climate.exe group --help
  A group command with a default
  
  Usage: ./main_climate.exe group [COMMAND]
         ./main_climate.exe group [OPTIONS] <STRING>
  
  Arguments:
    <STRING>  name
  
  Options:
    -h, --help  Print help
  
  Commands:
    a  do nothing

  $ ./main_cmdliner.exe group --help=plain
  NAME
         ./main_cmdliner.exe-group - A group command with a default
  
  SYNOPSIS
         ./main_cmdliner.exe group [COMMAND] …
  
  COMMANDS
         a [OPTION]…
             do nothing
  
  ARGUMENTS
         STRING (required)
             name.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe group exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe group --help
  Usage: ./main_stdlib_runner.exe group [OPTIONS] [ARGUMENTS]
  
  A group command with a default
  
  Subcommands:
    a     do nothing
  
  Arguments:
    <STRING>  name (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

Cover the execution of group a (does nothing):

  $ ./main_stdlib_runner.exe group a

What happens when that group with a default is run:

  $ ./main_base.exe group
  A group command with a default
  
    main_base.exe group SUBCOMMAND
  
  === subcommands ===
  
    a                          . do nothing
    help                       . explain a given subcommand (perhaps recursively)
  
  missing subcommand for command main_base.exe group
  [1]

  $ ./main_climate.exe group
  Missing required positional argument at position 0.
  [124]

  $ ./main_cmdliner.exe group
  ./main_cmdliner.exe: required argument STRING is missing
  Usage: ./main_cmdliner.exe group [COMMAND] …
  Try './main_cmdliner.exe group --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe group
  Missing required positional argument at position 0.
  [2]

And now running it with the required argument:

Default commands are not supported by core.command.

  $ ./main_base.exe group World
  A group command with a default
  
    main_base.exe group SUBCOMMAND
  
  === subcommands ===
  
    a                          . do nothing
    help                       . explain a given subcommand (perhaps recursively)
  
  unknown subcommand World
  [1]

  $ ./main_climate.exe group World
  Hello World

With cmdliner, this particular default command is not supported because the
positional argument is interpreted as an unknown command:

  $ ./main_cmdliner.exe group World
  ./main_cmdliner.exe: unknown command 'World', must be 'a'.
  Usage: ./main_cmdliner.exe group [COMMAND] …
  Try './main_cmdliner.exe group --help' or './main_cmdliner.exe --help' for more information.
  [124]

The recommended way to handle this in cmdliner is to add the special '--' token, such as in:

  $ ./main_cmdliner.exe group -- World
  Hello World

  $ ./main_stdlib_runner.exe group World
  Hello World
