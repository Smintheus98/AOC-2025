import std / [strutils, sequtils]
import parsecli, utils

type
  Button = seq[Natural]   # used to shift towards LightDiagram-scale
  Joltages = seq[Natural]
  Machine = object
    buttons: seq[Button]
    joltages: Joltages

### Parsing
proc parseButton(s: string): Button =
  s[1..^2].split(',').mapIt(it.parseInt.Natural)

proc parseJoltages(s: string): Joltages =
  s[1..^2].split(',').mapIt(it.parseInt.Natural)

proc parseMachine(line: string): Machine =
  let parts = line.splitWhitespace
  for part in parts[1..^2]:
    result.buttons.add part.parseButton
  result.joltages = parts[^1].parseJoltages

proc readMachines(file: string): seq[Machine] =
  for line in file.lines:
    result.add line.parseMachine

### Joltage
proc apply(joltages: Joltages; button: Button): Joltages =
  result = joltages
  for idx in button:
    result[idx].inc

proc anyBigger(js1, js2: Joltages): bool =
  for i in 0..<js1.len:
    if js1[i] > js2[i]:
      return true
  return false

### Machine
proc countRequiredButtons(machine: Machine; joltagesList: seq[tuple[b: int; j: Joltages]]; levelCounter = 1): int =
  var newJoltagesList: seq[tuple[b: int; j: Joltages]] = @[]
  for (bb, jolts) in joltagesList:
    for b, button in machine.buttons[bb..^1]:
      let newJolts = jolts.apply(button)
      if newJolts == machine.joltages:
        return levelCounter
      if not newJolts.anyBigger(machine.joltages):
        newJoltagesList.add (b+bb, newJolts)
  return machine.countRequiredButtons(newJoltagesList, levelCounter.succ)

proc countRequiredButtons(machine: Machine): int =
  machine.countRequiredButtons(@[(0, newSeqWith(machine.joltages.len, 0.Natural))])

proc totalButtonCount(machines: seq[Machine]): int =
  for i, machine in machines:
    echo i
    result += machine.countRequiredButtons

proc main =
  let infile = getInputFile()
  let machines = infile.readMachines

  echo machines.totalButtonCount

when isMainModule:
  main()

