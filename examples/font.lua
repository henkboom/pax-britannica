require "dokidoki.module" [[]]

require 'glfw'
import(require 'gl')

kernel = require "dokidoki.kernel"
graphics = require "dokidoki.graphics"
default_font = require "dokidoki.default_font"

function make_sprite_scene ()
  local font_map = false

  local function handle_event (event)
    if event.type == 'quit' or
       event.type == 'key' and event.is_down and event.key == glfw.KEY_ESC then
      kernel.abort_main_loop()
    end
  end

  local function update (dt)
  end

  local function init_graphics ()
    if not font_map then
      font_map = default_font.load()
    end
    glClearColor(0, 0, 0, 0)
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
      glScaled(2, 2, 2)
      glColor3d(1, 1, 1)
      local fps = math.floor(kernel.get_framerate()+0.5)
      graphics.draw_text(font_map,
        "Yay it works!\n\n" .. fps .. " fps")
    glPopMatrix()
  end

  return {handle_event = handle_event, update = update, draw = draw}
end

kernel.set_ratio(640/480)
kernel.set_video_mode(640, 480)
kernel.start_main_loop(make_sprite_scene(math.acos(-1)))

