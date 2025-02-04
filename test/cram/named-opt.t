In this test we monitor the behavior and doc related to the `named_opt` construct.

Let's start with characterizing whether and how the default value appears in the help page.

  $ ./main_base.exe named opt string-with-docv --help
  Named_opt__string_with_docv
  
    main_base.exe named opt string-with-docv 
  
  === flags ===
  
    [--who WHO]                . Hello WHO?
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe named opt string-with-docv --help
  Named_opt__string_with_docv
  
  Usage: ./main_climate.exe named opt string-with-docv [OPTIONS]
  
  Options:
    -h, --help       Show this help message.
        --who <WHO>  Hello WHO?

  $ ./main_cmdliner.exe named opt string-with-docv --help=plain
  NAME
         ./main_cmdliner.exe-named-opt-string-with-docv -
         Named_opt__string_with_docv
  
  SYNOPSIS
         ./main_cmdliner.exe named opt string-with-docv [--who=WHO] [OPTION]…
  
  OPTIONS
         --who=WHO
             Hello WHO?
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe named opt string-with-docv exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe named opt string-with-docv --help
  Usage: ./main_stdlib_runner.exe named opt string-with-docv [OPTIONS]
  
  Named_opt__string_with_docv
  
  Options:
    --who <WHO> Hello WHO? (optional)
    -help       Display this list of options
    --help      Display this list of options

--

  $ ./main_base.exe named opt string-with-docv

  $ ./main_climate.exe named opt string-with-docv

  $ ./main_cmdliner.exe named opt string-with-docv

  $ ./main_stdlib_runner.exe named opt string-with-docv

--

  $ ./main_base.exe named opt string-with-docv --who Alice
  Hello Alice

  $ ./main_climate.exe named opt string-with-docv --who Alice
  Hello Alice

  $ ./main_cmdliner.exe named opt string-with-docv --who Alice
  Hello Alice

  $ ./main_stdlib_runner.exe named opt string-with-docv --who Alice
  Hello Alice

Characterizing the flag documentation when the `docv` parameter is not supplied.

  $ ./main_base.exe named opt string-without-docv --help
  Named_opt__string_without_docv
  
    main_base.exe named opt string-without-docv 
  
  === flags ===
  
    [--who STRING]             . Hello WHO?
    [-help], -?                . print this help text and exit
  

  $ ./main_climate.exe named opt string-without-docv --help
  Named_opt__string_without_docv
  
  Usage: ./main_climate.exe named opt string-without-docv [OPTIONS]
  
  Options:
    -h, --help          Show this help message.
        --who <STRING>  Hello WHO?

  $ ./main_cmdliner.exe named opt string-without-docv --help=plain
  NAME
         ./main_cmdliner.exe-named-opt-string-without-docv -
         Named_opt__string_without_docv
  
  SYNOPSIS
         ./main_cmdliner.exe named opt string-without-docv [--who=STRING]
         [OPTION]…
  
  OPTIONS
         --who=STRING
             Hello WHO?
  
  COMMON OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of auto,
             pager, groff or plain. With auto, the format is pager or plain
             whenever the TERM env var is dumb or undefined.
  
         --version
             Show version information.
  
  EXIT STATUS
         ./main_cmdliner.exe named opt string-without-docv exits with:
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  SEE ALSO
         ./main_cmdliner.exe(1)
  

  $ ./main_stdlib_runner.exe named opt string-without-docv --help
  Usage: ./main_stdlib_runner.exe named opt string-without-docv [OPTIONS]
  
  Named_opt__string_without_docv
  
  Options:
    --who <STRING> Hello WHO? (optional)
    -help          Display this list of options
    --help         Display this list of options

