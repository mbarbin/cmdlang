Checking behavior of basic types.

String.

  $ ./main_base.exe basic string --help
  Print string.
  
    main_base.exe basic string STRING
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic string --help
  Print string.
  
  Usage: ./main_climate.exe basic string [OPTION]… <STRING>
  
  Arguments:
    <STRING>  A param with a value.
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic string --help=plain
  NAME
         ./main_cmdliner.exe-basic-string - Print string.
  
  SYNOPSIS
         ./main_cmdliner.exe basic string [OPTION]… STRING
  
  ARGUMENTS
         STRING (required)
             A param with a value.
  
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
  
  Print string.
  
  Arguments:
    <STRING>  A param with a value. (required)
  
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
  Print int.
  
    main_base.exe basic int INT
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic int --help
  Print int.
  
  Usage: ./main_climate.exe basic int [OPTION]… <INT>
  
  Arguments:
    <INT>  A param with a value.
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic int --help=plain
  NAME
         ./main_cmdliner.exe-basic-int - Print int.
  
  SYNOPSIS
         ./main_cmdliner.exe basic int [OPTION]… INT
  
  ARGUMENTS
         INT (required)
             A param with a value.
  
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
  
  Print int.
  
  Arguments:
    <INT>  A param with a value. (required)
  
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
  Error: Unknown argument name: -1
  
  Usage: ./main_climate.exe basic int [OPTION]… <INT>
  
  For more info, try running `./main_climate.exe basic int --help`.
  [124]

  $ ./main_cmdliner.exe basic int -13
  ./main_cmdliner.exe: unknown option '-1'.
  Usage: ./main_cmdliner.exe basic int [OPTION]… INT
  Try './main_cmdliner.exe basic int --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic int -13
  int: unknown option '-13'.
  Usage: ./main_stdlib_runner.exe basic int [OPTIONS] [ARGUMENTS]
  
  Print int.
  
  Arguments:
    <INT>  A param with a value. (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
  [2]

Float.

  $ ./main_base.exe basic float --help
  Print float.
  
    main_base.exe basic float FLOAT
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic float --help
  Print float.
  
  Usage: ./main_climate.exe basic float [OPTION]… <FLOAT>
  
  Arguments:
    <FLOAT>  A param with a value.
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic float --help=plain
  NAME
         ./main_cmdliner.exe-basic-float - Print float.
  
  SYNOPSIS
         ./main_cmdliner.exe basic float [OPTION]… FLOAT
  
  ARGUMENTS
         FLOAT (required)
             A param with a value.
  
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
  
  Print float.
  
  Arguments:
    <FLOAT>  A param with a value. (required)
  
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
  Error: Unknown argument name: -1
  
  Usage: ./main_climate.exe basic float [OPTION]… <FLOAT>
  
  For more info, try running `./main_climate.exe basic float --help`.
  [124]

  $ ./main_cmdliner.exe basic float -13.8
  ./main_cmdliner.exe: unknown option '-1'.
  Usage: ./main_cmdliner.exe basic float [OPTION]… FLOAT
  Try './main_cmdliner.exe basic float --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_stdlib_runner.exe basic float -13.8
  float: unknown option '-13.8'.
  Usage: ./main_stdlib_runner.exe basic float [OPTIONS] [ARGUMENTS]
  
  Print float.
  
  Arguments:
    <FLOAT>  A param with a value. (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
  [2]

Bool.

  $ ./main_base.exe basic bool --help
  Print bool.
  
    main_base.exe basic bool BOOL
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic bool --help
  Print bool.
  
  Usage: ./main_climate.exe basic bool [OPTION]… <BOOL>
  
  Arguments:
    <BOOL>  A param with a value.
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic bool --help=plain
  NAME
         ./main_cmdliner.exe-basic-bool - Print bool.
  
  SYNOPSIS
         ./main_cmdliner.exe basic bool [OPTION]… BOOL
  
  ARGUMENTS
         BOOL (required)
             A param with a value.
  
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
  
  Print bool.
  
  Arguments:
    <BOOL>  A param with a value. (required)
  
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
  Error: Failed to parse the argument at position 0: invalid value: "True" (not an bool)
  
  Usage: ./main_climate.exe basic bool [OPTION]… <BOOL>
  
  For more info, try running `./main_climate.exe basic bool --help`.
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
  
  Print bool.
  
  Arguments:
    <BOOL>  A param with a value. (required)
  
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
  Error: Failed to parse the argument at position 0: invalid value: "Not_a_bool" (not an bool)
  
  Usage: ./main_climate.exe basic bool [OPTION]… <BOOL>
  
  For more info, try running `./main_climate.exe basic bool --help`.
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
  
  Print bool.
  
  Arguments:
    <BOOL>  A param with a value. (required)
  
  Options:
    -help   Display this list of options
    --help  Display this list of options
  [2]

File.

  $ ./main_base.exe basic file --help
  Print file.
  
    main_base.exe basic file FILE
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe basic file --help
  Print file.
  
  Usage: ./main_climate.exe basic file [OPTION]… <FILE>
  
  Arguments:
    <FILE>  A param with a value.
  
  Options:
    -h, --help  Show this help message.

  $ ./main_cmdliner.exe basic file --help=plain
  NAME
         ./main_cmdliner.exe-basic-file - Print file.
  
  SYNOPSIS
         ./main_cmdliner.exe basic file [OPTION]… FILE
  
  ARGUMENTS
         FILE (required)
             A param with a value.
  
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
  
  Print file.
  
  Arguments:
    <FILE>  A param with a value. (required)
  
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
