import sequtils
import sdl2, sdl2/gfx, sdl2/image
import events, entity, physics, sprite, screen, controller, job, drawable, common_types, util, global

discard sdl2.init(sdl2.INIT_EVERYTHING)

var
  gEventQueue = newEventHandler()
  mapView = newView(0, 0, tileMap[0].len * tileSize, tileMap.len * tileSize)
  mainScreen = newScreen(
    cameraSize = cameraSize,
    windowName = "SDL Skeleton",
    windowPos = Position(x: 200, y: 200)
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
        file = "grass.png",
        animatedBy = AnimatedBy.None,
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
    file = "shepherd.png",
    animatedBy = AnimatedBy.Movement
  )
  playerBody = newPhysicsBody(
    newView(0, 0, playerSprite.getSize()),
    collidable = true,
    friction = 0.8
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

# just make SDL2 add its events to our event queue
sdl2.addEventWatch(
  proc(userdata: pointer, event: ptr Event): Bool32 {.cdecl.} =
    gEventQueue.addEvent(event[])
    return Bool32(true),
  nil
)

while runGame:
  sdl2.pumpEvents()

  while gEventQueue.hasEvents:
    let nextEvent = gEventQueue.peekEvent()
    case nextEvent.kind
    of QuitEvent:
      discard gEventQueue.getEvent()
      runGame = false
      break
    of MouseButtonDown:
      discard gEventQueue.getEvent()
      entityManager.addEntity(physicsManager, mainScreen, player.useSkill("fireball"))
    of KeyDown:
      # we only care about direction keys for now
      if not nextEvent.isValidDirectionKey:
        discard gEventQueue.getEvent()
        continue
      # get all directions in queue
      let directions = map(
        toSeq(gEventQueue.takeEventsWithKindWhile(KeyDown, isValidDirectionKey)),
        eventToDirection
      )
      # give directions to player
      player.entity.controller.directionQueue =
        if directions.len > 0:
          directions
        else:
          @[Direction.idle]
    else:  # including UserEvent
      discard gEventQueue.getEvent()

  let dt = fpsman.getFramerate / 1000

  entityManager.update(gEventQueue, physicsManager, mainScreen)
  physicsManager.step

  mainScreen.track(mapView, player.entity.body, 30, 0.1)
  mainScreen.render

  # flush SDL2 queue, we don't care about it at all
  sdl2.flushEvents(0, 0x99999)

  sdl2.delay(uint32(dt))

mainScreen.destroy
