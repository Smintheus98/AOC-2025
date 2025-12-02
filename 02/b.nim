import std / [strutils, sequtils]
import parsecli, utils

type
  ID = int
  IDRange = Slice[ID]
  IDRanges = seq[IDRange]

proc parseID(s: string): ID =
  s.parseInt.ID

proc parseIDRange(s: string): IDRange =
  let parts = s.split('-').mapIt(it.parseID)
  return parts[0]..parts[1]

proc parseIDRanges(s: string): IDRanges =
  for rng in s.split(','):
    result.add rng.parseIDRange

proc isRepetitiveID(id: ID): bool =
  result = false
  let s = $id
  for l in countdown(s.len.div2, 1):
    if s.len mod l != 0:
      continue
    let subs = s[0..<l]
    var match = true
    for k in 1..<(s.len div l):
      if s[l*k ..< l*k+l] != subs:
        match = false
        break
    if match:
      return true

proc isInvalid(id: ID): bool =
  id.isRepetitiveID

proc sumInvalidIDs(idrange: IDRange): int =
  for id in idrange:
    if id.isInvalid:
      result += id

proc sumInvalidIDs(idranges: IDRanges): int =
  for idrange in idranges:
    result += idrange.sumInvalidIDs


proc main =
  let input = getInputFile().readFile.strip()
  let idranges = input.parseIDRanges

  echo idranges.sumInvalidIDs

when isMainModule:
  main()
