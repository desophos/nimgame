from math import nil
import sdl2, sdl2/gfx, sdl2/image
import entity, drawable, common_types, util, global

discard sdl2.init(sdl2.INIT_EVERYTHING)

var
  camera = view(0, 0, cameraWidth, cameraHeight)
  window: sdl2.WindowPtr = sdl2.createWindow("SDL Skeleton", 100, 100, cint(camera.size.w), cint(camera.size.h), sdl2.SDL_WINDOW_SHOWN)
  renderer: sdl2.RendererPtr = sdl2.createRenderer(window, -1, sdl2.Renderer_Accelerated or sdl2.Renderer_PresentVsync or sdl2.Renderer_TargetTexture)
  entities: seq[Entity] = @[]
  background: seq[seq[Entity]] = @[]

# create static tiled background
for iRow in 0 ..< tileMap.len:
  background.add(@[])
  for iCol in 0 ..< tileMap[iRow].len:
    # create tile
    background[iRow].add(
      entity(
        renderer, "sheet.png",
        view(iCol * tileSize, iRow * tileSize, 100, 100)
      )
    )
    # step tile to correct frame
    for _ in 0 ..< tileMap[iRow][iCol]:
      background[iRow][iCol].frameStep

# create entities (dynamic foreground)
var
  player = entity(renderer, "sheet.png", view(0, 0, 100, 100))
entities.add(player)

var
  evt = sdl2.defaultEvent
  runGame = true
  fpsman: gfx.FpsManager

fpsman.init

while runGame:
  while bool(evt.pollEvent):
    case evt.kind
    of sdl2.QuitEvent:
      runGame = false
      break
    of sdl2.KeyDown:
      # evt.key is an accessor that casts evt to KeyboardEventPtr
      # so we can access the fields on KeyboardEventObj
      case evt.key.keysym.sym
      of sdl2.K_LEFT:
        player.move(mapView, Direction.left)
      of sdl2.K_UP:
        player.move(mapView, Direction.up)
      of sdl2.K_DOWN:
        player.move(mapView, Direction.down)
      of sdl2.K_RIGHT:
        player.move(mapView, Direction.right)
      else:
        continue
    else:
      continue

  let dt = fpsman.getFramerate / 1000

  renderer.setDrawColor(255, 255, 255, 255)
  renderer.clear

  # render tiles that intersect camera
  for iRow in 0 ..< background.len:
    for iCol in 0 ..< background[iRow].len:
      if camera.intersects(background[iRow][iCol].getView):
        background[iRow][iCol].render(renderer, camera)

  for i in 0 ..< entities.len:
    entities[i].renderAnimated(renderer, camera)

  camera.track(mapView, player, 50, 0.1)

  # debug outlines
#  renderer.setDrawColor(0, 0, 0, 255)
#  camera.drawOutline(renderer)
#  for iRow in 0 ..< background.len:
#    for iCol in 0 ..< background[iRow].len:
#      background[iRow][iCol].getView.drawOutline(renderer)

  renderer.present
  sdl2.delay(uint32(dt))

renderer.destroy
window.destroy
