import tables, future

type
  PhysicsEvent* = enum
    onCollision
  PhysicsBody* = object of RootObj
    events: Table[PhysicsEvent, seq[PhysicsBody -> void]]

proc update(body: PhysicsBody) =
  for event in body.events[onCollision]:
    event(body)
