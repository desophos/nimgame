import future, tables, basic2d
import sdl2
import entity, sprite, physics, controller, common_types

type
  SkillAction* = enum
    Projectile
  Skill* = ref object of RootObj
    proficiency: int
    case action*: SkillAction
    of Projectile:
      entityGenerator*: Entity -> Entity

# will probably eventually have to refactor this
# to support different renderers
# this is ridiculously complex, i need to simplify it
# the fireball skill has an entity generator,
# which can be called with a View to create an Entity
# based on the fireball entity "template" defined here
proc allSkills*(ren: RendererPtr): Table[string, Skill] =
  return toTable({
    "fireball": Skill(
      action: Projectile,
      entityGenerator: proc(user: Entity): Entity =
        var initialVelocity = user.getBody.velocity
        discard initialVelocity.tryNormalize
        initialVelocity *= 20
        var events: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]]
        events[PhysicsEvent.onCollision] = @[
          proc(body: PhysicsBody, other: PhysicsBody) {.closure.} =
            # explode on nearby characters
            if other != user.getBody():
              body.active = false
        ]
        return newEntity(
          sprite = newSprite(ren, "fireball.png", true),
          physics = newPhysicsBody(
            rect = newView(user.getBody.rect.pos, 50, 50),
            collidable = true,
            velocity = initialVelocity,
            events = events
          ),
          controller = NoneController()
        )
    )
  })
