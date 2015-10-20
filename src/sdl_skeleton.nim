from sdl2 import nil
from sdl2/gfx import nil
from sdl2/image import nil
from math import nil
import drawable
import common_types
import entity

discard sdl2.init(sdl2.INIT_EVERYTHING)

const
  screenWidth: cint = 640
  screenHeight: cint = 480
  tileSize: int = 40

var
  window: sdl2.WindowPtr = sdl2.createWindow("SDL Skeleton", 100, 100, screenWidth, screenHeight, sdl2.SDL_WINDOW_SHOWN)
  renderer: sdl2.RendererPtr = sdl2.createRenderer(window, -1, sdl2.Renderer_Accelerated or sdl2.Renderer_PresentVsync or sdl2.Renderer_TargetTexture)
  entities: seq[Entity]

# images
let
  background = drawable(renderer, "background.png")
  foreground = drawable(renderer, "image.png")

# sprites
var
  sheet = entity(renderer, "sheet.png", 100, 100)
entities.add(sheet)

var
  evt = sdl2.defaultEvent
  runGame = true
  fpsman: gfx.FpsManager

gfx.init(fpsman)

while runGame:
  while bool(sdl2.pollEvent(evt)):
    if evt.kind == sdl2.QuitEvent:
      runGame = false
      break
    elif evt.kind == sdl2.KeyDown or
        evt.kind == sdl2.MouseButtonDown:
      for i in 0 .. entities.len:
        entities[i].renderAnimated(renderer)

  let dt = gfx.getFramerate(fpsman) / 1000

  sdl2.setDrawColor(renderer, 0, 0, 0, 255)
  sdl2.clear(renderer)

  for entity in entities:
    entity.render(renderer)

  for x in 0 .. int(math.ceil(screenWidth / tileSize)):
    for y in 0 .. int(math.ceil(screenHeight / tileSize)):
      background.render(renderer, x * tileSize, y * tileSize, tileSize, tileSize)

  let fSize = foreground.getSize
  foreground.render(renderer, int((screenWidth - fSize.w) / 2), int((screenHeight - fSize.h) / 2))

  sdl2.present(renderer)
  sdl2.delay(uint32(dt))

foreground.destroy
background.destroy
sdl2.destroy renderer
sdl2.destroy window
