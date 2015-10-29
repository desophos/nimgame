import os, json
from sdl2 import nil
import drawable, common_types, util

type Frame = ref object of RootObj
  view: View
  name: string
  time: int
  resetTimer: int  # decrement by 1 on each render

proc newFrame(view: View, name: string, time: int): Frame =
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
  animated: bool

proc newSprite*(ren: sdl2.RendererPtr, file: string, animated: bool = false, startingFrame: int = 0): Sprite =
  let
    tex = initDrawable(ren, file)
    (_, filename, _) = splitFile(file)
    spriteJson = parseFile(getResourceFile(filename & ".json"))

  var frames: seq[Frame] = @[]

  for eachFrame in spriteJson["frames"]:
    frames.add(
      newFrame(
        newView(
          eachFrame["pos"]["x"].getNum.int,
          eachFrame["pos"]["y"].getNum.int,
          eachFrame["size"]["w"].getNum.int,
          eachFrame["size"]["h"].getNum.int
        ),
        eachFrame["name"].getStr,
        eachFrame["time"].getNum.int
      )
    )

  return Sprite(tex: tex, frames: frames, currentFrame: startingFrame, animated: animated)

proc getSize*(sprite: Sprite): Size =
  return sprite.frames[sprite.currentFrame].view.size

proc frameStep(sprite: var Sprite) =
  # increment frame and wrap to first frame if we exceed the # of frames
  sprite.currentFrame = (sprite.currentFrame + 1) mod sprite.frames.len

proc render*(sprite: var Sprite, ren: sdl2.RendererPtr, pos: Position, camera: View) =
  let frame = sprite.frames[sprite.currentFrame]
  sprite.tex.render(
    ren,
    camera,
    newView(pos, frame.view.size),
    frame.view
  )

  if sprite.animated:
    frame.resetTimer -= 1
    if frame.resetTimer <= 0:
      sprite.frameStep
      frame.resetTimer = frame.time
