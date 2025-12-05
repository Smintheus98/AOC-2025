import std / [strutils, sequtils]
import parsecli, utils

type
  ID = int
  IDList = seq[ID]
  IDRange = Slice[ID]
  IDRanges = seq[IDRange]
  Database = object
    freshIDs: IDRanges
    availableIDs: IDList

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

proc isFresh(id: ID; freshIDs: IDRanges): bool =
  for freshIDRange in freshIDs:
    if id in freshIDRange:
      return true
  return false

proc countFreshAvailableIDs(db: Database): int =
  for id in db.availableIDs:
    if id.isFresh(db.freshIDs):
      result.inc

proc main =
  let infile = getInputFile()
  let db = infile.readDatabase

  echo db.countFreshAvailableIDs

when isMainModule:
  main()

