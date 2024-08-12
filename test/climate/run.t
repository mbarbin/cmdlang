
  $ ./main_climate.exe --help
  Usage: ./main_climate.exe [OPTIONS]
         ./main_climate.exe [SUBCOMMAND]
  
  Hello
  
  Options:
   --help, -h   Print help
  
  Subcommands:
   cmd1  Hello command
   cmd2  Hello let%bind command
   cmd3  Hello cmd3
   cmd4  Hello let%bind command
   cmd5  Hello positional

  $ ./main_climate.exe cmd1 --help
  Usage: ./main_climate.exe cmd1 [OPTIONS]
  
  Hello command
  
  Options:
   --help, -h   Print help
  $ ./main_climate.exe cmd1
  Hello Wold

  $ ./main_climate.exe cmd2 --help
  Usage: ./main_climate.exe cmd2 [OPTIONS]
  
  Hello let%bind command
  
  Options:
   --verbose, -v   be more verbose
   --help, -h   Print help

  $ ./main_climate.exe cmd2
  verbose = false

  $ ./main_climate.exe cmd2 -v
  verbose = true

  $ ./main_climate.exe cmd2 --verbose
  verbose = true

  $ ./main_climate.exe cmd2 -verbose
  Unknown argument name: -e
  [124]

  $ ./main_climate.exe cmd2 --verb
  Unknown argument name: --verb
  [124]

  $ ./main_climate.exe cmd3 --help
  Usage: ./main_climate.exe cmd3 [OPTIONS]
  
  Hello cmd3
  
  Options:
   --verbose, -v   be more verbose
   --bool, -b <MYBOOL>   Specify a value
   --int, -i <INT>   Specify an int
   --help, -h   Print help

  $ ./main_climate.exe cmd3
  ((verbose false))
  ()
  42

  $ ./main_climate.exe cmd3 --int=37 --bool=true
  ((verbose false))
  (true)
  37

  $ ./main_climate.exe cmd3 --int 14
  ((verbose false))
  ()
  14

  $ ./main_climate.exe cmd3 --in=37 --bo=true
  Unknown argument name: --in
  [124]

  $ ./main_climate.exe cmd3 --i=37 --b=true
  Single-character names must only be specified with a single dash. "--i" is not allowed as it has two dashes but only one character.
  [124]

  $ ./main_climate.exe cmd3 -vb true
  ((verbose true))
  (true)
  42

  $ ./main_climate.exe cmd3 -vb=true
  Failed to parse the argument to "-b": invalid value: "=true" (not an bool)
  [124]

  $ ./main_climate.exe cmd3 -vbtrue
  ((verbose true))
  (true)
  42

  $ ./main_climate.exe cmd4 --help
  Usage: ./main_climate.exe cmd4 [OPTIONS] -n<FLOAT>
  
  Hello let%bind command
  
  Options:
   -n <FLOAT>   a float to print
   --help, -h   Print help

  $ ./main_climate.exe cmd4
  Missing required named argument: -n
  [124]

  $ ./main_climate.exe cmd4 -n 3
  3.

  $ ./main_climate.exe cmd4 --n=3.14
  Single-character names must only be specified with a single dash. "--n" is not allowed as it has two dashes but only one character.
  [124]

  $ ./main_climate.exe cmd4 -n3.14
  3.14

  $ ./main_climate.exe cmd4 -n=3.14
  Failed to parse the argument to "-n": invalid value: "=3.14" (not an float)
  [124]

  $ ./main_climate.exe cmd4 -n 3.14
  3.14

  $ ./main_climate.exe cmd5 --help
  Usage: ./main_climate.exe cmd5 [OPTIONS] <A> <B>
  
  Hello positional
  
  Options:
   --help, -h   Print help

  $ ./main_climate.exe cmd5 1.2 3.4
  ((a 1.2) (b 3.4) (c 3.14))

  $ ./main_climate.exe cmd5 1.2 3.4 5.6
  ((a 1.2) (b 3.4) (c 5.6))
