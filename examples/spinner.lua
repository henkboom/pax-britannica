require "dokidoki.module" [[]]

require "luagl"
require "SDL"
import(SDL)

kernel = require "dokidoki.kernel"
graphics = require "dokidoki.graphics"

function make_spinner_scene ()
  local rotation = 0

  local function handle_event (event)
    if event.type == SDL_QUIT or
       event.type == SDL_KEYDOWN and event.key == SDLK_ESCAPE then
      kernel.abort_main_loop()
    end
  end

  local function update (dt)
    rotation = rotation + dt * 45
  end

  local function init_graphics ()
    glClearColor(0, 0, 0.25, 0)
    glClear(GL_COLOR_BUFFER_BIT)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glOrtho(0, 300, 0, 300, 1, -1)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
  end

  local function draw ()
    init_graphics()
    glPushMatrix()
      glTranslated(150, 150, 0)
      glRotated(rotation, 0, 0, 1)
      glScaled(100, 100, 100)
      glColor3d(0.5, 0.25, 1)
      glBegin(GL_QUADS)
        glVertex2d(-1, -1)
        glVertex2d( 1, -1)
        glVertex2d( 1,  1)
        glVertex2d(-1,  1)
      glEnd()
    glPopMatrix()
  end

  return {handle_event = handle_event, update = update, draw = draw}
end

kernel.set_video_mode(300, 300)
kernel.set_ratio(1)
kernel.start_main_loop(make_spinner_scene(math.acos(-1)))

