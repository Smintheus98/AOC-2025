import std / [strutils, sequtils]
import parsecli, utils

type
  LightDiagram = uint16 # used as bit field
  Button = seq[uint8]   # used to shift towards LightDiagram-scale
  Machine = object
    lights: LightDiagram
    buttons: seq[Button]

### Parsing
proc parseLightDiagram(s: string): LightDiagram =
  for i, c in s[1..^2]:
    if c == '#':
      result = result or (1'u16 shl i)

proc parseButton(s: string): Button =
  s[1..^2].split(',').mapIt(it.parseInt.uint8)

proc parseMachine(line: string): Machine =
  let parts = line.splitWhitespace
  result.lights = parts[0].parseLightDiagram
  for part in parts[1..^2]:
    result.buttons.add part.parseButton

proc readMachines(file: string): seq[Machine] =
  for line in file.lines:
    result.add line.parseMachine
###

### Light Diagram
proc apply(lights: LightDiagram; button: Button): LightDiagram =
  result = lights
  for idx in button:
    result = result xor (1'u16 shl idx)

### Machine
proc countRequiredButtons(machine: Machine; levelCounter = 1; lightsIn = @[0.LightDiagram]): int =
  var lightsOut: seq[LightDiagram]
  for light in lightsIn:
    for button in machine.buttons:
      let newLights = light.apply button
      lightsOut.add newLights
      if newLights == machine.lights:
        return levelCounter
  return machine.countRequiredButtons(levelCounter.succ, lightsOut)

proc totalButtonCount(machines: seq[Machine]): int =
  for machine in machines:
    result += machine.countRequiredButtons

proc main =
  let infile = getInputFile()
  let machines = infile.readMachines

  echo machines.totalButtonCount

when isMainModule:
  main()

