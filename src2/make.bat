
set FLAGS=-Wno-writable-strings -Wno-format -Wno-extern-initializer
set FLAGS=-Wno-writable-strings -Wno-format
set ALLSRC=main.c externs.c

\cheerp\bin\clang++ -target cheerp-wasm %ALLSRC% %FLAGS% -o key.js -O3 > make.out 2>&1

vi make.out
