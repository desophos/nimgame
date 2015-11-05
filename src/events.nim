import future, tables
import sdl2
import common_types, global

type EventHandler* = ref object of RootObj
  pendingEvents: seq[Event]

proc newEventHandler*(): EventHandler =
  return EventHandler(pendingEvents: @[])

proc addEvent*(handler: EventHandler, event: Event) =
  handler.pendingEvents.insert(event)

proc peekEvent*(handler: EventHandler): Event =
  result = try: handler.pendingEvents[handler.pendingEvents.high]
           except IndexError: noneEvent

proc getEvent*(handler: EventHandler): Event =
  result = try: handler.pendingEvents.pop
           except IndexError: noneEvent

proc hasEvents*(handler: EventHandler): bool =
  return handler.pendingEvents.len > 0

proc isValidDirectionKey*(evt: Event): bool {.procvar.} =
  var evt = evt
  return directionMap.hasKey(evt.key.keysym.sym)

proc eventToDirection*(evt: Event): Direction {.procvar.} =
  # key is an accessor that casts an event to KeyboardEventPtr
  # so we can access the fields on KeyboardEventObj
  var evt = evt
  return directionMap[evt.key.keysym.sym]

iterator takeEventsWithKind*(eventQueue: EventHandler, eventKind: EventType): Event =
  while eventQueue.peekEvent().kind == eventKind:
    yield eventQueue.getEvent()

iterator takeEventsWhile*(eventQueue: EventHandler, pred: Event -> bool): Event =
  while pred(eventQueue.peekEvent()):
    yield eventQueue.getEvent()

iterator takeEventsWithKindWhile*(eventQueue: EventHandler, eventKind: EventType, pred: Event -> bool): Event =
  while eventQueue.peekEvent().kind == eventKind and
        pred(eventQueue.peekEvent()):
    yield eventQueue.getEvent()
