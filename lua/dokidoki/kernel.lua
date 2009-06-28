require "dokidoki.module"
[[ get_width, get_height, get_ratio, set_video_mode, set_ratio,
   start_main_loop, abort_main_loop, get_fps ]]

require "luagl"
require "SDL"
import(SDL)

import(require "dokidoki.base")
graphics = require "dokidoki.graphics"

---- Constants ----------------------------------------------------------------

max_update_time = 1/30 + 0.001
fps = 60
update_time = 1/fps
max_sample_frames = 16

-- Never sleep for less than this amount. This has to be bigger on systems with
-- really lame timers, like Windows.
min_sleep_time = 0.002
-- Allow for this much inaccuracy in SDL_Delay
sleep_allowance = 0.002

---- State Variables ----------------------------------------------------------

running = false
width = 640
height = 480
ratio = width / height

---- Public Interface ---------------------------------------------------------

function get_width () return width end
function get_height () return height end
function get_ratio () return ratio end

function set_video_mode (w, h)
  assert(w > 0)
  assert(h > 0)
  width = w
  height = h
  if running then
    if nil == SDL_SetVideoMode(w, h, 0, SDL_OPENGL) then
      error(SDL_GetError())
    end
    update_viewport()
  end
end

function set_ratio (r)
  assert(r > 0)
  ratio = r
  if running then update_viewport() end
end

function start_main_loop (scene)
  -- SDL_Quit() needs to be called even if there is an error, since otherwise
  -- it may not return the screen to its original resolution.
  local success, message = pcall(function ()
    if SDL_Init(bit_or(SDL_INIT_VIDEO, SDL_INIT_AUDIO)) ~= 0 then
      error(SDL_GetError())
    end
    running = true
    
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
    set_video_mode(width, height)

    main_loop(scene)
  end)

  SDL_Quit()

  if not success then error(message, 0) end
end

function abort_main_loop ()
  running = false
end

frame_times = {}

function get_fps ()
  if #frame_times >= 2 then
    return (#frame_times - 1) / (frame_times[#frame_times] - frame_times[1])
  else
    return 1
  end
end

---- Utility Functions --------------------------------------------------------

function main_loop (scene)
  local last_update_time = get_current_time()

  while true do
    ---- handle events
    do
      local event = SDL_Event_new()
      while SDL_PollEvent(event) ~= 0 do
        if event.type == SDL_VIDEORESIZE then
          set_video_mode(event.resize.w, event.resize.h)
        end

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
      -- Since we're probably going to be waiting at this point, may as well
      -- push along the garbage collector
      -- TODO: figure out whether or not this is actually a good idea
      --collectgarbage("step")
      -- wait until it's time to update at least once
      sleep_until(last_update_time + update_time)
      local current_time = get_current_time()
      log_frame_time(current_time)
      -- if we would have to update for more than max_update_time, skip forward
      local total_update_time = current_time - last_update_time
      if max_update_time < total_update_time then
        warn("underrun of %ims",
              math.ceil(1000 * (total_update_time - max_update_time)))
        last_update_time = current_time - max_update_time
      end
      -- update the right number of times
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
  -- loop, making us do iterations of 0 updates, which is stupid because it
  -- will render the same thing as last time. Making this condition slightly
  -- stricter fixes it.
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

function log_frame_time(time)
  table.insert(frame_times, time)
  if #frame_times > max_sample_frames then
    table.remove(frame_times, 1)
  end
end

function warn(str, ...)
  print(string.format("warning: " .. str, ...))
end

return get_module_exports()
