from os import nil
from sdl2 import nil
from sdl2/image import nil
import common_types

type Drawable* = object of RootObj
  texture: sdl2.TexturePtr

proc drawable*(ren: sdl2.RendererPtr, file: string): Drawable =
  return Drawable(texture: image.loadTexture(ren, getResourceFile(file)))

proc destroy*(drawable: Drawable) =
  sdl2.destroy drawable.texture

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, dstView: View, srcView: View) =
  var
    src = SDLRectFromView(srcView)
    dst = SDLRectFromView(dstView)
  sdl2.copy(ren, drawable.texture, addr(src), addr(dst))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, dstView: View) =
  var dst = SDLRectFromView(dstView)
  sdl2.copy(ren, drawable.texture, nil, addr(dst))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, x, y, w, h: int) =
  drawable.render(ren, view(x, y, w, h))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, pos: Position) =
  var w, h: cint
  sdl2.queryTexture(drawable.texture, nil, nil, addr(w), addr(h))
  render(drawable, ren, view(pos, int(w), int(h)))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, x, y: int) =
  drawable.render(ren, Position(x: x, y: y))

proc getSize*(drawable: Drawable): Size =
  var w, h: cint
  sdl2.queryTexture(drawable.texture, nil, nil, addr(w), addr(h))
  result.w = int(w)
  result.h = int(h)
