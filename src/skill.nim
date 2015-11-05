import future, tables, basic2d
import sdl2
import entity, sprite, physics, screen, controller, common_types

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
proc allSkills*(screen: Screen): Table[string, Skill] =
  return toTable({
    "fireball": Skill(
      action: Projectile,
      entityGenerator: proc(user: Entity): Entity =
        var mouseX, mouseY: cint
        getMouseState(mouseX, mouseY)
        # initial velocity is 20 magnitude in the direction of the mouse from the player
        var initialVelocity = vector2d(
          float(int(mouseX) - user.sprite.screenPos.x),
          float(int(mouseY) - user.sprite.screenPos.y)
        )
        discard initialVelocity.tryNormalize
        initialVelocity *= 10
        # set up collision event
        var events: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]]
        events[PhysicsEvent.onCollision] = @[
          proc(body: PhysicsBody, other: PhysicsBody) {.closure.} =
            # explode on nearby characters
            if other != user.body:
              body.active = false
              body.toDestroy = true
              other.active = false
              other.toDestroy = true
        ]
        # build the actual entity to be returned
        return newEntity(
          sprite = newSprite(
            ren = screen.renderer,
            zIndex = ZIndex.Foreground,
            file = "fireball.png",
            animatedBy = AnimatedBy.Time,
            screenPos = user.sprite.screenPos
          ),
          body = newPhysicsBody(
            rect = newView(user.body.rect.pos, 50, 50),
            collidable = true,
            velocity = initialVelocity,
            events = events
          ),
          controller = NoneController()
        )
    )
  })
