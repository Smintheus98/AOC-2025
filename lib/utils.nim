
proc div2*[I: SomeInteger](i: I): I =
  i shr 1

proc mod2*[I: SomeInteger](i: I): I =
  i and 1
