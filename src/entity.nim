import future, basic2d
import sdl2
import events, sprite, screen, physics, controller, common_types

type
  Entity* = ref object of RootObj
    # basically just a base type
    # that bundles a bunch of common systems
    sprite: Sprite
    physics: PhysicsBody
    controller: Controller
  EntityManager = ref object of RootObj
    entities: seq[Entity]
    physicsManager: PhysicsManager
    screen: Screen

proc newEntity*(
  sprite: Sprite,
  physics: PhysicsBody,
  controller: Controller
): Entity =
  return Entity(
    sprite: sprite,
    physics: physics,
    controller: controller
  )

proc newEntityManager*(): EntityManager =
  return EntityManager(
    entities: @[]
  )

proc getBody*(entity: Entity): PhysicsBody =
  return entity.physics

proc getSprite*(entity: Entity): Sprite =
  return entity.sprite

proc addEntity*(manager: EntityManager, physicsManager: PhysicsManager, screen: Screen, entity: Entity) =
  manager.entities.add(entity)
  physicsManager.addBody(entity.physics)
  screen.addSprite(entity.sprite)

proc update(entity: Entity, eventQueue: EventHandler, physicsManager: PhysicsManager) =
  # update world position and screen position
  let body = entity.physics
  if body.active:
    let initialPos = body.rect.pos
    for direction in entity.controller.chooseDirection(eventQueue):
      body.move(direction)
    body.velocity.scale(body.friction)
    body.rect.pos += initPosition(body.velocity)
    body.constrainTo(physicsManager.bounds)
    entity.sprite.screenPos += body.rect.pos - initialPos
    # animate or change to idle frame if not moving
    if entity.getSprite.animatedBy == AnimatedBy.Movement:
      if body.rect.pos.distanceFrom(initialPos).abs > 0:
        if entity.sprite.currentState != AnimationState.Move:
          entity.sprite.switchState(AnimationState.Move)
        entity.sprite.animate
      else:
        if entity.sprite.currentState != AnimationState.Idle:
          entity.sprite.switchState(AnimationState.Idle)
        entity.sprite.animate

proc update*(manager: EntityManager, eventQueue: EventHandler, physicsManager: PhysicsManager) =
  for entity in manager.entities:
    entity.update(eventQueue, physicsManager)
