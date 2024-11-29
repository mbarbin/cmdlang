module Command = Cmdlang.Command

let%expect_test "flag" =
  let test =
    Arg_test.create
      (let%map_open.Command hello = Arg.flag [ "print-hello" ] ~doc:"print Hello" in
       (ignore (hello : bool) [@coverage off]))
  in
  Arg_test.eval_all test { prog = "test"; args = [ "--help" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    [33;1mUsage: [0m[32;1mtest [OPTIONS][0m

    [33;1mOptions:[0m
      [32;1m    --print-hello [0m print Hello
      [32;1m-h, --help [0m        Print help
    ("Evaluation Raised" (Climate.Usage))
    ----------------------------------------------------- Cmdliner
    TEST(1)                           Test Manual                          TEST(1)



    NNAAMMEE
           test

    SSYYNNOOPPSSIISS
           tteesstt [----pprriinntt--hheelllloo] [_O_P_T_I_O_N]…

    OOPPTTIIOONNSS
           ----pprriinntt--hheelllloo
               print Hello.

    CCOOMMMMOONN OOPPTTIIOONNSS
           ----hheellpp[=_F_M_T] (default=aauuttoo)
               Show this help in format _F_M_T. The value _F_M_T must be one of aauuttoo,
               ppaaggeerr, ggrrooffff or ppllaaiinn. With aauuttoo, the format is ppaaggeerr or ppllaaiinn
               whenever the TTEERRMM env var is dduummbb or undefined.

    EEXXIITT SSTTAATTUUSS
           tteesstt exits with:

           0   on success.

           123 on indiscriminate errors reported on standard error.

           124 on command line parsing errors.

           125 on unexpected internal errors (bugs).



    Test                                                                   TEST(1)
    ----------------------------------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"unknown flag --help\")"))
    ----------------------------------------------------- Stdlib_runner
    Usage: test [OPTIONS]

    eval-stdlib-runner

    Options:
      --print-hello  print Hello (optional)
      -help          Display this list of options
      --help         Display this list of options
    |}];
  ()
;;
