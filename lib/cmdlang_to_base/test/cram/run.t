A simple migration plan from [core.command] to [climate].

Imagine we started from an original core command, defined as such:

  $ ./main_base.exe original -help
  A group of commands.
  
    main_base.exe original SUBCOMMAND
  
  === subcommands ===
  
    basic                      . A group of basic commands.
    or-error                   . A group of or-error commands.
    help                       . explain a given subcommand (perhaps recursively)
  

  $ ./main_base.exe original basic return

  $ ./main_base.exe original basic print -help
  A basic print command.
  
    main_base.exe original basic print 
  
  === flags ===
  
    -arg ARG                   . My long arg.
    [-help], -?                . print this help text and exit
  

  $ ./main_base.exe original basic print -arg Hello
  Hello

  $ ./main_base.exe original or-error return

  $ ./main_base.exe original or-error print -help
  An or-error print command.
  
    main_base.exe original or-error print 
  
  === flags ===
  
    [-arg ARG]                 . My long arg.
    [-help], -?                . print this help text and exit
  
  $ ./main_base.exe original or-error print -arg Hello
  Hello

  $ ./main_base.exe original or-error print
  This command fails during execution when the argument is missing.
  [1]

The point of the migration plan is to avoid a single roll where all the commands
are migrated at once, creating braking changes. For example:

  $ ./main_climate.exe basic print -arg Hello
  Unknown argument name: -a
  [124]

OK, so as a first step, we will have to go over all CLI invocations and make
sure that all the command names and arguments are fully provided. For example,
the following partial invocation is supported by core.command:

  $ ./main_base.exe original bas pr -ar Hello
  Hello

But will have no equivalent with climate, so we start by fixing them all.

  $ ./main_base.exe original basic print -arg Hello
  Hello

Next, we can start migrating commands one by one, at which ever pace we prefer.
We use a configuration for the translation that allows a transition phase during
which arguments with single dashes are still supported.

  $ ./main_base.exe migration-step1 basic print -arg Hello
  Hello

Whenever that code is rolled, we can patch invocations to use double dashes.

  $ ./main_base.exe migration-step1 basic print --arg Hello
  Hello

If this is too confusing, one may wait for the full migration to change all
flags at once. For example, the following command will fail:

  $ ./main_base.exe migration-step1 or-error print --arg Hello
  Error parsing command line:
  
    unknown flag --arg
  
  For usage information, run
  
    main_base.exe migration-step1 or-error print -help
  
  [1]

OK let's say we've finished migrating all the commands:

  $ ./main_base.exe migration-step2 basic print --arg Hello
  Hello

  $ ./main_base.exe migration-step2 or-error print --arg Hello
  Hello

  $ ./main_base.exe migration-step2 or-error print
  This command fails during execution when the argument is missing.
  [1]

At this point, we are still using the core.command library, but we are ready to
switch to climate, with no breaking changes.

  $ ./main_climate.exe basic return

  $ ./main_climate.exe basic print --arg Hello
  Hello

  $ ./main_climate.exe or-error return

  $ ./main_climate.exe or-error print --arg Hello
  Hello

  $ ./main_climate.exe or-error print
  This command fails during execution when the argument is missing.
  [1]

If you'd like, it is possible to add an additional step where we keep running
core.command, but disallow single dashes for flags.

  $ ./main_base.exe migration-step3 basic print -arg Hello
  Error parsing command line:
  
    unknown flag -arg
  
  For usage information, run
  
    main_base.exe migration-step3 basic print -help
  
  [1]

  $ ./main_base.exe migration-step3 or-error print -arg Hello
  Error parsing command line:
  
    unknown flag -arg
  
  For usage information, run
  
    main_base.exe migration-step3 or-error print -help
  
  [1]

Unfortunately, there is no way to disable the partial specification of commands
with core.command so this part has to be carefully achieved.

  $ ./main_base.exe migration-step3 bas pr --arg Hello
  Hello

However, the partial specification of flags can be disabled to prepare for the
more strict invocations required by climate:

  $ ./main_base.exe migration-step3 basic print --ar Hello
  Error parsing command line:
  
    unknown flag --ar
  
  For usage information, run
  
    main_base.exe migration-step3 basic print -help
  
  [1]

This additional step should permit isolating issues related to stale invocations
from issues arising from the migration to climate.

  $ ./main_base.exe migration-step3 basic print --arg Hello
  Hello

  $ ./main_base.exe migration-step3 or-error print --arg Hello
  Hello

  $ ./main_base.exe migration-step3 or-error print
  This command fails during execution when the argument is missing.
  [1]
