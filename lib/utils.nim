
proc div2*[I: SomeInteger](i: I): I =
  i shr 1

proc mod2*[I: SomeInteger](i: I): I =
  i and 1

proc argmax*[I: SomeInteger](s: openArray[I]): tuple[value: I; location: int] =
  if s.len == 0:
    return (-1, -1)
  var
    maxVal: I = s[0]
    maxLoc: int = 0
  for i, v in s:
    if v > maxVal:
      maxVal = v
      maxLoc = i
  return (maxVal, maxLoc)
