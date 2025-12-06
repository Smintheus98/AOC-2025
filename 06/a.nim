import std / [strutils, sequtils]
import parsecli, utils

type
  Operator = enum
    Plus = "+", Multiply = "*"
  Problem = object
    numbers: seq[int]
    operator: Operator
  Homework = seq[Problem]

proc parseHomework(data: seq[string]): Homework =
  var ncols: int
  for l in data[0..^2]:
    let nums = l.splitWhitespace.map(parseInt)
    if result.len == 0:
      ncols = nums.len
      result = newSeqWith(ncols, Problem.default)
    for i in 0..<ncols:
      result[i].numbers.add nums[i]
  let ops = data[^1].splitWhitespace.mapIt(it.parseEnum[:Operator])
  for i, o in ops:
    result[i].operator = o

proc solve(hw: Homework): seq[int] =
  for problem in hw:
    case problem.operator:
      of Plus:
        result.add problem.numbers.foldl(a + b, 0)
      of Multiply:
        result.add problem.numbers.foldl(a * b, 1)

proc grandTotal(hw: Homework): int =
  hw.solve.foldl(a + b, 0)

proc main =
  let indata = getInputFile().readFile.strip.splitLines
  let hw = indata.parseHomework

  echo hw.grandTotal

when isMainModule:
  main()

