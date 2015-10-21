from sdl2 import nil
import common_types
import spritesheet

type Entity* = object of RootObj
  sprite: SpriteSheet
  pos: Position
  frameTimer: seq[int]
  currentFrameTime: int  # decrement by 1 on each render

proc entity*(
  ren: sdl2.RendererPtr,
  file: string,
  size: Size
): Entity =
  let sprite = spriteSheet(ren, file, size)
  var frameTimer: seq[int] = @[]
  # completely temporary until i decide how to specify frame times
  for i in 0 .. sprite.numFrames:
    frameTimer.add(60)
  return Entity(
    sprite: sprite,
    pos: Position(x: 0, y: 0),
    frameTimer: frameTimer,
    currentFrameTime: frameTimer[0]
  )

proc entity*(ren: sdl2.RendererPtr, file: string, w, h: int): Entity =
  return entity(ren, file, Size(w: w, h: h))

proc `pos=`*(entity: var Entity, pos: Position) =
  entity.pos = pos

proc `pos=`*(entity: var Entity, x, y: int) =
  entity.pos = Position(x: x, y: y)

proc render(entity: Entity, ren: sdl2.RendererPtr) =
  entity.sprite.render(ren, entity.pos)

proc renderAnimated*(entity: var Entity, ren: sdl2.RendererPtr) =
  #echo entity.pos
  entity.render(ren)
  entity.currentFrameTime -= 1
  if entity.currentFrameTime <= 0:
    entity.sprite.frameStep
    entity.currentFrameTime = entity.frameTimer[entity.sprite.currentFrame]

proc move*(entity: var Entity, dir: Direction, speed: int = 0) =
  case dir
  of Direction.left:
    entity.pos.x -= speed
  of Direction.up:
    entity.pos.y -= speed
  of Direction.down:
    entity.pos.y += speed
  of Direction.right:
    entity.pos.x += speed
