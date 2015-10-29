import future, tables
import sdl2
import entity, sprite, physics, controller, common_types

type
  SkillAction* = enum
    Projectile
  Skill* = ref object of RootObj
    proficiency: int
    case action*: SkillAction
    of Projectile:
      speed: int
      entityGenerator*: View -> Entity

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
      speed: 50,
      entityGenerator: proc(view: View): Entity =
        var events: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]]
        events[PhysicsEvent.onCollision] = @[
          proc(body: PhysicsBody, other: PhysicsBody) {.closure.} =
            # explode on nearby characters
            # need to implement collision physics :(
            echo repr(other)
        ]
        return newEntity(
          sprite = newSprite(ren, "sheet.png", true),
          physics = newPhysicsBody(
            rect = newView(view.pos, 50, 50),
            collidable = true,
            events = events
          ),
          controller = NoneController()
        )
    )
  })
