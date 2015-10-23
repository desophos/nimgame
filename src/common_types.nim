import math

type
  Position* = object
    x*, y*: int
  Size* = object
    w*, h*: int
  View* = object
    pos*: Position
    size*: Size
  Direction* = enum
    left, up, down, right

proc `+`*(p1: Position, p2: Position): Position =
  return Position(x: p1.x + p2.x, y: p1.y + p2.y)

proc `-`*(p1: Position, p2: Position): Position =
  return Position(x: p1.x - p2.x, y: p1.y - p2.y)

proc `*`*(pos: Position, mult: float): Position =
  return Position(x: int(float(pos.x) * mult), y: int(float(pos.y) * mult))

proc distanceFrom*(p1: Position, p2: Position): float =
  return math.sqrt(float((p2.x - p1.x)^2 + (p2.y - p1.y)^2))

proc view*(x, y, w, h: int): View =
  return View(pos: Position(x: x, y: y), size: Size(w: w, h: h))

proc view*(pos: Position, w, h: int): View =
  return View(pos: pos, size: Size(w: w, h: h))

proc view*(x, y: int, size: Size): View =
  return View(pos: Position(x: x, y: y), size: size)

proc view*(pos: Position, size: Size): View =
  return View(pos: pos, size: size)

proc center*(view: View): Position =
  Position(
    x: view.pos.x + int(view.size.w / 2),
    y: view.pos.y + int(view.size.h / 2)
  )

proc centerOn*(view: var View, point: Position) =
  echo view.center, view.center-point
  view.pos = view.center - point

proc contains*(view: View, point: Position): bool =
  return point.x > view.pos.x and
         point.y > view.pos.y and
         point.x < (view.pos.x + view.size.w) and
         point.y < (view.pos.y + view.size.h)

proc contains*(v1: View, v2: View): bool =
  # upper left corner and lower right corner
  return v1.contains(
          v2.pos
        ) and
        v1.contains(
          Position(
            x: v2.pos.x + v2.size.w,
            y: v2.pos.y + v2.size.h
          )
        )

proc intersects*(v1: View, v2: View): bool =
  # any corner
  return v1.contains(
          v2.pos
        ) or
        v1.contains(
          Position(
            x: v2.pos.x + v2.size.w,
            y: v2.pos.y + v2.size.h
          )
        ) or
        v1.contains(
          Position(
            x: v2.pos.x + v2.size.w,
            y: v2.pos.y
          )
        ) or
        v1.contains(
          Position(
            x: v2.pos.x,
            y: v2.pos.y + v2.size.h
          )
        )

proc smaller*(view: View, distance: int): View =
  return view(
    view.pos.x + distance,
    view.pos.y + distance,
    view.size.w - distance*2,
    view.size.h - distance*2
  )
