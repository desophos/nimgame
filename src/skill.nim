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
        # initial velocity is 10 magnitude in the direction of the mouse from the player
        var mouseX, mouseY: cint
        getMouseState(mouseX, mouseY)
        var initialVelocity = vector2d(
          float(int(mouseX) - (user.sprite.screenPos.x + int(user.sprite.getSize.w / 2))),
          float(int(mouseY) - (user.sprite.screenPos.y + int(user.sprite.getSize.h / 2)))
        )
        discard initialVelocity.tryNormalize
        initialVelocity *= 10
        # set up collision event
        var events: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]]
        events[PhysicsEvent.onCollision] = @[
          proc(body: PhysicsBody, other: PhysicsBody) {.closure.} =
            # explode on nearby entities (yet to be implemented)
            # for now just destroy collided entity
            if other != user.body:
              body.active = false
              body.toDestroy = true
              other.active = false
              other.toDestroy = true
        ]
        # build the actual entity to be returned
        let
          sprite = newSprite(
            ren = screen.renderer,
            zIndex = ZIndex.Foreground,
            tex = screen.textures["fireball.png"],
            animatedBy = AnimatedBy.Time,
            screenPos = user.sprite.screenPos,
            states = loadSpriteDataFromJsonFile("fireball")
          )
          body = newPhysicsBody(
            rect = newView(user.body.rect.pos, sprite.getSize()),
            collidable = true,
            velocity = initialVelocity,
            events = events
          )
        return newEntity(
          sprite = sprite,
          body = body,
          controller = NoneController()
        )
    )
  })
