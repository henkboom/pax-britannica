require "dokidoki.module" [[]]

require "SDL"
import(require 'gl')

kernel = require "dokidoki.kernel"
graphics = require "dokidoki.graphics"

function make_texture_scene ()
  local time = 0
  local tex = false

  local function handle_event (event)
    if event.type == 'quit' or
       event.type == 'key' and event.is_down and event.key == glfw.KEY_ESC then
      kernel.abort_main_loop()
    end
  end

  local function update (dt)
    time = time + dt
  end

  local function init_graphics ()
    if not tex then
      local image = string.char(
        255, 0,   0,   255,
        0,   255, 0,   255,
        255, 255, 255, 255,

        0,   0,   255, 255,
        0,   0,   0,   0,
        255, 255, 255, 255,

        0,   0,   0,   255,
        0,   0,   0,   255,
        128, 128, 128, 255)
      -- the image will be padded out to 4x4 for the texture, with the right
      -- and bottom edges extending out
      tex = graphics.texture_from_string(image, 3, 3, 4)
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
    tex:enable()
    glPushMatrix()
      glTranslated(320, 240, 0)
      glColor3d(1, 1, 1)
      glBegin(GL_QUADS)
      glTexCoord2d(0, 1) glVertex2d(-200, -200)
      glTexCoord2d(1, 1) glVertex2d( 200, -200)
      glTexCoord2d(1, 0) glVertex2d( 200,  200)
      glTexCoord2d(0, 0) glVertex2d(-200,  200)
      glEnd()
    glPopMatrix()
    tex:disable()
  end

  return {handle_event = handle_event, update = update, draw = draw}
end

kernel.set_ratio(640/480)
kernel.start_main_loop(make_texture_scene())

