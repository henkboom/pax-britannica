require "dokidoki.module" [[]]

require 'glfw'
import(require 'gl')

kernel = require "dokidoki.kernel"
graphics = require "dokidoki.graphics"

font_filename = "/usr/share/fonts/ttf-bitstream-vera/Vera.ttf"
font_size = 20

function make_sprite_scene ()
  local font_map = false
  local tex = false

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
      font_map = graphics.make_font_map(font_filename, font_size)
      tex = font_map[" "].tex
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
      glColor3d(1, 1, 1)
      graphics.draw_text(font_map, "Yay it works!")
    glPopMatrix()
  end

  return {handle_event = handle_event, update = update, draw = draw}
end

kernel.set_ratio(800/600)
kernel.set_video_mode(800, 600)
kernel.start_main_loop(make_sprite_scene(math.acos(-1)))

