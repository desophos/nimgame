import json, os
from math import nil
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

type SpriteSheet* = object of RootObj
  tex: Drawable
  frames: seq[Frame]
  currentFrame*: int

proc spriteSheet*(ren: sdl2.RendererPtr, file: string): SpriteSheet =
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

  return SpriteSheet(tex: tex, frames: frames, currentFrame: 0)

proc numFrames*(sSheet: SpriteSheet): int =
  return sSheet.frames.len

proc frameStep(sSheet: var SpriteSheet) =
  # increment frame and wrap to first frame if we exceed the # of frames
  sSheet.currentFrame = (sSheet.currentFrame + 1) mod sSheet.numFrames

proc animate*(sSheet: var SpriteSheet) =
  let frame = sSheet.frames[sSheet.currentFrame]
  frame.resetTimer -= 1
  if frame.resetTimer <= 0:
    sSheet.frameStep
    frame.resetTimer = frame.time

proc render*(sSheet: var SpriteSheet, ren: sdl2.RendererPtr, camera: View, pos: Position) =
  let frame = sSheet.frames[sSheet.currentFrame]
  sSheet.tex.render(
    ren,
    camera,
    view(pos, frame.view.size),
    frame.view
  )

proc getSize*(sSheet: SpriteSheet): Size =
  return sSheet.frames[sSheet.currentFrame].view.size
