import std / [strutils, sequtils]
import parsecli, utils

type
  Joltage = range[1..9]
  Battery = object
    jolt: Joltage = 1
  BatteryBank = seq[Battery]
  BatteryCollection = seq[BatteryBank]

proc parseBatteryBank(line: string): BatteryBank =
  for c in line:
    result.add Battery(jolt: c.`$`.parseint.Joltage)

proc readBatteryCollection(file: string): BatteryCollection =
  for line in file.lines:
    result.add line.parseBatteryBank

proc buildNumber(a, b: Joltage): int =
  a.int * 10 + b.int

proc calcMaxJoltage(bank: BatteryBank): int =
  let
    jolts = bank.mapIt(it.jolt.int)
    (n1, l1) = jolts[0..^2].argmax
    n2 = jolts[l1.succ..^1].max
  return buildNumber(n1.Joltage, n2.Joltage)

proc sumMaxJoltages(coll: BatteryCollection): int =
  for bank in coll:
    result += bank.calcMaxJoltage

proc main =
  let infile = getInputFile()
  let batts = infile.readBatteryCollection

  echo batts.sumMaxJoltages

  discard

when isMainModule:
  main()
