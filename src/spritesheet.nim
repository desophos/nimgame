from math import nil
from sdl2 import nil
import drawable
import common_types

type SpriteSheet = object of RootObj
  views: seq[View]
  sprite_size: Size
  sheet: Drawable

proc spriteSheet*(ren: sdl2.RendererPtr, file: string, size: Size): SpriteSheet =
  let
    sheet = drawable(ren, getResourceFile(file))
    sheet_size = sheet.getSize
  # sprites are defined by Views into a SpriteSheet
  # views are in reading order
  # (in rows, left to right, top to bottom)
  var
    views: seq[View]
    curX, curY: int
  for y in 0 .. int(math.ceil(sheet_size.h / size.h)):
    for x in 0 .. int(math.ceil(sheet_size.w / size.w)):
      views.add(view(curX, curY, size.w, size.h))
      curX += size.w
    curY += size.h
  return SpriteSheet(views: views, sprite_size: size, sheet: sheet)

proc spriteSheet*(ren: sdl2.RendererPtr, file: string, w, h: int): SpriteSheet =
  spriteSheet(ren, file, Size(w: w, h: h))

proc renderSprite*(sSheet: SpriteSheet, ren: sdl2.RendererPtr, which_view: int) =
  sSheet.sheet.render(ren, sSheet.views[which_view])
