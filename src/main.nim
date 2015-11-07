import future, sequtils, basic2d, tables
from math import random, randomize
import sdl2, sdl2/gfx, sdl2/image
import events, entity, physics, sprite, screen, controller, job, drawable, common_types, util, global

randomize()  # init random
discard sdl2.init(sdl2.INIT_EVERYTHING)

var
  gEventQueue = newEventHandler()
  mapView = newView(0, 0, tileMap[0].len * tileSize, tileMap.len * tileSize)
  mainScreen = newScreen(
    cameraSize = cameraSize,
    windowName = "Main Window",
    windowPos = Position(x: 200, y: 200)
  )
  entityManager = newEntityManager()
  physicsManager = newPhysicsManager(mapView)

for filename in ["forest.png", "shepherd.png", "fireball.png"]:
  mainScreen.addTexture(filename)

let spritesData = loadSpriteData(["forest_grass", "forest_tree", "shepherd"])

# create tiled background
for iRow in 0 ..< tileMap.len:
  for iCol in 0 ..< tileMap[iRow].len:
    # create tile
    let
      tileSprite = newSprite(
        ren = mainScreen.renderer,
        zIndex = ZIndex.Background,
        tex = mainScreen.textures["forest.png"],
        startingFrame = tileMap[iRow][iCol],
        screenPos = Position(x: iCol * tileSize, y: iRow * tileSize),
        states = spritesData["forest_grass"]
      )
      tileBody = newPhysicsBody(
        newView(tileSprite.screenPos, tileSprite.getSize()),
        collidable = false,
        active = false
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

var stationaryCollisionEvents: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]]
stationaryCollisionEvents[PhysicsEvent.onCollision] = @[
  proc(body: PhysicsBody, other: PhysicsBody) {.closure.} =
    # stop collided entity from moving
    other.velocity = vector2d(0, 0)
]

# make some happy little trees
let numTrees = 6
for i in 0 ..< numTrees:
  var
    treeSprite = newSprite(
      ren = mainScreen.renderer,
      zIndex = ZIndex.Foreground,
      tex = mainScreen.textures["forest.png"],
      screenPos = Position(
        x: random(mapView.size.w),
        y: random(mapView.size.h)
      ),
      states = spritesData["forest_tree"]
    )
    treeBody = newPhysicsBody(
      newView(
        treeSprite.screenPos,
        treeSprite.getSize()
      ),
      collidable = true,
      events = stationaryCollisionEvents
    )

  # make sure tree doesn't collide with any other entity
  while entityManager.entities.any(
    proc(entity: Entity): bool =
      return entity.sprite.zIndex == ZIndex.Foreground and
             entity.body.rect.intersects(treeBody.rect)
  ):
    treeSprite.screenPos = Position(
      x: random(mapView.size.w.float).int,
      y: random(mapView.size.h.float).int
    )
    treeBody.rect = newView(
      treeSprite.screenPos,
      treeSprite.getSize()
    )

  entityManager.addEntity(
    physicsManager,
    mainScreen,
    newEntity(
      treeSprite,
      treeBody,
      NoneController()
    )
  )


# create entities
let
  playerSprite = newSprite(
    ren = mainScreen.renderer,
    zIndex = ZIndex.Foreground,
    tex = mainScreen.textures["shepherd.png"],
    animatedBy = AnimatedBy.Movement,
    states = spritesData["shepherd"]
  )
  playerBody = newPhysicsBody(
    newView(0, 0, playerSprite.getSize()),
    collidable = true,
    friction = 0.8
  )
  player = newCharacter(
    newEntity(playerSprite, playerBody, InputController()),
    mainScreen,
    Jobs.Mage
  )

entityManager.addEntity(physicsManager, mainScreen, player.entity)

var
  runGame = true
  fpsManager: gfx.FpsManager

fpsManager.init

# just make SDL2 add its events to our event queue
sdl2.addEventWatch(
  proc(userdata: pointer, event: ptr Event): Bool32 {.cdecl.} =
    gEventQueue.addEvent(event[])
    return Bool32(true),
  nil
)

while runGame:
  # pump all events that have passed since the last invocation
  # through the SDL2 event pipeline into our gEventQueue
  sdl2.pumpEvents()

  # main event handling loop
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
    else:  # including UserEvent (noneEvent)
      discard gEventQueue.getEvent()

  entityManager.update(gEventQueue, physicsManager, mainScreen)
  physicsManager.step

  mainScreen.track(mapView, player.entity.body, 30, 0.1)
  mainScreen.render

  # flush SDL2 queue, we don't care about it at all
  sdl2.flushEvents(0, 0x99999)

  let dt = fpsManager.getFramerate / 1000
  sdl2.delay(uint32(dt))

mainScreen.destroy
