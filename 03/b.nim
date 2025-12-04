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

proc calcMaxJoltage(bank: BatteryBank): int =
  var jolts = bank.mapIt(it.jolt.int)
  var v, l: int
  for r in countdown(12, 1):
    (v, l) = jolts[0..^r].argmax
    jolts = jolts[l.succ..^1]
    result *= 10
    result += v

proc sumMaxJoltages(coll: BatteryCollection): int =
  for bank in coll:
    result += bank.calcMaxJoltage

proc main =
  let infile = getInputFile()
  let batts = infile.readBatteryCollection

  echo batts.sumMaxJoltages

when isMainModule:
  main()
