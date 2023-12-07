[private]
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

get DAY:
  #!/usr/bin/env sh
  set -e
  mkdir -p day{{DAY}}
  cd day{{DAY}}
  aoc download --day {{DAY}} --overwrite --input-file input.txt --puzzle-file README.md
  awk -f ../parts-from-md.awk README.md
  touch part1.txt part2.txt

init LANG DAY:
  #!/usr/bin/env sh
  set -e
  just -q get {{DAY}}
  mkdir -p day{{DAY}}/{{LANG}}
  cd day{{DAY}}/{{LANG}}
  curl -sSL https://www.toptal.com/developers/gitignore/api/{{LANG}} -o .gitignore
  just -q init-{{LANG}} {{DAY}}


run LANG DAY:
  just run-{{LANG}} {{DAY}} $(pwd)/day{{DAY}}/input.txt
run-part1 LANG DAY:
  just run-{{LANG}} {{DAY}} $(pwd)/day{{DAY}}/part1.txt
run-part2 LANG DAY:
  just run-{{LANG}} {{DAY}} $(pwd)/day{{DAY}}/part2.txt


watch LANG DAY:
  just watch-input {{LANG}} {{DAY}} $(pwd)/day{{DAY}}/input.txt
watch-part1 LANG DAY:
  just watch-input {{LANG}} {{DAY}} $(pwd)/day{{DAY}}/part1.txt
watch-part2 LANG DAY:
  just watch-input {{LANG}} {{DAY}} $(pwd)/day{{DAY}}/part2.txt

[private]
watch-input LANG DAY INPUT:
  #!/usr/bin/env sh
  set -ex
  cd day{{DAY}}/{{LANG}}
  watchexec --watch . --workdir . --watch {{INPUT}} $(just -q watch-{{LANG}}) --restart just run-{{LANG}} {{DAY}} {{INPUT}}
  

