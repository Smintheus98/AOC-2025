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
  let s = $id
  if s.len.mod2 == 1:
    return false
  return s[0..<(s.len.div2)] == s[s.len.div2..^1]

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
