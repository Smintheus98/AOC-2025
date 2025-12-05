import std / [strutils, sequtils]
import parsecli, utils
import rangesets

type
  ID = int
  IDList = seq[ID]
  IDRange = Slice[ID]
  IDRanges = seq[IDRange]
  Database = object
    freshIDs: IDRanges
    availableIDs: IDList
  IDRangeSet = RangeSet[ID]

proc parseID(s: string): ID =
  s.parseInt.ID

proc parseIDRange(s: string): IDRange =
  let parts = s.split('-').mapIt(it.parseID)
  return parts[0]..parts[1]

proc parseIDRanges(ls: seq[string]): IDRanges =
  for l in ls:
    for rng in l.split(','):
      result.add rng.parseIDRange

proc parseIDList(ls: seq[string]): IDList =
  ls.map(parseID)

proc readDatabase(file: string): Database =
  let
    data = file.readFile.strip.splitLines
    splitidx = data.find("")
  result.freshIDs = data[0..<splitidx].parseIDRanges
  result.availableIDs = data[splitidx.succ..^1].parseIDList

proc countFreshIDs(db: Database): int =
  var collection: IDRangeSet
  for idrange in db.freshIDs:
    collection.incl idrange, false
  return collection.card


proc main =
  let infile = getInputFile()
  let db = infile.readDatabase

  echo db.countFreshIDs

when isMainModule:
  main()

