structure Race where
  maxTime: Nat
  recordDistance: Nat
deriving Repr

def Race.waysToWin (r: Race) : Id Nat := do
  let mut total : Nat := 0
  let range := [ 1: r.maxTime ]
  for buttonTime in range do
    let distance := (r.maxTime - buttonTime) * buttonTime
    if distance > r.recordDistance then
      total := total + 1
  total

def readFileContents (filename : String) : IO String := do
  let h ← IO.FS.Handle.mk filename IO.FS.Mode.read
  h.readToEnd

def parseNums (line : String) : List Nat :=
  line
  |> (·.replace " " "") |> ([ · ])
  |> List.map String.trim
  |> List.filter (not ∘ String.isEmpty)
  |> List.map String.toNat!

def parseTimes (line : String) : List Nat :=
  line
  |> (·.replace  "Time:" "")
  |> parseNums

def parseDistances (line : String) : List Nat :=
  line
  |> (·.replace "Distance:" "")
  |> parseNums

def app2 (f: α →  β → γ)
  | (a, b) => f a b

def parseInput (input : String) : List Race :=
  let lines := input.splitOn "\n"
  let times := lines.head! |> parseTimes
  let distances := lines.get! 1 |> parseDistances
  let timesAndDistances := times.zip distances
  timesAndDistances |> List.map (app2 Race.mk)

def main (args : List String) : IO Unit :=
  match args with
  | [] => throw $ IO.userError "Expected filename"
  | (filename :: _) => do
    let contents ← readFileContents filename
    let timesAndDistances := parseInput contents
    let waysToWin := List.map Race.waysToWin timesAndDistances
    let prod := waysToWin |> List.filter (· > 0) |> List.foldl Nat.mul 1
    IO.println prod
