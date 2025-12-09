import std / [strutils, sequtils, math, algorithm, strformat]
import parsecli, utils

type
  Position = tuple
    r, c: int
  JunctionBox = tuple
    x, y, z: Natural
  JunctionBoxList = seq[JunctionBox]
  Circuit = seq[int]
  Circuits = seq[Circuit]
  DistTable = seq[seq[float]]

proc parseJunctionBox(s: string): JunctionBox =
  let parts = s.split(',').mapIt(it.parseInt)
  result.x = parts[0]
  result.y = parts[1]
  result.z = parts[2]

proc readJunctionBoxList(file: string): JunctionBoxList =
  for line in file.lines:
    result.add line.parseJunctionBox

#proc dist(a, b: JunctionBox): float =
proc `|-|`(a, b: JunctionBox): float =
  let
    dxs = (a.x - b.x) * (a.x - b.x)
    dys = (a.y - b.y) * (a.y - b.y)
    dzs = (a.z - b.z) * (a.z - b.z)
  return sqrt((dxs + dys + dzs).float)

proc compress(circuits: var Circuits) =
  let n = circuits.len
  for i in 0..<n:
    for j in i.succ..<n:
      var overlap = false
      for jb in circuits[i]:
        if jb in circuits[j]:
          overlap = true
      if overlap:
        circuits[i] = (circuits[i] & circuits[j]).deduplicate
        circuits.del(j)
        circuits.compress
        return

proc add(circuits: var Circuits; pos: Position) =
  circuits.add @[pos.r, pos.c]
  circuits.compress

proc makeDistTable(jbs: JunctionBoxList): DistTable =
  let n = jbs.len
  result = newSeqWith(n, newSeqWith(n, Inf))
  for i, a in jbs:
    for j, b in jbs:
      if i >= j:
        result[i][j] = Inf
      result[i][j] = a |-| b

proc findMin(dt: DistTable): Position =
  let n = dt.len
  var minval = Inf
  for r in 0..<n:
    for c in r.succ..<n:
      let val = dt[r][c]
      if val < minval:
        minval = val
        result = (r,c)

proc buildCircuits(dt: DistTable; n: Natural): Circuits =
  var dt = dt
  for i in 0..<n:
    let pos = dt.findMin
    result.add pos
    dt[pos.r][pos.c] = Inf

proc prodbig3(cs: Circuits): int =
  let cs = cs.mapIt(it.len).sorted(SortOrder.Descending)
  cs[0..<min(cs.len, 3)].foldl(a * b, 1)


proc main =
  let infile = getInputFile()
  let N = if infile == "example": 10 else: 1000
  let jbs = infile.readJunctionBoxList
  let dt = jbs.makeDistTable

  let cs = dt.buildCircuits(N)

  echo cs.prodbig3


when isMainModule:
  main()

