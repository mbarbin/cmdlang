Exercising the error handling from the command line.

  $ cat > file << EOF
  > Hello World
  > EOF

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 0 --length 5 \
  > --message-kind=error
  File "file", line 1, characters 0-5:
  1 | Hello World
      ^^^^^
  Error: error message
  [123]

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind=warning
  File "file", line 1, characters 6-11:
  1 | Hello World
            ^^^^^
  Warning: warning message

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind=warning \
  > --warn-error
  File "file", line 1, characters 6-11:
  1 | Hello World
            ^^^^^
  Warning: warning message
  [123]

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind=info

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind=info \
  > --verbose
  File "file", line 1, characters 6-11:
  1 | Hello World
            ^^^^^
  Info: info message

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind=debug \
  > --verbose

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind=debug \
  > --verbosity=debug
  File "file", line 1, characters 6-11:
  1 | Hello World
            ^^^^^
  Debug: debug message

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 0 --length 5 \
  > --raise 2>&1 | head -n 1
  Internal Error: Failure("Raising an exception!")

Logs and Fmt options

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 0 --length 5 \
  > --message-kind=error \
  > --color=always
  File "file", line 1, characters 0-5:
  1 | Hello World
      ^^^^^
  Error: error message
  [123]

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 0 --length 5 \
  > --message-kind=error \
  > --color=never
  File "file", line 1, characters 0-5:
  1 | Hello World
      ^^^^^
  Error: error message
  [123]
