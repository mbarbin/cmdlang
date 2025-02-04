Checking behavior of basic types.

String.

  $ ./main_base.exe basic string --help
  print string
  
    main_base.exe basic string STRING
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic string --help
  print string
  
  Usage: ./main_climate.exe basic string [OPTIONS] <STRING>
  
  Arguments:
    <STRING>  value
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic string --help=plain
  NAME
         ./main_cmdliner.exe-basic-string - print string
  
  SYNOPSIS
         ./main_cmdliner.exe basic string [OPTION]… STRING
  
  ARGUMENTS
         STRING (required)
             value.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe basic string exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe basic string --help
  Usage: ./main_stdlib_runner.exe basic string [OPTIONS] [ARGUMENTS]
  
  print string
  
  Arguments:
    <STRING>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

And run it too.

  $ ./main_base.exe basic string Hello
  Hello

  $ ./main_climate.exe basic string Hello
  Hello

  $ ./main_cmdliner.exe basic string Hello
  Hello

  $ ./main_stdlib_runner.exe basic string Hello
  Hello

Int.

  $ ./main_base.exe basic int --help
  print int
  
    main_base.exe basic int INT
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic int --help
  print int
  
  Usage: ./main_climate.exe basic int [OPTIONS] <INT>
  
  Arguments:
    <INT>  value
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic int --help=plain
  NAME
         ./main_cmdliner.exe-basic-int - print int
  
  SYNOPSIS
         ./main_cmdliner.exe basic int [OPTION]… INT
  
  ARGUMENTS
         INT (required)
             value.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe basic int exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_stdlib_runner.exe basic int --help
  Usage: ./main_stdlib_runner.exe basic int [OPTIONS] [ARGUMENTS]
  
  print int
  
  Arguments:
    <INT>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

And run it too.

  $ ./main_base.exe basic int 17
  17

  $ ./main_climate.exe basic int 17
  17

  $ ./main_cmdliner.exe basic int 17
  17

  $ ./main_stdlib_runner.exe basic int 17
  17

Negative numbers are not supported as positional arguments since they look like
flags.

  $ ./main_base.exe basic int -13
  Error parsing command line:
  
    unknown flag -13
  
  For usage information, run
  
    main_base.exe basic int -help
  
  [1]

  $ ./main_climate.exe basic int -13
  Unknown argument name: -1
  [124]

  $ ./main_cmdliner.exe basic int -13
  ./main_cmdliner.exe: unknown option '-1'.
  Usage: ./main_cmdliner.exe basic int [OPTION]… INT
  Try './main_cmdliner.exe basic int --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic int -13
  int: unknown option '-13'.
  Usage: ./main_stdlib_runner.exe basic int [OPTIONS] [ARGUMENTS]
  
  print int
  
  Arguments:
    <INT>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
  [2]

Float.

  $ ./main_base.exe basic float --help
  print float
  
    main_base.exe basic float FLOAT
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic float --help
  print float
  
  Usage: ./main_climate.exe basic float [OPTIONS] <FLOAT>
  
  Arguments:
    <FLOAT>  value
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic float --help=plain
  NAME
         ./main_cmdliner.exe-basic-float - print float
  
  SYNOPSIS
         ./main_cmdliner.exe basic float [OPTION]… FLOAT
  
  ARGUMENTS
         FLOAT (required)
             value.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe basic float exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_stdlib_runner.exe basic float --help
  Usage: ./main_stdlib_runner.exe basic float [OPTIONS] [ARGUMENTS]
  
  print float
  
  Arguments:
    <FLOAT>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

And run it too.

  $ ./main_base.exe basic float 3.14
  3.14

  $ ./main_climate.exe basic float 3.14
  3.14

  $ ./main_cmdliner.exe basic float 3.14
  3.14

  $ ./main_stdlib_runner.exe basic float 3.14
  3.14

Negative numbers are not supported as positional arguments since they look like
flags.

  $ ./main_base.exe basic float -13.8
  Error parsing command line:
  
    unknown flag -13.8
  
  For usage information, run
  
    main_base.exe basic float -help
  
  [1]

  $ ./main_climate.exe basic float -13.8
  Unknown argument name: -1
  [124]

  $ ./main_cmdliner.exe basic float -13.8
  ./main_cmdliner.exe: unknown option '-1'.
  Usage: ./main_cmdliner.exe basic float [OPTION]… FLOAT
  Try './main_cmdliner.exe basic float --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic float -13.8
  float: unknown option '-13.8'.
  Usage: ./main_stdlib_runner.exe basic float [OPTIONS] [ARGUMENTS]
  
  print float
  
  Arguments:
    <FLOAT>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
  [2]

Bool.

  $ ./main_base.exe basic bool --help
  print bool
  
    main_base.exe basic bool BOOL
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic bool --help
  print bool
  
  Usage: ./main_climate.exe basic bool [OPTIONS] <BOOL>
  
  Arguments:
    <BOOL>  value
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic bool --help=plain
  NAME
         ./main_cmdliner.exe-basic-bool - print bool
  
  SYNOPSIS
         ./main_cmdliner.exe basic bool [OPTION]… BOOL
  
  ARGUMENTS
         BOOL (required)
             value.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe basic bool exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_stdlib_runner.exe basic bool --help
  Usage: ./main_stdlib_runner.exe basic bool [OPTIONS] [ARGUMENTS]
  
  print bool
  
  Arguments:
    <BOOL>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

And run it too.

  $ ./main_base.exe basic bool true
  true

  $ ./main_climate.exe basic bool true
  true

  $ ./main_cmdliner.exe basic bool true
  true

  $ ./main_stdlib_runner.exe basic bool true
  true

--

  $ ./main_base.exe basic bool false
  false

  $ ./main_climate.exe basic bool false
  false

  $ ./main_cmdliner.exe basic bool false
  false

  $ ./main_stdlib_runner.exe basic bool false
  false

--

  $ ./main_base.exe basic bool True
  Error parsing command line:
  
    failed to parse BOOL value "True"
    (Failure "valid arguments: {false,true}")
  
  For usage information, run
  
    main_base.exe basic bool -help
  
  [1]

  $ ./main_climate.exe basic bool True
  Failed to parse the argument at position 0: invalid value: "True" (not an bool)
  [124]

  $ ./main_cmdliner.exe basic bool True
  ./main_cmdliner.exe: BOOL argument: invalid value 'True', either 'true' or
                       'false'
  Usage: ./main_cmdliner.exe basic bool [OPTION]… BOOL
  Try './main_cmdliner.exe basic bool --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic bool True
  bool: Failed to parse the argument at position 0: invalid value "True" (not a bool).
  Usage: ./main_stdlib_runner.exe basic bool [OPTIONS] [ARGUMENTS]
  
  print bool
  
  Arguments:
    <BOOL>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
  [2]

Invalid entry.

  $ ./main_base.exe basic bool Not_a_bool
  Error parsing command line:
  
    failed to parse BOOL value "Not_a_bool"
    (Failure "valid arguments: {false,true}")
  
  For usage information, run
  
    main_base.exe basic bool -help
  
  [1]

  $ ./main_climate.exe basic bool Not_a_bool
  Failed to parse the argument at position 0: invalid value: "Not_a_bool" (not an bool)
  [124]

  $ ./main_cmdliner.exe basic bool Not_a_bool
  ./main_cmdliner.exe: BOOL argument: invalid value 'Not_a_bool', either 'true'
                       or 'false'
  Usage: ./main_cmdliner.exe basic bool [OPTION]… BOOL
  Try './main_cmdliner.exe basic bool --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic bool Not_a_bool
  bool: Failed to parse the argument at position 0: invalid value "Not_a_bool" (not a bool).
  Usage: ./main_stdlib_runner.exe basic bool [OPTIONS] [ARGUMENTS]
  
  print bool
  
  Arguments:
    <BOOL>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
  [2]

File.

  $ ./main_base.exe basic file --help
  print file
  
    main_base.exe basic file FILE
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic file --help
  print file
  
  Usage: ./main_climate.exe basic file [OPTIONS] <FILE>
  
  Arguments:
    <FILE>  value
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic file --help=plain
  NAME
         ./main_cmdliner.exe-basic-file - print file
  
  SYNOPSIS
         ./main_cmdliner.exe basic file [OPTION]… FILE
  
  ARGUMENTS
         FILE (required)
             value.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe basic file exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_stdlib_runner.exe basic file --help
  Usage: ./main_stdlib_runner.exe basic file [OPTIONS] [ARGUMENTS]
  
  print file
  
  Arguments:
    <FILE>  value (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options

And run it too.

  $ ./main_base.exe basic file foo.txt
  foo.txt

  $ ./main_climate.exe basic file foo.txt
  foo.txt

  $ ./main_cmdliner.exe basic file foo.txt
  ./main_cmdliner.exe: FILE argument: no 'foo.txt' file or directory
  Usage: ./main_cmdliner.exe basic file [OPTION]… FILE
  Try './main_cmdliner.exe basic file --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic file foo.txt
  foo.txt

Same when the file actually exists

  $ echo "foo" | tee foo.txt
  foo

--

  $ ./main_base.exe basic file foo.txt
  foo.txt

  $ ./main_climate.exe basic file foo.txt
  foo.txt

  $ ./main_cmdliner.exe basic file foo.txt
  foo.txt

  $ ./main_stdlib_runner.exe basic file foo.txt
  foo.txt

--

  $ ./main_base.exe basic file /bogus/bar
  /bogus/bar

  $ ./main_climate.exe basic file /bogus/bar
  /bogus/bar

  $ ./main_cmdliner.exe basic file /bogus/bar
  ./main_cmdliner.exe: FILE argument: no '/bogus/bar' file or directory
  Usage: ./main_cmdliner.exe basic file [OPTION]… FILE
  Try './main_cmdliner.exe basic file --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic file /bogus/bar
  /bogus/bar
