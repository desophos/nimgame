from sdl2 import nil
import common_types
import spritesheet

type Entity* = object of RootObj
  sprite: SpriteSheet
  pos: Position

proc entity*(ren: sdl2.RendererPtr, file: string, size: Size): Entity =
  return Entity(sprite: spriteSheet(ren, file, size), pos: Position(x: 0, y: 0))

proc entity*(ren: sdl2.RendererPtr, file: string, w, h: int): Entity =
  return entity(ren, file, Size(w: w, h: h))

proc `pos=`*(entity: var Entity, pos: Position) =
  entity.pos = pos

proc `pos=`*(entity: var Entity, x, y: int) =
  entity.pos = Position(x: x, y: y)

proc render*(entity: Entity, ren: sdl2.RendererPtr) =
  entity.sprite.render(ren, entity.pos)

proc renderAnimated*(entity: var Entity, ren: sdl2.RendererPtr) =
  entity.render(ren)
  entity.sprite.frameStep

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
