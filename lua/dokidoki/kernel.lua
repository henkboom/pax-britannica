require "dokidoki.closedmodule"
[[ abort_main_loop, start_main_loop ]]

require "luagl"
require "SDL"
import(SDL)

max_update_time = 0.1
fps = 60
update_time = 1/fps

-- never sleep for less than this amount
min_sleep_time = 0.01
-- allow for this much inaccuracy in SDL_Delay
sleep_allowance = 0.002

quit = false

function abort_main_loop()
  quit = true
end

function start_main_loop (scene)
  SDL_Init(SDL_INIT_VIDEO)
  
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
  set_video_mode(640, 480)
  
  main_loop(scene)

  SDL_Quit()
end

function main_loop(scene)
  local last_update_time = get_current_time()

  while true do
    ---- handle events
    do
      local event = SDL_Event_new()
      while SDL_PollEvent(event) ~= 0 do
        local translated = translate_event(event)
        if translated then scene.handle_event(translated) end

        if quit then
          SDL_Event_delete(event)
          return
        end
      end
      SDL_Event_delete(event)
    end

    ---- update
    do
      -- wait until it's time to update at least once
      sleep_until(last_update_time + update_time)
      local current_time = get_current_time()
      -- if we would have to update for more than max_update_time, skip forward
      last_update_time = math.max(last_update_time,
                                  current_time - max_update_time)
      while last_update_time + update_time <= current_time do
        last_update_time = last_update_time + update_time
        scene.update(update_time)
        if quit then return end
      end
    end

    ---- draw
    scene.draw()
    if quit then return end
    SDL_GL_SwapBuffers()
  end
end

function translate_event(event)
  if event.type == SDL_QUIT then
    return {type = event.type}
  elseif event.type == SDL_KEYDOWN or
     event.type == SDL_KEYUP then 
     return {type = event.type, key = event.key.keysym.sym, mod = event.key}
  else
    return false
  end
end

function get_current_time ()
  return SDL_GetTicks() / 1000
end

function sleep_until (time)
  local time_to_sleep = time - get_current_time() - sleep_allowance
  if time_to_sleep > min_sleep_time then
    SDL_Delay(time_to_sleep * 1000)
  end
  -- Floating point inaccuracy can cause this to pass here but not in the main
  -- loop, making us do iterations of 0 updates, which is stupid. Making this
  -- condition slightly stricter fixes it.
  while time + 0.0001 > get_current_time() do end
end

function set_video_mode (w, h)
  if nil == SDL_SetVideoMode(w, h, 0, SDL_OPENGL) then
    error("failed setting video mode")
  end
end

return get_module_exports()
