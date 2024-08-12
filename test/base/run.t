
  $ ./main_base.exe --help
  Hello
  
    main_base.exe SUBCOMMAND
  
  === subcommands ===
  
    cmd1                       . Hello command
    cmd2                       . Hello let%bind command
    cmd3                       . Hello cmd3
    cmd4                       . Hello let%bind command
    cmd5                       . Hello positional
    version                    . print version information
    help                       . explain a given subcommand (perhaps recursively)
  
  $ ./main_base.exe cmd1 --help
  Hello command
  
    main_base.exe cmd1 
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  
  $ ./main_base.exe cmd1
  Hello Wold

  $ ./main_base.exe cmd2 --help
  Hello let%bind command
  
    main_base.exe cmd2 
  
  === flags ===
  
    [--verbose], -v            . be more verbose
    [-help], -?                . print this help text and exit
  
  $ ./main_base.exe cmd2
  verbose = false

  $ ./main_base.exe cmd2 -v
  verbose = true

  $ ./main_base.exe cmd2 -verbose
  Error parsing command line:
  
    unknown flag -verbose
  
  For usage information, run
  
    main_base.exe cmd2 -help
  
  [1]

  $ ./main_base.exe cmd2 -verb
  Error parsing command line:
  
    unknown flag -verb
  
  For usage information, run
  
    main_base.exe cmd2 -help
  
  [1]

  $ ./main_base.exe cmd2 --verbose
  verbose = true

  $ ./main_base.exe cmd2 --verb
  verbose = true

  $ ./main_base.exe cmd3 --help
  Hello cmd3
  
    main_base.exe cmd3 
  
  === flags ===
  
    [--bool MYBOOL], -b        . Specify a value
    [--int Specify], -i        . an int
    [--verbose], -v            . be more verbose
    [-help], -?                . print this help text and exit
  
  $ ./main_base.exe cmd3
  ((verbose false))
  ()
  42

  $ ./main_base.exe cmd3 -int 37 -bool true
  Error parsing command line:
  
    unknown flag -int
  
  For usage information, run
  
    main_base.exe cmd3 -help
  
  [1]

  $ ./main_base.exe cmd3 --int 37 --bool true
  ((verbose false))
  (true)
  37

  $ ./main_base.exe cmd3 --int=14
  Error parsing command line:
  
    unknown flag --int=14
  
  For usage information, run
  
    main_base.exe cmd3 -help
  
  [1]

  $ ./main_base.exe cmd3 -vi 14
  Error parsing command line:
  
    unknown flag -vi
  
  For usage information, run
  
    main_base.exe cmd3 -help
  
  [1]

  $ ./main_base.exe cmd4 --help
  Hello let%bind command
  
    main_base.exe cmd4 
  
  === flags ===
  
    -n a                       . float to print
    [-help], -?                . print this help text and exit
  

  $ ./main_base.exe cmd4
  Error parsing command line:
  
    missing required flag: -n
  
  For usage information, run
  
    main_base.exe cmd4 -help
  
  [1]

  $ ./main_base.exe cmd4 -n 3
  3.

  $ ./main_base.exe cmd4 -n=3.14
  Error parsing command line:
  
    unknown flag -n=3.14
  
  For usage information, run
  
    main_base.exe cmd4 -help
  
  [1]

  $ ./main_base.exe cmd4 -n 3.14
  3.14

  $ ./main_base.exe cmd5 --help
  Hello positional
  
    main_base.exe cmd5 A B [C]
  
  === flags ===
  
    [-help], -?                . print this help text and exit
  

  $ ./main_base.exe cmd5 1.2 3.4
  ((a 1.2) (b 3.4) (c 3.14))

  $ ./main_base.exe cmd5 1.2 3.4 5.6
  ((a 1.2) (b 3.4) (c 5.6))
