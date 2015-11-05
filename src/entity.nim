import future, basic2d, sequtils
import sdl2
import events, sprite, screen, physics, controller, common_types

type
  Entity* = ref object of RootObj
    # basically just a base type
    # that bundles a bunch of common systems
    sprite*: Sprite
    body*: PhysicsBody
    controller*: Controller
  EntityManager = ref object of RootObj
    entities*: seq[Entity]

proc newEntity*(
  sprite: Sprite,
  body: PhysicsBody,
  controller: Controller
): Entity =
  return Entity(
    sprite: sprite,
    body: body,
    controller: controller
  )

proc newEntityManager*(): EntityManager =
  return EntityManager(
    entities: @[]
  )

proc addEntity*(manager: EntityManager, physicsManager: PhysicsManager, screen: Screen, entity: Entity) =
  manager.entities.add(entity)
  physicsManager.addBody(entity.body)
  screen.addSprite(entity.sprite)

proc removeEntity*(manager: EntityManager, entity: Entity) =
  manager.entities.del(manager.entities.find(entity))

proc update(entity: Entity, eventQueue: EventHandler, physicsManager: PhysicsManager) =
  # update world position and screen position
  let body = entity.body
  if body.active:
    let initialPos = body.rect.pos
    for direction in entity.controller.chooseDirection():
      body.move(direction)
    body.velocity.scale(body.friction)
    body.rect.pos += initPosition(body.velocity)
    body.constrainTo(physicsManager.bounds)
    entity.sprite.screenPos += body.rect.pos - initialPos
    # switch to appropriate animation state (Move if moved) and animate
    if entity.sprite.animatedBy == AnimatedBy.Movement:
      if body.rect.pos.distanceFrom(initialPos).abs > 0:
        if entity.sprite.currentState != AnimationState.Move:
          entity.sprite.switchState(AnimationState.Move)
      else:
        if entity.sprite.currentState != AnimationState.Idle:
          entity.sprite.switchState(AnimationState.Idle)
      entity.sprite.animate

proc update*(manager: EntityManager, eventQueue: EventHandler, physicsManager: PhysicsManager, screen: Screen) =
  for entity in manager.entities:
    entity.update(eventQueue, physicsManager)
  # destroy entities marked for death
  # this is probably super slow :/
  while manager.entities.any(entity => entity.body.toDestroy):
    for i in 0 ..< manager.entities.len:
      let entity = manager.entities[i]
      if entity.body.toDestroy:
        screen.removeSprite(entity.sprite)
        physicsManager.removeBody(entity.body)
        manager.removeEntity(entity)
        # break so we iterate over the seq from the start again
        # this is slow but safe
        break
