require "dokidoki.closedmodule"
[[ get_width, get_height, get_ratio, set_video_mode, set_ratio,
   start_main_loop, abort_main_loop ]]

require "luagl"
require "SDL"
import(SDL)

---- Constants ----------------------------------------------------------------

max_update_time = 0.1
fps = 60
update_time = 1/fps

-- never sleep for less than this amount
min_sleep_time = 0.01
-- allow for this much inaccuracy in SDL_Delay
sleep_allowance = 0.002

---- State Variables ----------------------------------------------------------

running = false
width = 640
height = 480
ratio = width / height

---- Public Interface ---------------------------------------------------------

function get_width() return width end
function get_height() return height end
function get_ratio() return ratio end

function set_video_mode (w, h)
  assert(w > 0)
  assert(h > 0)
  width = w
  height = h
  if nil == SDL_SetVideoMode(w, h, 0, SDL_OPENGL) then
    error("failed setting video mode")
  end
  update_viewport()
end

function set_ratio(r)
  assert(r > 0)
  ratio = r
  if running then update_viewport() end
end

function start_main_loop (scene)
  SDL_Init(SDL_INIT_VIDEO)
  running = true
  
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
  set_video_mode(width, height)

  main_loop(scene)

  SDL_Quit()
end

function abort_main_loop ()
  running = false
end

---- Utility Functions --------------------------------------------------------

function main_loop (scene)
  local last_update_time = get_current_time()

  while true do
    ---- handle events
    do
      local event = SDL_Event_new()
      while SDL_PollEvent(event) ~= 0 do
        local translated = translate_event(event)
        if translated then scene.handle_event(translated) end

        if not running then
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
        if not running then return end
      end
    end

    ---- draw
    scene.draw()
    if not running then return end
    SDL_GL_SwapBuffers()
  end
end

function translate_event (event)
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

function update_viewport ()
  if width / height > ratio then
    -- pillarbox
    inner_width = math.floor(height * ratio + 0.5)
    glViewport(math.floor((width - inner_width) / 2), 0, inner_width, height)
  else
    -- letterbox
    inner_height = math.floor(width / ratio + 0.5)
    glViewport(0, math.floor((height - inner_height) / 2), width, inner_height)
  end
end

return get_module_exports()
