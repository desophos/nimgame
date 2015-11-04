import os, json
from sdl2 import nil
import drawable, common_types, util

type
  AnimatedBy* {.pure.} = enum
    Time, Movement, None
  ZIndex* = enum
    Background, Foreground
  Frame = ref object of RootObj
    view: View
    name: string
    time: int
    resetTimer: int  # decrement by 1 on each render
  Sprite* = ref object of RootObj
    tex: Drawable
    zIndex*: ZIndex
    screenPos*: Position
    frames: seq[Frame]
    currentFrame*: int
    animatedBy*: AnimatedBy

proc newFrame(view: View, name: string, time: int): Frame =
  return Frame(
    view: view,
    name: name,
    time: time,
    resetTimer: time
  )

proc destroy*(sprite: Sprite) =
  sprite.tex.destroy

proc newSprite*(
  ren: sdl2.RendererPtr,
  zIndex: ZIndex,
  file: string,
  animatedBy: AnimatedBy = AnimatedBy.None,
  startingFrame: int = 0,
  screenPos: Position = Position(x: 0, y: 0)
): Sprite =
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

  return Sprite(
    tex: tex, zIndex: zIndex, screenPos: screenPos,
    frames: frames, currentFrame: startingFrame, animatedBy: animatedBy
  )

proc getSize*(sprite: Sprite): Size =
  return sprite.frames[sprite.currentFrame].view.size

proc frameStep(sprite: Sprite) =
  # increment frame and wrap to first frame if we exceed the # of frames
  sprite.currentFrame = (sprite.currentFrame + 1) mod sprite.frames.len

proc animate*(sprite: Sprite) =
  let frame = sprite.frames[sprite.currentFrame]
  frame.resetTimer -= 1
  if frame.resetTimer <= 0:
    sprite.frameStep
    frame.resetTimer = frame.time

proc render*(sprite: Sprite, ren: sdl2.RendererPtr) =
  let frame = sprite.frames[sprite.currentFrame]
  sprite.tex.render(
    ren,
    newView(sprite.screenPos, frame.view.size),
    frame.view
  )

  if sprite.animatedBy == AnimatedBy.Time:
    sprite.animate
