import os, json
from sdl2 import nil
import drawable, common_types, util

type Frame = ref object of RootObj
  view: View
  name: string
  time: int
  resetTimer: int  # decrement by 1 on each render

proc frame(view: View, name: string, time: int): Frame =
  return Frame(
    view: view,
    name: name,
    time: time,
    resetTimer: time
  )

type Sprite* = ref object of RootObj
  tex: Drawable
  frames: seq[Frame]
  currentFrame*: int
  pos*: Position
  animated: bool

proc sprite*(ren: sdl2.RendererPtr, file: string, pos: Position, animated: bool = false): Sprite =
  let
    tex = drawable(ren, file)
    (_, filename, _) = splitFile(file)
    spriteJson = parseFile(getResourceFile(filename & ".json"))

  var frames: seq[Frame] = @[]

  for eachFrame in spriteJson["frames"]:
    frames.add(
      frame(
        view(
          eachFrame["pos"]["x"].getNum.int,
          eachFrame["pos"]["y"].getNum.int,
          eachFrame["size"]["w"].getNum.int,
          eachFrame["size"]["h"].getNum.int
        ),
        eachFrame["name"].getStr,
        eachFrame["time"].getNum.int
      )
    )

  return Sprite(tex: tex, frames: frames, currentFrame: 0, pos: pos, animated: animated)

proc sprite*(ren: sdl2.RendererPtr, file: string, animated: bool = false): Sprite =
  return sprite(ren, file, Position(x: 0, y: 0), animated)

proc `pos=`*(sprite: var Sprite, pos: Position) =
  sprite.pos = pos

proc `pos=`*(sprite: var Sprite, x, y: int) =
  sprite.pos = Position(x: x, y: y)

proc getSize*(sprite: Sprite): Size =
  return sprite.frames[sprite.currentFrame].view.size

proc getView*(sprite: Sprite): View =
  return view(sprite.pos, sprite.getSize)

proc center*(sprite: Sprite): Position =
  let size = sprite.getSize
  return Position(
    x: sprite.pos.x + int(size.w / 2),
    y: sprite.pos.y + int(size.h / 2)
  )

proc constrainTo*(sprite: var Sprite, constrain: View) =
  var constrainedView = sprite.getView
  constrainedView.constrainTo(constrain)
  sprite.pos = constrainedView.pos

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

proc frameStep(sprite: var Sprite) =
  # increment frame and wrap to first frame if we exceed the # of frames
  sprite.currentFrame = (sprite.currentFrame + 1) mod sprite.frames.len

proc render*(sprite: var Sprite, ren: sdl2.RendererPtr, camera: View) =
  let frame = sprite.frames[sprite.currentFrame]
  sprite.tex.render(
    ren,
    camera,
    view(sprite.pos, frame.view.size),
    frame.view
  )

  if sprite.animated:
    frame.resetTimer -= 1
    if frame.resetTimer <= 0:
      sprite.frameStep
      frame.resetTimer = frame.time

# this proc needs a real home :( please adopt
proc track*(view: var View, constrain: View, sprite: Sprite, trackDistance: int = 0, trackSpeedMult: float = 1) =
  if not (view.smaller(trackDistance).contains(sprite.getView)):
    view.pos = view.pos + (sprite.center - view.center) * trackSpeedMult
  view.constrainTo(constrain)
