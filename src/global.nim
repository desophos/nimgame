import tables
import sdl2
import common_types

const
  noneEvent* = Event(kind: UserEvent)
  cameraSize* = Size(w: 320, h: 240)
  tileMap* = [
    [0, 1, 0, 1, 0, 1, 0],
    [1, 2, 1, 2, 1, 2, 1],
    [2, 3, 2, 3, 2, 3, 2],
    [3, 0, 3, 0, 3, 0, 3],
    [0, 1, 0, 1, 0, 1, 0],
    [1, 2, 1, 2, 1, 2, 1],
    [2, 3, 2, 3, 2, 3, 2],
    [3, 0, 3, 0, 3, 0, 3]
  ]
  tileSize* = 100
  directionMap* = toTable[cint, Direction]([
    (K_LEFT, Direction.left),
    (K_UP, Direction.up),
    (K_DOWN, Direction.down),
    (K_RIGHT, Direction.right)
  ])
