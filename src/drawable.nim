from os import nil
import sdl2, sdl2/image
import common_types, util

type Drawable* = object of RootObj
  texture: sdl2.TexturePtr

proc initDrawable*(ren: sdl2.RendererPtr, file: string): Drawable =
  return Drawable(texture: image.loadTexture(ren, getResourceFile(file)))

proc destroy*(drawable: Drawable) =
  drawable.texture.destroy

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, dstView: View, srcView: View) =
  var
    src = SDLRectFromView(srcView)
    dst = SDLRectFromView(dstView)
  ren.copy(drawable.texture, addr(src), addr(dst))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, dstView: View) =
  var dst = SDLRectFromView(dstView)
  ren.copy(drawable.texture, nil, addr(dst))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, x, y, w, h: int) =
  drawable.render(ren, newView(x, y, w, h))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, pos: Position) =
  var w, h: cint
  drawable.texture.queryTexture(nil, nil, addr(w), addr(h))
  drawable.render(ren, newView(pos, int(w), int(h)))

proc render*(drawable: Drawable, ren: sdl2.RendererPtr, x, y: int) =
  drawable.render(ren, Position(x: x, y: y))

proc getSize*(drawable: Drawable): Size =
  var w, h: cint
  drawable.texture.queryTexture(nil, nil, addr(w), addr(h))
  result.w = int(w)
  result.h = int(h)
