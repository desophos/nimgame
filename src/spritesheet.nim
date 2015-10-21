from math import nil
from sdl2 import nil
import drawable
import common_types
import util

type SpriteSheet* = object of RootObj
  views: seq[View]
  sprite_size: Size
  sheet: Drawable
  currentFrame*: int

proc spriteSheet*(ren: sdl2.RendererPtr, file: string, size: Size): SpriteSheet =
  let
    sheet = drawable(ren, file)
    sheet_size = sheet.getSize
  # sprites are defined by Views into a SpriteSheet
  # views are in reading order
  # (in rows, left to right, top to bottom)
  var
    views: seq[View] = @[]
    curX, curY: int
  for y in 0 ..< int(math.ceil(sheet_size.h / size.h)):
    curX = 0
    for x in 0 ..< int(math.ceil(sheet_size.w / size.w)):
      views.add(view(curX, curY, size.w, size.h))
      curX += size.w
    curY += size.h
  return SpriteSheet(views: views, sprite_size: size, sheet: sheet)

proc spriteSheet*(ren: sdl2.RendererPtr, file: string, w, h: int): SpriteSheet =
  return spriteSheet(ren, file, Size(w: w, h: h))

proc numFrames*(sSheet: SpriteSheet): int =
  return sSheet.views.len

proc render*(sSheet: SpriteSheet, ren: sdl2.RendererPtr, pos: Position) =
  sSheet.sheet.render(
    ren,
    view(pos, sSheet.views[sSheet.currentFrame].size),
    sSheet.views[sSheet.currentFrame]
  )

proc frameStep*(sSheet: var SpriteSheet) =
  # increment frame and wrap to first frame if we exceed the # of frames
  sSheet.currentFrame = (sSheet.currentFrame + 1) mod sSheet.views.len
