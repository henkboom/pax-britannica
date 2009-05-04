require "dokidoki.closedmodule" [[]]

-- Stuff we need
require "luagl"
require "SDL"
-- Since all of SDL's names are prefixed already, we may as well strip the
-- namespacing.  This lets us write, for example, SDL_QUIT instead of
-- SDL.SDL_QUIT.
import(SDL)

kernel = require "dokidoki.kernel"

function make_uber_scene (coefficient_of_awesomeness)
  time_until_change = 0
  color = {0, 0, 0, 0}

  function handle_event(event)
    if event.type == SDL_QUIT or
       event.type == SDL_KEYDOWN and event.key == SDLK_ESCAPE then
      kernel.abort_main_loop()
    end
  end

  function update (dt)
    time_until_change = time_until_change - dt
    if time_until_change <= 0 then
      time_until_change = time_until_change + 1 / coefficient_of_awesomeness
      color = {math.random(), math.random(), math.random(), 0}
    end
  end

  function draw ()
    glClearColor(unpack(color))
    glClear(GL_COLOR_BUFFER_BIT)
  end

  return {handle_event = handle_event, update = update, draw = draw}
end

kernel.start_main_loop(make_uber_scene(math.acos(-1)))
