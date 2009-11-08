require "dokidoki.module" [[]]
require "glfw"
import(require "gl")

kernel = require "dokidoki.kernel"

function make_uber_scene (coefficient_of_awesomeness)
  local time_until_change = 0
  local color = {0, 0, 0, 0}

  local function handle_event (event)
    if event.type == 'quit' or
       event.type == 'key' and event.is_down and event.key == glfw.KEY_ESC then
      kernel.abort_main_loop()
    end
  end

  local function update (dt)
    time_until_change = time_until_change - dt
    if time_until_change <= 0 then
      time_until_change = time_until_change + 1 / coefficient_of_awesomeness
      color = {math.random(), math.random(), math.random(), 0}
    end
  end

  local function draw ()
    glClearColor(unpack(color))
    glClear(GL_COLOR_BUFFER_BIT)
  end

  return {handle_event = handle_event, update = update, draw = draw}
end

kernel.start_main_loop(make_uber_scene(math.acos(-1)))
