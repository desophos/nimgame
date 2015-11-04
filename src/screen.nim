import algorithm, future
import sdl2
import sprite, physics, common_types

type Screen* = ref object of RootObj
  camera: View
  window: WindowPtr
  renderer*: RendererPtr
  sprites: seq[Sprite]

proc newScreen*(
  cameraSize: Size,
  windowName: string,
  windowPos: Position
): Screen =
  let
    camera = newView(0, 0, cameraSize)
    window = createWindow(windowName, windowPos.x.cint, windowPos.y.cint, camera.size.w.cint, camera.size.h.cint, SDL_WINDOW_SHOWN)
    renderer = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)
  return Screen(
    camera: camera,
    window: window,
    renderer: renderer,
    sprites: @[]
  )

proc destroy*(screen: Screen) =
  for i in 0 ..< screen.sprites.len:
    screen.sprites[i].destroy
  screen.renderer.destroy
  screen.window.destroy

proc addSprite*(screen: Screen, sprite: Sprite) =
  screen.sprites.add(sprite)

proc render*(screen: Screen) =
  screen.sprites.sort((sprite1, sprite2) => (sprite1.zIndex > sprite2.zIndex))
  screen.renderer.setDrawColor(255, 255, 255, 255)
  screen.renderer.clear
  for sprite in screen.sprites:
    # if sprite intersects visible view (window)
    if newView(0, 0, screen.camera.size).intersects(newView(sprite.screenPos, sprite.getSize())):
      sprite.render(screen.renderer)
  screen.renderer.present

proc track*(screen: Screen, constrain: View, body: PhysicsBody, trackDistance: int = 0, trackSpeedMult: float = 1) =
  let initialCameraPos = screen.camera.pos

  if not (screen.camera.smaller(trackDistance).contains(body.rect)):
    screen.camera.pos = screen.camera.pos + (body.rect.center - screen.camera.center) * trackSpeedMult
  screen.camera.constrainTo(constrain)

  for sprite in screen.sprites:
    sprite.screenPos += initialCameraPos - screen.camera.pos
