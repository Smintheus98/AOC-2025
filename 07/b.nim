import std / [strutils, sequtils]
import parsecli, utils

type
  Manifold = object
    level: Natural
    field: seq[string]
  Position = tuple
    r, c: int
  Memory = seq[seq[int]]

proc `[]`(m: Manifold; i: Natural): string = m.field[i]
proc `[]`(m: var Manifold; i: Natural): var string = m.field[i]

proc readManifold(file: string): Manifold =
  for line in file.lines:
    result.field.add line
  result.level = 0

proc initMemory(m: Manifold): Memory =
  newSeqWith(m.field.len, newSeqWith(m.field[0].len, 0))

proc `[]`(mem: Memory; p: Position): int = mem[p.r][p.c]
proc `[]`(mem: var Memory; p: Position): var int = mem[p.r][p.c]

proc dive(m: var Manifold; pos: Position; mem: var Memory): int =
  # Recursive tree descend with memoization to limit computational cost
  if pos.r.succ >= m.field.len: # leaf
    mem[pos] = 1
  elif mem[pos] == 0:
    if m[pos.r.succ][pos.c] == '^': # split
      mem[pos] =  m.dive((pos.r.succ, pos.c.pred), mem)
      mem[pos] += m.dive((pos.r.succ, pos.c.succ), mem)
    else:                           # straight
      mem[pos] = m.dive((pos.r.succ, pos.c), mem)
  return mem[pos]


proc iterate(m: Manifold): int =
  var
    m = m
    mem = initMemory(m)
  let start = (0, m.field[0].find('S'))
  return m.dive(start, mem)

proc main =
  let infile = getInputFile()
  let m = infile.readManifold

  echo m.iterate

when isMainModule:
  main()

