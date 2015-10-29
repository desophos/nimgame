import future, sequtils
import sdl2
import common_types, events, global

type
  Controller* = ref object of RootObj
  InputController* = ref object of Controller
  AIController* = ref object of Controller
  NoneController* = ref object of Controller

method chooseDirection*(controller: Controller, eventQueue: EventHandler): seq[Direction] {.base.} =
  quit repr(controller of InputController)

method chooseDirection*(controller: InputController, eventQueue: EventHandler): seq[Direction] =
  # key is an accessor that casts an event to KeyboardEventPtr
  # so we can access the fields on KeyboardEventObj
  #for evt in eventQueue.takeEventsWithKindWhile(KeyDown, isValidDirectionKey):
  #  return toSeq(directionMap[evt.key.keysym.sym])
  let directions = map(
    toSeq(eventQueue.takeEventsWithKindWhile(KeyDown, isValidDirectionKey)),
    eventToDirection
  )
  if directions.len > 0:
    return directions
  return @[Direction.idle]

method chooseDirection*(controller: AIController, eventQueue: EventHandler): seq[Direction] =
  return @[Direction.down]

method chooseDirection*(controller: NoneController, eventQueue: EventHandler): seq[Direction] =
  return @[Direction.idle]
