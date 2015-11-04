import future, basic2d
import common_types

type
  PhysicsEvent* = enum
    onCollision
  PhysicsBody* = ref object of RootObj
    rect*: View
    velocity*: TVector2d
    friction*: float
    active*: bool
    collidable: bool
    events: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]]
  PhysicsManager* = ref object of RootObj
    bodies: seq[PhysicsBody]
    bounds*: View
    friction*: float

proc newPhysicsManager*(
  bounds: View,
  friction: float = 0.9
): PhysicsManager =
  return PhysicsManager(
    bodies: @[],
    bounds: bounds,
    friction: friction
  )

proc initEvents(): array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]] =
  result[onCollision] = @[]

proc newPhysicsBody*(
  rect: View,
  collidable: bool,
  active: bool = true,
  friction: float = 1.0,
  velocity: Vector2d = vector2d(0, 0),
  events: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]] = initEvents()
): PhysicsBody =
  return PhysicsBody(
    rect: rect,
    velocity: velocity,
    friction: friction,
    collidable: collidable,
    active: active,
    events: events
  )

proc addBody*(manager: PhysicsManager, body: PhysicsBody) =
  manager.bodies.add(body)

proc `pos=`*(body: PhysicsBody, pos: Position) =
  body.rect.pos = pos

proc `pos=`*(body: PhysicsBody, x, y: int) =
  body.rect.pos = Position(x: x, y: y)

proc applyForceScalar*(body: PhysicsBody, force: float) =
  body.velocity *= force

proc applyForceVector*(body: PhysicsBody, force: Vector2d) =
  body.velocity += force

proc constrainTo*(body: PhysicsBody, constrain: View) =
  var constrainedView = body.rect
  constrainedView.constrainTo(constrain)
  body.rect.pos = constrainedView.pos

proc move*(body: PhysicsBody, dir: Direction, accel: float = 5) =
  case dir
  of Direction.left:
    body.velocity -= XAXIS * accel
  of Direction.up:
    body.velocity -= YAXIS * accel
  of Direction.down:
    body.velocity += YAXIS * accel
  of Direction.right:
    body.velocity += XAXIS * accel
  else:
    discard

proc step*(manager: PhysicsManager) =
  for i in 0 ..< manager.bodies.len:
    var body = manager.bodies[i]
    if body.active:
      # ultra simple collision checker
      # only checks single collision
      # doesn't remove events
      if body.collidable:
        for j in 0 ..< manager.bodies.len:
          var other = manager.bodies[j]
          if other.collidable and
             addr(other) != addr(body) and
             other.rect.intersects(body.rect):
            for event in body.events[onCollision]:
              if not body.collidable or
                 not other.collidable:
                break
              event(body, other)
