type
  Position* = object
    x*, y*: int
  Size* = object
    w*, h*: int
  View* = object
    pos*: Position
    size*: Size

proc view*(x, y, w, h: int): View =
  return View(pos: Position(x: x, y: y), size: Size(w: w, h: h))

proc view*(pos: Position, w, h: int): View =
  return View(pos: pos, size: Size(w: w, h: h))

proc view*(x, y: int, size: Size): View =
  return View(pos: Position(x: x, y: y), size: size)

proc view*(pos: Position, size: Size): View =
  return View(pos: pos, size: size)
