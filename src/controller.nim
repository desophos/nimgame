import future, sequtils
import sdl2
import common_types, events, global

type
  Controller* = ref object of RootObj
    directionQueue*: seq[Direction]
  InputController* = ref object of Controller
  AIController* = ref object of Controller
  NoneController* = ref object of Controller

method chooseDirection*(controller: Controller): seq[Direction] {.base.} =
  quit repr(controller of InputController)

method chooseDirection*(controller: InputController): seq[Direction] =
  result = controller.directionQueue
  controller.directionQueue = @[Direction.idle]

method chooseDirection*(controller: AIController): seq[Direction] =
  return @[Direction.down]

method chooseDirection*(controller: NoneController): seq[Direction] =
  return @[Direction.idle]
