# Show available tasks.
help:
  just -l

[private]
watch-scala:
  #!/usr/bin/env sh
  echo --exts scala,sc
[private]
init-scala DAY:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/scala
  cat <<-EOF > Main.scala
  package aoc.day{{DAY}}
  object Main extends App { println("Hello day{{DAY}}") }
  EOF
[private]
run-scala DAY INPUT:
  #!/usr/bin/env sh
  set -ex
  cd day{{DAY}}/scala
  scala-cli run Main.scala -- {{INPUT}}

[private]
watch-rust:
  #!/usr/bin/env sh
  echo --exts rs
[private]
init-rust DAY:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/rust
  cargo init --name "day{{DAY}}"
[private]
run-rust DAY INPUT:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/rust
  cargo run -- {{INPUT}}

[private]
init-zig DAY:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/zig
  zig init-exe
[private]
run-zig DAY INPUT:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/zig
  zig build run -- {{INPUT}}

[private]
init-flix DAY:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/flix
  flix init
[private]
run-flix DAY INPUT:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/flix
  flix run -- {{INPUT}}

[private]
watch-ocaml:
  #!/usr/bin/env sh
  echo --exts ml,mi
[private]
init-ocaml DAY:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}
  rm -rf ocaml
  mkdir tmp/
  ( dune init project day{{DAY}} tmp --root tmp --kind executable --no-config )
  mv tmp/day{{DAY}} ocaml
  rm -rf tmp
[private]
run-ocaml DAY INPUT:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/ocaml
  dune exec day{{DAY}} -- {{INPUT}}


[private]
watch-lean:
  #!/usr/bin/env sh
  echo --exts lean
[private]
init-lean DAY:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}
  rm -rf lean
  lake new day{{DAY}}  exe
  mv day{{DAY}} lean
  rm -rf lean/.git
[private]
run-lean DAY INPUT:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/lean
  lake exec day{{DAY}} {INPUT}}

# Fetch AdventOfCode README, input and examples for DAY.
get DAY:
  #!/usr/bin/env sh
  set -e
  mkdir -p day{{DAY}}
  cd day{{DAY}}
  aoc download --day {{DAY}} --overwrite --input-file input.txt --puzzle-file README.md
  awk -f ../parts-from-md.awk README.md
  touch part1.txt part2.txt

# Initialize a new LANG project for solving DAY.
init LANG DAY:
  #!/usr/bin/env sh
  set -e
  just -q get {{DAY}}
  mkdir -p day{{DAY}}/{{LANG}}
  cd day{{DAY}}/{{LANG}}
  curl -sSL https://www.toptal.com/developers/gitignore/api/{{LANG}} -o .gitignore
  just -q init-{{LANG}} {{DAY}}


# Run LANG project with the personalized input for DAY.
run LANG DAY:
  just run-{{LANG}} {{DAY}} $(pwd)/day{{DAY}}/input.txt
# Run LANG project with the first example input from README.
run-part1 LANG DAY:
  just run-{{LANG}} {{DAY}} $(pwd)/day{{DAY}}/part1.txt
# Run LANG project with the second example input from README.
run-part2 LANG DAY:
  just run-{{LANG}} {{DAY}} $(pwd)/day{{DAY}}/part2.txt


# Watch for changes and run LANG project with the personalized input for DAY.
watch LANG DAY:
  just watch-input {{LANG}} {{DAY}} $(pwd)/day{{DAY}}/input.txt
# Watch for changes and run LANG project with the first example input from README.
watch-part1 LANG DAY:
  just watch-input {{LANG}} {{DAY}} $(pwd)/day{{DAY}}/part1.txt
# Watch for changes and run LANG project with the second example input from README.
watch-part2 LANG DAY:
  just watch-input {{LANG}} {{DAY}} $(pwd)/day{{DAY}}/part2.txt

[private]
watch-input LANG DAY INPUT:
  #!/usr/bin/env sh
  set -ex
  cd day{{DAY}}/{{LANG}}
  watchexec --watch . --workdir . --watch {{INPUT}} $(just -q watch-{{LANG}}) --restart --clear reset just run-{{LANG}} {{DAY}} {{INPUT}}
  

