require "dokidoki.module" [[]]

require "luagl"
require "SDL"
import(SDL)

kernel = require "dokidoki.kernel"
graphics = require "dokidoki.graphics"

function make_sprite_scene ()
  local time = 0
  local sprite = false

  local function handle_event (event)
    if event.type == SDL_QUIT or
       event.type == SDL_KEYDOWN and event.key == SDLK_ESCAPE then
      kernel.abort_main_loop()
    end
  end

  local function update (dt)
    time = time + dt
  end

  local function init_graphics ()
    if not sprite then
      sprite = graphics.sprite_from_image("rgba.png", nil, "centered")
    end
    glClearColor(0.3 + math.cos(time/2) * 0.1, 0, 0.75, 0)
    glClear(GL_COLOR_BUFFER_BIT)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glOrtho(0, 640, 0, 480, 1, -1)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()

    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  end

  local function draw ()
    init_graphics()
    glPushMatrix()
      glTranslated(320, 240, 0)
      glRotated(math.sin(time * math.pi) * 5, 0, 0, 1)
      glColor3d(1, 1, 1)
      sprite:draw()
    glPopMatrix()
  end

  return {handle_event = handle_event, update = update, draw = draw}
end

kernel.set_ratio(640/480)
kernel.start_main_loop(make_sprite_scene(math.acos(-1)))

