import std / [strutils, sequtils, tables]
import parsecli, utils

type 
  Coord = tuple
    r, c: Natural
  Tile = Coord
  Tiles = seq[Tile]
  Rectangle = object
    a, b: Tile
  Field = object
    redTiles: Tiles
    borderTiles: tuple[byRow, byCol: Table[Natural, seq[Natural]]]

proc readTiles(file: string): Tiles =
  proc parseCoord(l: string): Coord =
    let coord = l.split(',').map(parseInt)
    (coord[0], coord[1])
  for l in file.lines:
    result.add l.parseCoord

proc toField(tiles: Tiles): Field =
  result.redTiles = tiles
  for (redTile1, redTile2) in zip(tiles, tiles[1..^1] & tiles[0]):
    let
      rows = (lo: min(redTile1.r, redTile2.r), hi: max(redTile1.r, redTile2.r))
      cols = (lo: min(redTile1.c, redTile2.c), hi: max(redTile1.c, redTile2.c))
    if rows.lo == rows.hi:
      for c in cols.lo..cols.hi.pred:
        if not result.borderTiles.byRow.hasKey(rows.lo):
          result.borderTiles.byRow[rows.lo] = @[]
        result.borderTiles.byRow[rows.lo].add c
        if not result.borderTiles.byCol.hasKey(c):
          result.borderTiles.byCol[c] = @[]
        result.borderTiles.byCol[c].add rows.lo
    elif cols.lo == cols.hi:
      for r in rows.lo..rows.hi.pred:
        if not result.borderTiles.byRow.hasKey(r):
          result.borderTiles.byRow[r] = @[]
        result.borderTiles.byRow[r].add cols.lo
        if not result.borderTiles.byCol.hasKey(cols.lo):
          result.borderTiles.byCol[cols.lo] = @[]
        result.borderTiles.byCol[cols.lo].add r

proc readField(file: string): Field =
  file.readTiles.toField

proc initRectangle(a, b: Tile): Rectangle =
  Rectangle(a: a, b: b)

proc area(r: Rectangle): int =
  let (a, b) = (r.a, r.b)
  ((a.r - b.r).abs + 1) * ((a.c - b.c).abs + 1)

proc lo(r: Rectangle): Tile = (min(r.a.r, r.b.r), min(r.a.c, r.b.c))
proc hi(r: Rectangle): Tile = (max(r.a.r, r.b.r), max(r.a.c, r.b.c))

proc contains(f: Field; rect: Rectangle): bool =
  if rect.a.r == rect.b.r or rect.a.c == rect.b.c:
    return true
  let
    lo = rect.lo
    hi = rect.hi
  for r in [lo.r.succ, hi.r.pred]:
    if f.borderTiles.byRow.getOrDefault(r).countIt(it > lo.c and it < hi.c) > 0:
      return false
  for c in [lo.c.succ, hi.c.pred]:
    if f.borderTiles.byCol.getOrDefault(c).countIt(it > lo.r and it < hi.r) > 0:
      return false
  return true

proc biggestInnerRectangleArea(f: Field): int =
  for i, a in f.redTiles:
    for j in i.succ..<f.redTiles.len:
      let b = f.redTiles[j]
      let
        rect = initRectangle(a, b)
        area = rect.area
      if area > result and f.contains(rect):
        result = area


proc main =
  let infile = getInputFile()
  let f = infile.readField
  echo f.biggestInnerRectangleArea

when isMainModule:
  main()

