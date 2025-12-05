

type
  Range*[T] = Slice[T]
  RangeSet*[T: SomeInteger] = object
    ranges: seq[Range[T]]

proc del(rs: var RangeSet; idx: Natural) =
  rs.ranges.del(idx)

proc compress*[T](rs: var RangeSet[T]) =
  for i, a in rs.ranges.mpairs:
    let idx_a = i
    for j, b in rs.ranges[i.succ..^1]:
      let idx_b = i + j + 1
      # a and b not connected           -(-)-[-]- -[-]-(-)-  []: old, (): new
      if b.b < a.a or b.a > a.b:
        continue
      # b entirely covered by a         -[-(-)-]-
      if b.a >= a.a and b.b <= a.b:
        rs.del(idx_b)
        rs.compress
        return
      # a entirely covered by b         -(-[-]-)-
      if b.a <= a.a and b.b >= a.b:
        rs.del(idx_a)
        rs.compress
        return
      # b around lower bound of a       -(-[-)-]-
      if b.a < a.a: # and x.b >= idr.a and x.b <= idr.b:
        a.a = b.a
        rs.del(idx_b)
        rs.compress
        return
      # b around upper bound of a        -[-(-]-)-
      if b.b > a.b: # and x.a <= idr.b and x.a >= idr.a:
        a.b = b.b
        rs.del(idx_b)
        rs.compress
        return


proc incl*[T](rs: var RangeSet[T]; x: Range[T]; compress = true): bool {.discardable.} =
  rs.ranges.add x
  rs.compress

proc card*(rs: RangeSet): int =
  var rs = rs
  rs.compress
  for r in rs.ranges:
    result.inc r.len

