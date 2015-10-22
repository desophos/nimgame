import sdl2
from sdl2/gfx import nil
from sdl2/image import nil
from math import nil
import drawable
import common_types
import entity

discard sdl2.init(sdl2.INIT_EVERYTHING)

const
  screenWidth: int = 640
  screenHeight: int = 480
  cameraWidth: int = 320
  cameraHeight: int = 240
  tileSize: int = 40

var
  window: sdl2.WindowPtr = sdl2.createWindow("SDL Skeleton", 100, 100, cint(screenWidth), cint(screenHeight), sdl2.SDL_WINDOW_SHOWN)
  renderer: sdl2.RendererPtr = sdl2.createRenderer(window, -1, sdl2.Renderer_Accelerated or sdl2.Renderer_PresentVsync or sdl2.Renderer_TargetTexture)
  camera = view(int(screenWidth/2), int(screenHeight/2), cameraWidth, cameraHeight)
  entities: seq[Entity] = @[]

# tiles (static background)
let
  background = drawable(renderer, "background.bmp")

# entities (dynamic foreground)
var
  player = entity(renderer, "sheet.png", 100, 100)
entities.add(player)

var
  evt = sdl2.defaultEvent
  runGame = true
  fpsman: gfx.FpsManager

gfx.init(fpsman)

while runGame:
  while bool(sdl2.pollEvent(evt)):
    case evt.kind
    of sdl2.QuitEvent:
      runGame = false
      break
    of sdl2.KeyDown:
      # evt.key is an accessor that casts evt to KeyboardEventPtr
      # so we can access the fields on KeyboardEventObj
      case evt.key.keysym.sym
      of sdl2.K_LEFT:
        player.move(Direction.left)
      of sdl2.K_UP:
        player.move(Direction.up)
      of sdl2.K_DOWN:
        player.move(Direction.down)
      of sdl2.K_RIGHT:
        player.move(Direction.right)
      else:
        continue
    else:
      continue

  let dt = gfx.getFramerate(fpsman) / 1000

  sdl2.setDrawColor(renderer, 0, 0, 0, 255)
  sdl2.clear(renderer)

  # tile background image across screen
  #for x in 0 .. int(math.ceil(screenWidth / tileSize)):
  #  for y in 0 .. int(math.ceil(screenHeight / tileSize)):
  #    background.render(renderer, x * tileSize, y * tileSize, tileSize, tileSize)

  background.render(renderer, camera, camera)

  for i in 0 ..< entities.len:
    entities[i].renderAnimated(renderer)

  camera.track(player, 50, 0.1)

  sdl2.present(renderer)
  sdl2.delay(uint32(dt))

background.destroy
sdl2.destroy renderer
sdl2.destroy window
