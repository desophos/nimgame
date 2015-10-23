import json
from sdl2 import nil
import common_types, spritesheet

type Entity* = ref object of RootObj
  sprite: SpriteSheet
  pos*: Position
  animated*: bool

proc entity*(ren: sdl2.RendererPtr, file: string, pos: Position, animated: bool = false): Entity =
  return Entity(sprite: spriteSheet(ren, file), pos: pos, animated: animated)

proc entity*(ren: sdl2.RendererPtr, file: string, animated: bool = false): Entity =
  return entity(ren, file, Position(x: 0, y: 0), animated)

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

proc setFrame*(entity: var Entity, frame: int) =
  entity.sprite.currentFrame = frame

proc constrainTo*(entity: var Entity, constrain: View) =
  var constrainedView = entity.getView
  constrainedView.constrainTo(constrain)
  entity.pos = constrainedView.pos

proc render*(entity: Entity, ren: sdl2.RendererPtr, camera: View) =
  entity.sprite.render(ren, camera, entity.pos)
  if entity.animated:
    entity.sprite.animate

proc move*(entity: var Entity, constrain: View, dir: Direction, speed: int = 10) =
  case dir
  of Direction.left:
    entity.pos.x -= speed
  of Direction.up:
    entity.pos.y -= speed
  of Direction.down:
    entity.pos.y += speed
  of Direction.right:
    entity.pos.x += speed
  entity.constrainTo(constrain)

# this proc needs a real home :( please adopt
proc track*(view: var View, constrain: View, entity: Entity, trackDistance: int = 0, trackSpeedMult: float = 1) =
  if not (view.smaller(trackDistance).contains(entity.getView)):
    view.pos = view.pos + (entity.center - view.center) * trackSpeedMult
  view.constrainTo(constrain)
