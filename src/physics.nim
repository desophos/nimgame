import future, basic2d
import common_types

type
  PhysicsEvent* = enum
    onCollision
  PhysicsBody* = ref object of RootObj
    rect*: View
    velocity: TVector2d
    active*: bool
    collidable: bool
    events: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]]
  PhysicsManager* = ref object of RootObj
    bodies: seq[PhysicsBody]
    bounds: View
    friction: float

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
  events: array[PhysicsEvent, seq[(PhysicsBody, PhysicsBody) -> void]] = initEvents()
): PhysicsBody =
  return PhysicsBody(
    rect: rect,
    velocity: vector2d(0, 0),
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
  body.rect.pos = body.rect.pos + initPosition(body.velocity)

proc update*(manager: PhysicsManager) =
  # ultra simple collision checker
  # only checks single collision
  # doesn't remove events
  for i in 0 ..< manager.bodies.len:
    if manager.bodies[i].active:
      #echo repr(manager.bodies[i])
      manager.bodies[i].velocity.scale(manager.friction)
      manager.bodies[i].constrainTo(manager.bounds)
      if manager.bodies[i].collidable:
        for j in 0 ..< manager.bodies.len:
          if manager.bodies[j].collidable and
             addr(manager.bodies[j]) != addr(manager.bodies[i]) and
             manager.bodies[j].rect.intersects(manager.bodies[i].rect):
            for event in manager.bodies[i].events[onCollision]:
              if not manager.bodies[i].collidable or
                 not manager.bodies[j].collidable:
                break
              event(manager.bodies[i], manager.bodies[j])

# this proc needs a real home :( please adopt
proc track*(view: var View, constrain: View, body: PhysicsBody, trackDistance: int = 0, trackSpeedMult: float = 1) =
  if not (view.smaller(trackDistance).contains(body.rect)):
    view.pos = view.pos + (body.rect.center - view.center) * trackSpeedMult
  view.constrainTo(constrain)
