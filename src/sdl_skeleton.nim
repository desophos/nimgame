from math import nil
import sdl2, sdl2/gfx, sdl2/image
import events, entity, physics, sprite, controller, job, drawable, common_types, util, global

discard sdl2.init(sdl2.INIT_EVERYTHING)

var
  gEventQueue = newEventHandler()
  mapView = newView(0, 0, tileMap[0].len * tileSize, tileMap.len * tileSize)
  camera = newView(0, 0, cameraWidth, cameraHeight)
  window: sdl2.WindowPtr = sdl2.createWindow("SDL Skeleton", 100, 100, cint(camera.size.w), cint(camera.size.h), sdl2.SDL_WINDOW_SHOWN)
  renderer: sdl2.RendererPtr = sdl2.createRenderer(window, -1, sdl2.Renderer_Accelerated or sdl2.Renderer_PresentVsync or sdl2.Renderer_TargetTexture)
  entityManager = newEntityManager(renderer, camera)
  physicsManager = newPhysicsManager(mapView)

# create static tiled background
for iRow in 0 ..< tileMap.len:
  for iCol in 0 ..< tileMap[iRow].len:
    # create tile
    let
      tileSprite = newSprite(
        renderer,
        "sheet.png",
        startingFrame = tileMap[iRow][iCol]
      )
      tileBody = newPhysicsBody(
        newView(iCol * tileSize, iRow * tileSize, tileSprite.getSize()),
        false,
        false
      )
    entityManager.addEntity(
      physicsManager,
      newEntity(
        tileSprite,
        tileBody,
        NoneController()
      )
    )

# create entities (dynamic foreground)
let
  playerSprite = newSprite(
    renderer,
    "sheet.png",
    true
  )
  playerBody = newPhysicsBody(
    newView(0, 0, playerSprite.getSize()),
    collidable = true,
    friction = 0.9
  )
var
  player = newCharacter(
    newEntity(playerSprite, playerBody, InputController()),
    renderer,
    Jobs.Mage
  )
entityManager.addEntity(physicsManager, player.entity)

var
  runGame = true
  fpsman: gfx.FpsManager

fpsman.init

sdl2.addEventWatch(
  proc(userdata: pointer, event: ptr Event): Bool32 {.cdecl.} =
    gEventQueue.addEvent(event[])
    return Bool32(true),
  nil
)

while runGame:
  sdl2.pumpEvents()

  var nextEvent = gEventQueue.peekEvent()
  echo repr(nextEvent.kind)
  if nextEvent.kind == QuitEvent:
    discard gEventQueue.getEvent()
    runGame = false
    break
  elif nextEvent.kind == UserEvent:
    discard gEventQueue.getEvent()
  elif nextEvent.kind == MouseButtonDown:
    entityManager.addEntity(physicsManager, player.useSkill("fireball"))

  let dt = fpsman.getFramerate / 1000

  renderer.setDrawColor(255, 255, 255, 255)
  renderer.clear

  entityManager.update(gEventQueue)
  physicsManager.update()

  camera.track(mapView, player.entity.getBody(), 30, 0.1)

  renderer.present

  # flush SDL2 queue, we don't care about it at all
  sdl2.flushEvents(0, 0x99999)

  # TEMPORARILY discard all other events
  while gEventQueue.hasEvents:
    discard gEventQueue.getEvent

  sdl2.delay(uint32(dt))

renderer.destroy
window.destroy
