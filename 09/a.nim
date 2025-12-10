import std / [strutils, sequtils]
import parsecli, utils

type 
  Coord = tuple
    x, y: Natural
  RedTile = Coord
  RedTiles = seq[RedTile]
  Rectangle = object
    a, b: RedTile

proc readRedTiles(file: string): RedTiles =
  proc parseCoord(l: string): Coord =
    let coord = l.split(',').map(parseInt)
    (coord[0], coord[1])
  for l in file.lines:
    result.add l.parseCoord

proc initRectangle(a, b: RedTile): Rectangle =
  Rectangle(a: a, b: b)

proc area(r: Rectangle): int =
  ((r.a.x - r.b.x).abs + 1) * ((r.a.y - r.b.y).abs + 1)

proc biggestRectangleArea(rts: RedTiles): int =
  for i in 0..<rts.len:
    let a = rts[i]
    for j in i.succ..<rts.len:
      let
        b = rts[j]
        area = initRectangle(a, b).area
      if area > result:
        result = area


proc main =
  let infile = getInputFile()
  let rts = infile.readRedTiles
  echo rts.biggestRectangleArea

when isMainModule:
  main()

