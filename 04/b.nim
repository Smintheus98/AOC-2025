import std / [strutils, sequtils]
import parsecli

type
  Place = enum
    PaperRoll = "@", Empty = "."
  Grid = seq[seq[Place]]
  Position = tuple[r, c: Natural]

proc parseGrid(s: seq[string]): Grid =
  for l in s:
    result.add l.mapIt(it.`$`.parseEnum[:Place])

proc countAdjacentPaperRolls(grid: Grid; pos: Position): int =
  for rr in -1..1:
    if pos.r + rr < 0 or pos.r + rr >= grid.len:
      continue
    for rc in -1..1:
      if pos.c + rc < 0 or pos.c + rc >= grid[0].len:
        continue
      if rc == 0 and rr == 0:
        continue
      if grid[pos.r + rr][pos.c + rc] == PaperRoll:
        result.inc

proc isPaperRollMovable(grid: Grid; pos: Position): bool =
  return grid.countAdjacentPaperRolls(pos) < 4

proc isPaperRoll(grid: Grid; pos: Position): bool =
  return grid[pos.r][pos.c] == PaperRoll

proc removeMovablePaperRolls(grid: var Grid): int =
  for r in 0..<grid.len:
    for c in 0..<grid[r].len:
      let pos: Position = (r, c)
      if grid.isPaperRoll(pos) and grid.isPaperRollMovable(pos):
        result.inc
        grid[r][c] = Empty

proc countMovablePaperRolls(grid: Grid): int =
  var grid = grid
  while true:
    let removed = grid.removeMovablePaperRolls
    if removed == 0:
      return
    result += removed

proc main =
  let input = getInputFile().readFile.strip.splitlines
  let grid = input.parseGrid

  echo grid.countMovablePaperrolls

when isMainModule:
  main()
