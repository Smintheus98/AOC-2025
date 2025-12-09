import std / [strutils, sequtils, math, algorithm, strformat]
import parsecli, utils

type Position = tuple
  r, c: int

proc min(p: Position): int =
  if p.r <= p.c:  p.r
  else:           p.c
proc max(p: Position): int =
  if p.r >= p.c:  p.r
  else:           p.c

type JunctionBox = tuple
  x, y, z: Natural

proc parseJunctionBox(s: string): JunctionBox =
  let parts = s.split(',').mapIt(it.parseInt)
  result.x = parts[0]
  result.y = parts[1]
  result.z = parts[2]

proc dist(a, b: JunctionBox): float =
  let
    dxs = (a.x - b.x) * (a.x - b.x)
    dys = (a.y - b.y) * (a.y - b.y)
    dzs = (a.z - b.z) * (a.z - b.z)
  return sqrt((dxs + dys + dzs).float)


type
  Circuit = seq[JunctionBox]
  Circuits = seq[Circuit]

proc readCircuits(file: string): Circuits =
  for line in file.lines:
    result.add @[line.parseJunctionBox]

proc dist(a, b: Circuit): float =
  result = Inf
  for abox in a:
    for bbox in b:
      result = min(result, dist(abox, bbox))

proc mergeDelete(cs: var Circuits; keep, del: int) =
  cs[keep].add cs[del]
  cs.delete(del)



type SymmMat[T] = object
  # symmetric matrix stored as upper triangle matrix with diagonal and intuitive indexing
  n: int
  data: seq[seq[T]]

proc initSymmMat[T](n: int): SymmMat[T] =
  result.n = n
  for r in 0..<n:
    result.data.add newSeqWith(n - r, T.default)

proc `[]`[T](sm: SymmMat[T]; pos: Position): T = sm.data[pos.min][pos.max - pos.min]
proc `[]`[T](sm: var SymmMat[T]; pos: Position): var T = sm.data[pos.min][pos.max - pos.min]
proc `[]=`[T](sm: var SymmMat[T]; pos: Position; val: T) = sm.data[pos.min][pos.max - pos.min] = val
proc `[]`[T](sm: SymmMat[T]; r, c: int): T = sm[(r,c)]
proc `[]`[T](sm: var SymmMat[T]; r, c: int): var T = sm[(r,c)]
proc `[]=`[T](sm: var SymmMat[T]; r, c: int; val: T) = sm[(r,c)] = val

proc delete[T](sm: var SymmMat[T]; i: int): seq[T] =
  result = newSeqOfCap[T](sm.n.pred)
  for r in 0..<i: # could be done more intuitive (see `[]`) but this one is more efficient
    result.add sm[r,i]
    sm.data[r].delete(i - r)
  for c in i.succ..<sm.n: # see above
    result.add sm[i,c]
  sm.data.delete(i)
  sm.n.dec


type
  DistTable = object
    circuits: Circuits
    dists: SymmMat[float]

proc makeDistTable(cs: Circuits): DistTable =
  result.circuits = cs
  let n = cs.len
  result.dists = initSymmMat[float](n)
  for i in 0..<n:
    for j in i..<n:
      if i == j:
        result.dists[i,j] = Inf # 0.0
      result.dists[i,j] = dist(cs[i], cs[j])

proc minWhere(dt: DistTable): Position =
  let n = dt.circuits.len
  var minval = Inf
  for r in 0..<n:
    for c in r.succ..<n:
      let val = dt.dists[r, c]
      if val < minval:
        minval = val
        result = (r,c)

proc updateDists(dt: var DistTable; pos: Position) =
  # Circuit B at pos.c is merged into Circuit A at pos.r and removed afterwards
  dt.circuits.mergeDelete(pos.r, pos.c)
  # get and delete distances of Circuit B which is about to be removed
  var rmcirc_vals = dt.dists.delete(pos.c)
  #echo fmt"{rmcirc_vals.len=}"
  # update distances of A depending on distances of B
  for i in 0..<rmcirc_vals.len:
    if i == pos.r: continue
    dt.dists[pos.r, i] = min(dt.dists[pos.r, i], rmcirc_vals[i])

proc connectCircuits(dt: var DistTable; pos: Position) =
  dt.updateDists(pos)

proc connect(cs: Circuits; n: Natural): Circuits =
  var dt = cs.makeDistTable
  for i in 1..<n:
    let pos = dt.minWhere
    dt.connectCircuits(pos)
  dt.circuits

proc prodbig3(cs: Circuits): int =
  let scs = cs.mapIt(it.len).sorted(SortOrder.Descending)
  scs[0..<min(scs.len, 3)].foldl(a * b, 1)

proc main =
  let infile = getInputFile()
  let N = if infile == "example": 10 else: 500
  let cs = infile.readCircuits

  let cons = cs.connect(N)

  echo cons.prodbig3


when isMainModule:
  main()

