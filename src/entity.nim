from sdl2 import nil
import common_types
import spritesheet

type Entity* = ref object of RootObj
  sprite: SpriteSheet
  pos*: Position
  frameTimer: seq[int]
  currentFrameTime: int  # decrement by 1 on each render

proc entity*(
  ren: sdl2.RendererPtr,
  file: string,
  view: View
): Entity =
  let sprite = spriteSheet(ren, file, view.size)
  var frameTimer: seq[int] = @[]
  # completely temporary until i decide how to specify frame times
  for i in 0 .. sprite.numFrames:
    frameTimer.add(60)
  return Entity(
    sprite: sprite,
    pos: view.pos,
    frameTimer: frameTimer,
    currentFrameTime: frameTimer[0]
  )

proc entity*(ren: sdl2.RendererPtr, file: string, w, h: int): Entity =
  return entity(ren, file, view(0, 0, Size(w: w, h: h)))

proc `pos=`*(entity: var Entity, pos: Position) =
  entity.pos = pos

proc `pos=`*(entity: var Entity, x, y: int) =
  entity.pos = Position(x: x, y: y)

proc center*(entity: Entity): Position =
  let size = entity.sprite.getSize
  return Position(
    x: entity.pos.x + int(size.w / 2),
    y: entity.pos.y + int(size.h / 2)
  )

proc getView*(entity: Entity): View =
  return view(entity.pos, entity.sprite.getSize)

proc frameStep*(entity: var Entity) =
  entity.sprite.frameStep

proc render*(entity: Entity, ren: sdl2.RendererPtr) =
  entity.sprite.render(ren, entity.pos)

proc renderAnimated*(entity: var Entity, ren: sdl2.RendererPtr) =
  entity.render(ren)
  entity.currentFrameTime -= 1
  if entity.currentFrameTime <= 0:
    entity.frameStep
    entity.currentFrameTime = entity.frameTimer[entity.sprite.currentFrame]

proc move*(entity: var Entity, dir: Direction, speed: int = 10) =
  case dir
  of Direction.left:
    entity.pos.x -= speed
  of Direction.up:
    entity.pos.y -= speed
  of Direction.down:
    entity.pos.y += speed
  of Direction.right:
    entity.pos.x += speed

# this proc needs a real home :( please adopt
proc track*(view: var View, entity: Entity, trackDistance: int = 0, trackSpeedMult: float = 1) =
  if not (view.smaller(trackDistance).contains(entity.getView)):
    view.pos = view.pos + (entity.center - view.center) * trackSpeedMult

