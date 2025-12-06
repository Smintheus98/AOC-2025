import std / [strutils, sequtils, strformat]
import parsecli, utils

type
  Operator = enum
    Plus = "+", Multiply = "*"
  Problem = object
    numbers: seq[int]
    operator: Operator
  Homework = seq[Problem]

proc findSeperators(data: seq[string]): seq[int] =
  let
    nrow = data.len
    ncol = data.mapIt(it.len).max
  for c in 0..<ncol:
    if data[0][c] == ' ':
      var sep = true
      for r in 1..<nrow:
        if data[r][c] != ' ':
          sep = false
          break
      if sep:
        result.add c

proc parseHomework(data: seq[string]): Homework =
  let
    nrow = data.len
    ncol = data.mapIt(it.len).max
    seps = -1 & data.findSeperators & ncol
  
  for (lowsep, uppsep) in zip(seps[0..^2], seps[1..^1]):
    var problem: Problem
    for c in lowsep.succ..<uppsep:
      var strnum = ""
      for r in 0..<nrow.pred:
        if data[r][c] != ' ':
          strnum &= data[r][c]
      problem.numbers.add strnum.parseInt
    problem.operator = data[^1][lowsep.succ..<min(uppsep, data[^1].len)].strip.parseEnum[:Operator]
    result.add problem

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

