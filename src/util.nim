import future, os, tables
from sdl2 import nil
import common_types

proc getResourceFile*(file: string): string =
  return os.joinPath(os.parentDir(os.getAppDir()), "res", file)

proc SDLRectFromView*(view: View): sdl2.Rect =
  return sdl2.rect(
    x = cint(view.pos.x),
    y = cint(view.pos.y),
    w = cint(view.size.w),
    h = cint(view.size.h)
  )

proc drawOutline*(view: View, ren: sdl2.RendererPtr) =
  var rect = view.SDLRectFromView
  sdl2.drawRect(ren, rect)

iterator takeWhile*[T](s: seq[T], pred: T -> bool): seq[T] =
  for i in 0 ..< s.len:
    if not pred(s[i]):
      break
    yield s[i]

proc filterTableByKey*[T, S](t: Table[T, S], pred: T -> bool): Table[T, S] =
  #return lc[(k, v) | (k <- t.keys, v <- t.values, pred(k)), seq[(T, S)]].toTable
  var s: seq[(T, S)] = @[]
  for k, v in t.pairs:
    if pred(k):
      s.add((k, v))
  return s.toTable
