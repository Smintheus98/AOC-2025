import std / [strutils, sequtils, sugar]

type
  Direction = enum
    Left = "L", Right = "R"
  Rotation = tuple[dir: Direction, val: Natural]
  Rotations = seq[Rotation]

proc toDirection(c: char): Direction =
  c.`$`.parseEnum[:Direction]

proc readRotations(file: string): Rotations =
  for line in file.lines:
    let dir = line[0].toDirection
    let val = line[1..^1].parseInt.Natural
    result.add (dir, val)

proc rotate(pos: Natural; rot: Rotation; numbers = range[0..99]): Natural =
  let
    modulus = (numbers.high - numbers.low + 1)
    offset = numbers.low
    op = case rot.dir:
      of Left:  (a,b: int) => a - b
      of Right: (a,b: int) => a + b
  (op(pos, rot.val) + modulus * (rot.val div modulus + 1)) mod modulus + offset

proc countZeros(rots: Rotations): Natural =
  var pointing: Natural = 50
  for rot in rots:
    pointing = pointing.rotate(rot)
    if pointing == 0:
      result.inc

proc main() =
  let rots =
    #"example".readRotations
    "input".readRotations

  echo rots.countZeros

when isMainModule:
  main()
