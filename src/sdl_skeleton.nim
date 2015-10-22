import sdl2
from sdl2/gfx import nil
from sdl2/image import nil
from math import nil
import drawable
import common_types
import entity

discard sdl2.init(sdl2.INIT_EVERYTHING)

const
  screenWidth: int = 300
  screenHeight: int = 400
  cameraWidth: int = 150
  cameraHeight: int = 150
  tileSize: int = 100

var
  window: sdl2.WindowPtr = sdl2.createWindow("SDL Skeleton", 100, 100, cint(screenWidth), cint(screenHeight), sdl2.SDL_WINDOW_SHOWN)
  renderer: sdl2.RendererPtr = sdl2.createRenderer(window, -1, sdl2.Renderer_Accelerated or sdl2.Renderer_PresentVsync or sdl2.Renderer_TargetTexture)
  camera = view(0, 0, cameraWidth, cameraHeight)
  entities: seq[Entity] = @[]
  background: seq[seq[Entity]] = @[]

# tiles (static background)
let
  tile_map = [
    [0, 1, 0],
    [1, 2, 1],
    [2, 3, 2],
    [3, 0, 3]
  ]
  
# create tiled background
for iRow in 0 ..< tile_map.len:
  background.add(@[])
  for iCol in 0 ..< tile_map[iRow].len:
    # create tile
    background[iRow].add(
      entity(
        renderer, "sheet.png",
        view(iCol * tileSize, iRow * tileSize, 100, 100)
      )
    )
    # step tile to correct frame
    for _ in 0 ..< tile_map[iRow][iCol]:
      background[iRow][iCol].frameStep

# entities (dynamic foreground)
var
  player = entity(renderer, "sheet.png", view(0, 0, 100, 100))
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

  # render tiles that intersect camera
  for iRow in 0 ..< background.len:
    for iCol in 0 ..< background[iRow].len:
      if camera.intersects(background[iRow][iCol].getView):
        background[iRow][iCol].render(renderer)

  for i in 0 ..< entities.len:
    entities[i].renderAnimated(renderer)

  camera.track(player, 10, 0.1)

  sdl2.present(renderer)
  sdl2.delay(uint32(dt))

sdl2.destroy renderer
sdl2.destroy window
