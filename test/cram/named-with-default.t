In this test we monitor the behavior related to the `named_with_default` construct.

Let's start with characterizing whether and how the default value appears in the help page.

At the moment, the default value is not displayed in the help page for the `base` backend.

  $ ./main_base.exe named with-default string --help
  Named_with_default__string
  
    main_base.exe named with-default string 
  
  === flags ===
  
    [--who WHO]                . Hello WHO?
    [-help], -?                . print this help text and exit
  

At the moment, the default value is not displayed in the help page for the
`climate` backend. There is also some kind of an issue with the alignment of the
help page.

  $ ./main_climate.exe named with-default string --help
  Usage: ./main_climate.exe named with-default string [OPTIONS]
  
  Named_with_default__string
  
  Options:
   --who <WHO>   Hello WHO?
   --help, -h   Print help

In the cmdliner backend, the default value is shown next to the option, in
parentheses. See `(absent=...)` below.

  $ ./main_cmdliner.exe named with-default string --help=plain
  NAME
         ./main_cmdliner.exe-named-with-default-string -
         Named_with_default__string
  
  SYNOPSIS
         ./main_cmdliner.exe named with-default string [--who=WHO] [OPTION]…
  
  OPTIONS
         --who=WHO (absent=World)
             Hello WHO?.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe named with-default string exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

Let's check behavior when the default value is used.

  $ ./main_base.exe named with-default string
  Hello World

  $ ./main_climate.exe named with-default string
  Hello World

  $ ./main_cmdliner.exe named with-default string
  Hello World

And when a value is provided.

  $ ./main_base.exe named with-default string --who You
  Hello You

  $ ./main_climate.exe named with-default string --who=You
  Hello You

  $ ./main_cmdliner.exe named with-default string --who=You
  Hello You

We also exercises some default for param constructs involving custom print
functions or parsers generated from modules with utils.

  $ ./main_base.exe named with-default create --who A
  Hello A

  $ ./main_climate.exe named with-default create --who=A
  Hello A

  $ ./main_cmdliner.exe named with-default create --who=A
  Hello A

  $ ./main_base.exe named with-default create --who B
  Hello B

  $ ./main_climate.exe named with-default create --who=B
  Hello B

  $ ./main_cmdliner.exe named with-default create --who=B
  Hello B

  $ ./main_base.exe named with-default create --who C
  Error parsing command line:
  
    failed to parse --who value "C".
    (Msg "\"C\": invalid E.t")
  
  For usage information, run
  
    main_base.exe named with-default create -help
  
  [1]

  $ ./main_climate.exe named with-default create --who=C
  Failed to parse the argument to "--who": "C": invalid E.t
  [124]

  $ ./main_cmdliner.exe named with-default create --who=C
  ./main_cmdliner.exe: option '--who': "C": invalid E.t
  Usage: ./main_cmdliner.exe named with-default create [--who=(A|B)] [OPTION]…
  Try './main_cmdliner.exe named with-default create --help' or './main_cmdliner.exe --help' for more information.
  [124]

  $ ./main_base.exe named with-default create --help
  Named_with_default__create
  
    main_base.exe named with-default create 
  
  === flags ===
  
    [--who Greet]              . A or B?
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe named with-default create --help
  Usage: ./main_climate.exe named with-default create [OPTIONS]
  
  Named_with_default__create
  
  Options:
   --who <(A|B)>   Greet A or B?
   --help, -h   Print help

  $ ./main_cmdliner.exe named with-default create --help=plain
  NAME
         ./main_cmdliner.exe-named-with-default-create -
         Named_with_default__create
  
  SYNOPSIS
         ./main_cmdliner.exe named with-default create [--who=(A|B)]
         [OPTION]…
  
  OPTIONS
         --who=(A|B) (absent=A)
             Greet A or B?.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe named with-default create exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
Named-with-default with a stringable parameter.

  $ ./main_base.exe named with-default stringable --help
  Named_with_default__stringable
  
    main_base.exe named with-default stringable 
  
  === flags ===
  
    [--who _]                  . identifier
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe named with-default stringable --help
  Usage: ./main_climate.exe named with-default stringable [OPTIONS]
  
  Named_with_default__stringable
  
  Options:
   --who <VAL>   identifier
   --help, -h   Print help

  $ ./main_cmdliner.exe named with-default stringable --help=plain
  NAME
         ./main_cmdliner.exe-named-with-default-stringable -
         Named_with_default__stringable
  
  SYNOPSIS
         ./main_cmdliner.exe named with-default stringable [--who=VAL]
         [OPTION]…
  
  OPTIONS
         --who=VAL (absent=my-id)
             identifier.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe named with-default stringable exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_base.exe named with-default stringable
  Hello my-id

  $ ./main_climate.exe named with-default stringable
  Hello my-id

  $ ./main_cmdliner.exe named with-default stringable
  Hello my-id

Named-with-default with a validated string parameter.

  $ ./main_base.exe named with-default validated --help
  Named_with_default__validated
  
    main_base.exe named with-default validated 
  
  === flags ===
  
    [--who 4]                  . letters alphanumerical identifier
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe named with-default validated --help
  Usage: ./main_climate.exe named with-default validated [OPTIONS]
  
  Named_with_default__validated
  
  Options:
   --who <VAL>   4 letters alphanumerical identifier
   --help, -h   Print help

  $ ./main_cmdliner.exe named with-default validated --help=plain
  NAME
         ./main_cmdliner.exe-named-with-default-validated -
         Named_with_default__validated
  
  SYNOPSIS
         ./main_cmdliner.exe named with-default validated [--who=VAL]
         [OPTION]…
  
  OPTIONS
         --who=VAL (absent=0000)
             4 letters alphanumerical identifier.
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe named with-default validated exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_base.exe named with-default validated
  Hello 0000

  $ ./main_climate.exe named with-default validated
  Hello 0000

  $ ./main_cmdliner.exe named with-default validated
  Hello 0000

Invalid entry for the validated string parameter.

  $ ./main_base.exe named with-default validated --who foo
  Error parsing command line:
  
    failed to parse --who value "foo".
    (Msg "\"foo\": invalid 4 letters alphanumerical identifier")
  
  For usage information, run
  
    main_base.exe named with-default validated -help
  
  [1]

  $ ./main_climate.exe named with-default validated --who foo
  Failed to parse the argument to "--who": "foo": invalid 4 letters alphanumerical identifier
  [124]

  $ ./main_cmdliner.exe named with-default validated --who foo
  ./main_cmdliner.exe: option '--who': "foo": invalid 4 letters alphanumerical
                       identifier
  Usage: ./main_cmdliner.exe named with-default validated [--who=VAL] [OPTION]…
  Try './main_cmdliner.exe named with-default validated --help' or './main_cmdliner.exe --help' for more information.
  [124]

Valid entry for the validated string parameter.

  $ ./main_base.exe named with-default validated --who foo7
  Hello foo7

  $ ./main_climate.exe named with-default validated --who foo7
  Hello foo7

  $ ./main_cmdliner.exe named with-default validated --who foo7
  Hello foo7

Named-with-default with a comma-separated string parameter.

  $ ./main_base.exe named with-default comma-separated --help
  Named_with_default__comma_separated
  
    main_base.exe named with-default comma-separated 
  
  === flags ===
  
    [--who Hello]              . WHO?
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe named with-default comma-separated --help
  Usage: ./main_climate.exe named with-default comma-separated [OPTIONS]
  
  Named_with_default__comma_separated
  
  Options:
   --who <STRING>   Hello WHO?
   --help, -h   Print help

  $ ./main_cmdliner.exe named with-default comma-separated --help=plain
  NAME
         ./main_cmdliner.exe-named-with-default-comma-separated -
         Named_with_default__comma_separated
  
  SYNOPSIS
         ./main_cmdliner.exe named with-default comma-separated
         [--who=[STRING,..]] [OPTION]…
  
  OPTIONS
         --who=[STRING,..] (absent=World)
             Hello WHO? (comma-separated).
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe named with-default comma-separated exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  
  $ ./main_base.exe named with-default comma-separated
  Hello World

  $ ./main_climate.exe named with-default comma-separated
  Hello World

  $ ./main_cmdliner.exe named with-default comma-separated
  Hello World

Valid entry for the parameter.

  $ ./main_base.exe named with-default comma-separated --who You,Me
  Hello You
  Hello Me

  $ ./main_climate.exe named with-default comma-separated --who You,Me
  Hello You
  Hello Me

  $ ./main_cmdliner.exe named with-default comma-separated --who You,Me
  Hello You
  Hello Me
