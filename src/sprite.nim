import json
from sdl2 import nil
import common_types, spritesheet

type Sprite* = ref object of RootObj
  sheet: SpriteSheet
  pos*: Position
  animated*: bool

proc sprite*(ren: sdl2.RendererPtr, file: string, pos: Position, animated: bool = false): Sprite =
  return Sprite(sheet: spriteSheet(ren, file), pos: pos, animated: animated)

proc sprite*(ren: sdl2.RendererPtr, file: string, animated: bool = false): Sprite =
  return sprite(ren, file, Position(x: 0, y: 0), animated)

proc `pos=`*(sprite: var Sprite, pos: Position) =
  sprite.pos = pos

proc `pos=`*(sprite: var Sprite, x, y: int) =
  sprite.pos = Position(x: x, y: y)

proc center*(sprite: Sprite): Position =
  let size = sprite.sheet.getSize
  return Position(
    x: sprite.pos.x + int(size.w / 2),
    y: sprite.pos.y + int(size.h / 2)
  )

proc getView*(sprite: Sprite): View =
  return view(sprite.pos, sprite.sheet.getSize)

proc setFrame*(sprite: var Sprite, frame: int) =
  sprite.sheet.currentFrame = frame

proc constrainTo*(sprite: var Sprite, constrain: View) =
  var constrainedView = sprite.getView
  constrainedView.constrainTo(constrain)
  sprite.pos = constrainedView.pos

proc render*(sprite: Sprite, ren: sdl2.RendererPtr, camera: View) =
  sprite.sheet.render(ren, camera, sprite.pos)
  if sprite.animated:
    sprite.sheet.animate

proc move*(sprite: var Sprite, constrain: View, dir: Direction, speed: int = 20) =
  case dir
  of Direction.left:
    sprite.pos.x -= speed
  of Direction.up:
    sprite.pos.y -= speed
  of Direction.down:
    sprite.pos.y += speed
  of Direction.right:
    sprite.pos.x += speed
  sprite.constrainTo(constrain)

# this proc needs a real home :( please adopt
proc track*(view: var View, constrain: View, sprite: Sprite, trackDistance: int = 0, trackSpeedMult: float = 1) =
  if not (view.smaller(trackDistance).contains(sprite.getView)):
    view.pos = view.pos + (sprite.center - view.center) * trackSpeedMult
  view.constrainTo(constrain)
