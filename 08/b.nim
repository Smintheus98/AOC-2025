# This is definitely not the nicest or most performant solution!
# By now I'm just glad, it works and I'm done with this exercise!
import std / [strutils, sequtils, math]
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

proc add(circuits: var Circuits; pos: Position; compress = true) =
  circuits.add @[pos.r, pos.c]
  if compress:
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

proc lastConnectionForOneCircuit(jbs: JunctionBoxList; dt: DistTable): tuple[a, b: JunctionBox] =
  var
    circuits = (0..<jbs.len).toSeq.mapIt(@[it].Circuit).Circuits
    dt = dt
    pos: Position
  while circuits.len > 1:
    pos = dt.findMin
    circuits.add pos
    dt[pos.r][pos.c] = Inf
  return (jbs[pos.r], jbs[pos.c])

proc prodLastXCoords(jbs: JunctionBoxList): int =
  let dt = jbs.makeDistTable
  let (a, b) = jbs.lastConnectionForOneCircuit(dt)
  a.x * b.x

proc main =
  let infile = getInputFile()
  let jbs = infile.readJunctionBoxList

  echo jbs.prodLastXCoords


when isMainModule:
  main()

