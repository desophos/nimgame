import sdl2, sdl2/gfx, sdl2/image
import events, entity, physics, sprite, screen, controller, job, drawable, common_types, util, global

discard sdl2.init(sdl2.INIT_EVERYTHING)

var
  gEventQueue = newEventHandler()
  mapView = newView(0, 0, tileMap[0].len * tileSize, tileMap.len * tileSize)
  mainScreen = newScreen(
    cameraSize = cameraSize,
    windowName = "SDL Skeleton",
    windowPos = Position(x: 100, y: 100)
  )
  entityManager = newEntityManager()
  physicsManager = newPhysicsManager(mapView)

# create static tiled background
for iRow in 0 ..< tileMap.len:
  for iCol in 0 ..< tileMap[iRow].len:
    # create tile
    let
      tileSprite = newSprite(
        ren = mainScreen.renderer,
        zIndex = ZIndex.Background,
        file = "sheet.png",
        animated = false,
        startingFrame = tileMap[iRow][iCol],
        screenPos = Position(x: iCol * tileSize, y: iRow * tileSize)
      )
      tileBody = newPhysicsBody(
        newView(iCol * tileSize, iRow * tileSize, tileSprite.getSize()),
        false,
        false
      )
    entityManager.addEntity(
      physicsManager,
      mainScreen,
      newEntity(
        tileSprite,
        tileBody,
        NoneController()
      )
    )

# create entities (dynamic foreground)
let
  playerSprite = newSprite(
    ren = mainScreen.renderer,
    zIndex = ZIndex.Foreground,
    file = "sheet.png",
    animated = true
  )
  playerBody = newPhysicsBody(
    newView(0, 0, playerSprite.getSize()),
    collidable = true,
    friction = 0.9
  )
var
  player = newCharacter(
    newEntity(playerSprite, playerBody, InputController()),
    mainScreen,
    Jobs.Mage
  )
entityManager.addEntity(physicsManager, mainScreen, player.entity)

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
  if nextEvent.kind == QuitEvent:
    discard gEventQueue.getEvent()
    runGame = false
    break
  elif nextEvent.kind == UserEvent:
    discard gEventQueue.getEvent()
  elif nextEvent.kind == MouseButtonDown:
    entityManager.addEntity(physicsManager, mainScreen, player.useSkill("fireball"))

  let dt = fpsman.getFramerate / 1000

  entityManager.update(gEventQueue, physicsManager)
  physicsManager.step

  mainScreen.track(mapView, player.entity.getBody(), 30, 0.1)
  mainScreen.render

  # flush SDL2 queue, we don't care about it at all
  sdl2.flushEvents(0, 0x99999)

  # TEMPORARILY discard all other events
  while gEventQueue.hasEvents:
    discard gEventQueue.getEvent

  sdl2.delay(uint32(dt))

mainScreen.destroy
