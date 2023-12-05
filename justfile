[private]
help:
  just -l

[private]
ext-scala:
  #!/usr/bin/env sh
  echo scala,sc
[private]
init-scala DAY:
  #!/usr/bin/env sh
  cd day{{DAY}}/scala
  cat <<-EOF > Main.scala
  package aoc.day{{DAY}}
  object Main extends App { println("Hello day{{DAY}}") }
  EOF
[private]
run-scala DAY INPUT:
  #!/usr/bin/env sh
  cd day{{DAY}}/scala
  scala-cli run . -- {{INPUT}}

[private]
ext-rust:
  #!/usr/bin/env sh
  echo rs
[private]
init-rust DAY:
  #!/usr/bin/env sh
  cd day{{DAY}}/rust
  cargo init --name "day{{DAY}}"
[private]
run-rust DAY INPUT:
  #!/usr/bin/env sh
  cd day{{DAY}}/rust
  cargo run -- {{INPUT}}

[private]
ext-zig:
  #!/usr/bin/env sh
  echo zig
[private]
init-zig DAY:
  #!/usr/bin/env sh
  cd day{{DAY}}/zig
  zig init-exe
[private]
run-zig DAY INPUT:
  #!/usr/bin/env sh
  cd day{{DAY}}/zig
  zig build run -- {{INPUT}}

[private]
ext-flix:
  #!/usr/bin/env sh
  echo flix
[private]
init-flix DAY:
  #!/usr/bin/env sh
  cd day{{DAY}}/flix
  flix init
[private]
run-flix DAY INPUT:
  #!/usr/bin/env sh
  cd day{{DAY}}/flix
  flix run -- {{INPUT}}

init LANG DAY:
  #!/usr/bin/env sh
  set -e
  mkdir -p day{{DAY}}/{{LANG}}
  cd day{{DAY}}
  aoc download --day {{DAY}} --overwrite --input-file input.txt --puzzle-file README.md
  awk -f ../parts-from-md.awk README.md
  touch part1.txt part2.txt
  cd {{LANG}}
  curl -sSL https://www.toptal.com/developers/gitignore/api/{{LANG}} -o .gitignore
  just -q init-{{LANG}} {{DAY}}


run LANG DAY:
  just -q run-{{LANG}} {{DAY}} $PWD/day{{DAY}}/input.txt
run-part1 LANG DAY:
  just -q run-{{LANG}} {{DAY}} $PWD/day{{DAY}}/part1.txt
run-part2 LANG DAY:
  just -q run-{{LANG}} {{DAY}} $PWD/day{{DAY}}/part2.txt


watch LANG DAY:
  just -q watch-input {{LANG}} {{DAY}} $PWD/day{{DAY}}/input.txt
watch-part1 LANG DAY:
  just -q watch-input {{LANG}} {{DAY}} $PWD/day{{DAY}}/part1.txt
watch-part2 LANG DAY:
  just -q watch-input {{LANG}} {{DAY}} $PWD/day{{DAY}}/part2.txt

[private]
watch-input LANG DAY INPUT:
  #!/usr/bin/env sh
  set -e
  cd day{{DAY}}/{{LANG}}
  watchexec --watch . --workdir . --watch {{INPUT}} --restart --clear reset just -q run-{{LANG}} {{DAY}} {{INPUT}}
  

