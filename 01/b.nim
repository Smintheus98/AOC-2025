import std / [strutils]

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

proc rotateCountingZeros(rots: Rotations; numbers = range[0..99]): Natural =
  let modulus = (numbers.high - numbers.low + 1)
  var pos: Natural = 50
  for rot in rots:
    result.inc rot.val div modulus
    let valrmd = rot.val mod modulus

    var nextPos: Natural
    case rot.dir:
      of Left:
        nextPos = pos + modulus - valrmd
        result.inc (pos != 0 and nextPos <= modulus).int
      of Right:
        nextPos = pos + valrmd
        result.inc (pos != 0 and nextPos >= modulus).int
    pos = nextPos mod modulus

proc main() =
  let rots =
    #"example".readRotations
    "input".readRotations

  echo rots.rotateCountingZeros

when isMainModule:
  main()
