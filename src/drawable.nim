from os import nil
from sdl2 import nil
from sdl2/image import nil
import common_types
import util

type Drawable* = object of RootObj
  texture: sdl2.TexturePtr

proc drawable*(ren: sdl2.RendererPtr, file: string): Drawable =
  return Drawable(texture: image.loadTexture(ren, getResourceFile(file)))

proc destroy*(drawable: Drawable) =
  sdl2.destroy drawable.texture

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, camera: View, dstView: View, srcView: View) =
  var
    src = SDLRectFromView(srcView)
    dst = SDLRectFromView(dstView)
  dst.x -= cint(camera.pos.x)
  dst.y -= cint(camera.pos.y)
  sdl2.copy(ren, drawable.texture, addr(src), addr(dst))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, camera: View, dstView: View) =
  var dst = SDLRectFromView(dstView)
  dst.x -= cint(camera.pos.x)
  dst.y -= cint(camera.pos.y)
  sdl2.copy(ren, drawable.texture, nil, addr(dst))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, camera: View, x, y, w, h: int) =
  drawable.render(ren, camera, view(x, y, w, h))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, camera: View, pos: Position) =
  var w, h: cint
  sdl2.queryTexture(drawable.texture, nil, nil, addr(w), addr(h))
  drawable.render(ren, camera, view(pos, int(w), int(h)))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, camera: View, x, y: int) =
  drawable.render(ren, camera, Position(x: x, y: y))

proc getSize*(drawable: Drawable): Size =
  var w, h: cint
  sdl2.queryTexture(drawable.texture, nil, nil, addr(w), addr(h))
  result.w = int(w)
  result.h = int(h)
