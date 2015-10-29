import future
import sdl2
import events, sprite, physics, controller, common_types

type
  Entity* = ref object of RootObj
    # basically just a base type
    # that bundles a bunch of common systems
    sprite: Sprite
    physics: PhysicsBody
    controller: Controller
#  EntityTemplate* = ref object of RootObj
#    # an Entity whose fields are closures
#    sprite: void -> Sprite
#    physics: void -> PhysicsBody
#    controller: void -> Controller
  EntityManager = ref object of RootObj
    entities: seq[Entity]
    renderer: RendererPtr
    camera: View

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

#proc entityTemplate*(
#  sprite: void -> Sprite,
#  physics: void -> PhysicsBody,
#  controller: void -> Controller
#): EntityTemplate =
#  return EntityTemplate(
#    sprite: sprite,
#    physics: physics,
#    controller: controller
#  )
#
#proc generate*(generator: EntityTemplate): Entity =
#  return Entity(
#    sprite: generator.sprite(),
#    physics: generator.physics(),
#    controller: generator.controller()
#  )

proc newEntityManager*(
  renderer: RendererPtr,
  camera: View
): EntityManager =
  return EntityManager(
    entities: @[],
    renderer: renderer,
    camera: camera
  )

proc getBody*(entity: Entity): PhysicsBody =
  return entity.physics

proc addEntity*(manager: EntityManager, physicsManager: PhysicsManager, entity: Entity) =
  manager.entities.add(entity)
  physicsManager.addBody(entity.physics)

proc update(entity: Entity, eventQueue: EventHandler, ren: RendererPtr, camera: View) =
  if entity.physics.active:
    for direction in entity.controller.chooseDirection(eventQueue):
      entity.physics.move(direction)
  entity.sprite.render(ren, entity.physics.rect.pos, camera)

proc update*(manager: EntityManager, eventQueue: EventHandler) =
  for entity in manager.entities:
    entity.update(eventQueue, manager.renderer, manager.camera)
