import os, tables, json
from sdl2 import nil
import drawable, common_types, util

type
  AnimatedBy* {.pure.} = enum
    Time, Movement, None
  AnimationState* {.pure.} = enum
    Idle, Move
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
    states*: array[AnimationState, seq[Frame]]
    currentState*: AnimationState
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
  image: string,
  animatedBy: AnimatedBy = AnimatedBy.None,
  startingFrame: int = 0,
  screenPos: Position = Position(x: 0, y: 0),
  states: array[AnimationState, seq[Frame]],
): Sprite =
  return Sprite(
    tex: initDrawable(ren, image),
    zIndex: zIndex,
    screenPos: screenPos,
    states: states,
    currentState: AnimationState.Idle,
    currentFrame: startingFrame,
    animatedBy: animatedBy
  )

proc getSize*(sprite: Sprite): Size =
  return sprite.states[sprite.currentState][sprite.currentFrame].view.size

proc switchState*(sprite: Sprite, state: AnimationState) =
  sprite.currentFrame = 0
  sprite.currentState = state

proc frameStep*(sprite: Sprite) =
  # increment frame and wrap to first frame if we exceed the # of frames
  sprite.currentFrame = (sprite.currentFrame + 1) mod sprite.states[sprite.currentState].len

proc animate*(sprite: Sprite) =
  let frame = sprite.states[sprite.currentState][sprite.currentFrame]
  frame.resetTimer -= 1
  if frame.resetTimer <= 0:
    sprite.frameStep
    frame.resetTimer = frame.time

proc render*(sprite: Sprite, ren: sdl2.RendererPtr) =
  let frame = sprite.states[sprite.currentState][sprite.currentFrame]
  sprite.tex.render(
    ren,
    newView(sprite.screenPos, frame.view.size),
    frame.view
  )

  if sprite.animatedBy == AnimatedBy.Time:
    sprite.animate

proc loadSpriteDataFromJsonFile*(jsonFilename: string): array[AnimationState, seq[Frame]] =
  let spriteJson = parseFile(getResourceFile(jsonFilename & ".json"))

  for eachState in spriteJson["frames"].getFields:
    var frames: seq[Frame] = @[]
    for eachFrame in eachState.val:
      let size = if spriteJson.hasKey("size"): spriteJson["size"] else: eachFrame["size"]
      frames.add(
        newFrame(
          newView(
            eachFrame["pos"]["x"].getNum.int,
            eachFrame["pos"]["y"].getNum.int,
            size["w"].getNum.int,
            size["h"].getNum.int
          ),
          eachFrame["name"].getStr,
          eachFrame["time"].getNum.int
        )
      )
    case eachState.key
    of "idle":
      result[AnimationState.Idle] = frames
    of "move":
      result[AnimationState.Move] = frames
    else:
      discard

proc loadSpriteData*(jsonFilenames: openarray[string]): Table[string, array[AnimationState, seq[Frame]]] =
  result = initTable[string, array[AnimationState, seq[Frame]]](
    rightSize(jsonFilenames.len)
  )
  for filename in jsonFilenames:
    result[filename] = loadSpriteDataFromJsonFile(filename)
