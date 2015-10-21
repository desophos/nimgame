import os
from sdl2 import nil
import common_types

proc getResourceFile*(file: string): string =
  let
    srcDir = os.getCurrentDir()
    resDir = "res"
  echo os.joinPath(os.parentDir(srcDir), resDir, file)
  return os.joinPath(os.parentDir(srcDir), resDir, file)

proc SDLRectFromView*(view: View): sdl2.Rect =
  return sdl2.rect(
    x = cint(view.pos.x),
    y = cint(view.pos.y),
    w = cint(view.size.w),
    h = cint(view.size.h)
  )
