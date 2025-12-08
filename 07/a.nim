import std / [strutils, sequtils]
import parsecli, utils

type
  Manifold = object
    level: Natural
    field: seq[string]
    splits: Natural

proc `[]`(m: Manifold; i: Natural): string = m.field[i]
proc `[]`(m: var Manifold; i: Natural): var string = m.field[i]

proc readManifold(file: string): Manifold =
  for line in file.lines:
    result.field.add line
  result.level = 0

proc next(m: var Manifold): bool =
  if m.level.succ >= m.field.len:
    return false
  for i, c in m[m.level]:
    case c:
      of '.':
        continue
      of 'S', '|':
        if m[m.level.succ][i] == '^':
          m.splits.inc
          m[m.level.succ][i.pred] = '|'
          m[m.level.succ][i.succ] = '|'
        else:
          m[m.level.succ][i] = '|'
      else:
        discard
  m.level.inc
  return true

proc iterate(m: Manifold): int =
  var m = m
  while m.next:
    discard
  return m.splits

proc main =
  let infile = getInputFile()
  let m = infile.readManifold

  echo m.iterate

when isMainModule:
  main()

