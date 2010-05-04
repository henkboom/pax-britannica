--- dokidoki.kernel
--- ===============
---
--- `dokidoki.kernel` handles initialization and the core loop.  It takes an
--- abstract scene object which provides implementations of updating, drawing,
--- and event-handling functions.
---
--- A scene must implement:
---
--- - `scene.update()`
--- - `scene.draw()`
--- - `scene.handle_event(event)`
---
--- where none of the callbacks has a return value.
---
--- For the `handle_event(event)` callback, `event` has one of the following
--- forms:
---
--- - `{type = 'close'}`
--- - `{type = 'resize', width = ?, height = ?}`
--- - `{type = 'key', key = ?, is_down = ?}` (`key` is a GLFW key constant)

--- Implementation
--- --------------

require "dokidoki.module"
[[ set_fps, set_max_frameskip, get_width, get_height, get_ratio,
   set_fullscreen, set_video_mode, set_ratio, start_main_loop, abort_main_loop,
   switch_scene, get_framerate ]]

require "glfw"

local mixer = require "mixer"
local log = require "log"

import(require "gl")

import(require "dokidoki.base")

---- Constants ----------------------------------------------------------------

max_frameskip = 6
fps = 60
max_sample_frames = 16

-- Never sleep for less than this amount. This has to be bigger on systems with
-- really lame timers, like Windows.
min_sleep_time = 0.002
-- Allow for this much inaccuracy in the OS sleep operation
sleep_allowance = 0.002

---- State Variables ----------------------------------------------------------

running = false
use_fullscreen = false

width = 640
height = 480
ratio = width / height

frame_times = {}

next_scene = nil

---- Public Interface ---------------------------------------------------------

--- ### `set_max_frameskip(max_frameskip)`
--- Sets the maximum number of updates to run before forcing a draw.
---
--- If more than this number of updates are queued to happen before a redraw,
--- the rest will be discared.
function set_max_frameskip(new_max_frameskip)
  assert(type(new_max_frameskip == 'number') and new_max_frameskip >= 1)
  max_frameskip = new_max_frameskip
end

--- ### `set_fps(fps)`
--- Sets the target frames-per-second.
function set_fps(new_fps)
  assert(type(new_fps == 'number') and fps > 0)
  fps = new_fps
end

--- ### `get_width()`
--- Returns the current total window width in pixels. This includes borders
--- when the ratio doesn't match the window size.
function get_width () return width end

--- ### `get_height()`
--- Returns the current total window height in pixels. This includes borders
--- when the ratio doesn't match the window size.
function get_height () return height end

--- ### `set_fullscreen(fullscreen)`
--- Sets whether or not a fullscreen window should be opened. This must be
--- called before entering the main loop.
---
--- The default is to open in a window.
function set_fullscreen(fullscreen)
  assert(not running, 'set_fullscreen must be called before the main loop')
  use_fullscreen = fullscreen
end

--- ### `set_video_mode(width, height)`
--- Sets the desired width/height of the window in pixels.
---
--- If the main loop hasn't yet been started, it will immediately change
--- the window size (or change video modes in fullscreen). If called before
--- entering the main loop, this sets the initial video mode, but has no
--- immediate effect.
---
--- This does not set the desired ratio, so unless you set that as well you may
--- end up with borders.
function set_video_mode (w, h)
  assert(w > 0)
  assert(h > 0)
  width = w
  height = h
  if running then
    glfw.SetWindowSize(w, h)
    update_viewport()
  end
end

--- ### `get_ratio()`
--- Returns the screen ratio used within the window for the active area. See
--- also `set_ratio()`.
function get_ratio () return ratio end

--- ### `set_ratio(ratio)`
--- Sets the desired screen ratio.
---
--- If the window size doesn't match this ratio, then the ratio is used to set
--- the opengl viewport shape within the window.
---
--- This must be set manually if a ratio other than 4/3 is wanted, since calls
--- to `set_video_mode()` have no effect on it.
function set_ratio (r)
  assert(r > 0)
  ratio = r
  if running then update_viewport() end
end

--- ### `start_main_loop(scene)`
--- Initializes stuff and begins the main loop. `scene` is used as described in
--- the introduction above.
function start_main_loop (scene)
  -- glfw.Terminate() needs to be called even if there is an error, since
  -- otherwise it may not return the screen to its original resolution.
  local success, message = xpcall(function ()
    log.log_message "initializing mixer. . ."
    assert(mixer.init())
    log.log_message "initializing glfw. . ."
    if glfw.Init() == GL_FALSE then
      error("glfw initialization failed")
    end

    running = true
    
    log.log_message "setting video mode. . ."
    glfw.OpenWindow(width, height, 8, 8, 8, 8, 24, 0,
                    use_fullscreen and glfw.FULLSCREEN or glfw.WINDOW)
    set_video_mode(width, height)

    log.log_message "starting main loop"

    next_scene = scene
    while next_scene do
      scene = next_scene
      next_scene = nil
      main_loop(scene)
      if next_scene then
        running = true
      end
    end
  end, get_stack_trace)

  log.log_message "shutting down"
  glfw.Terminate()

  if not success then error(message, 0) end
end

--- ### `get_framerate()`
--- Returns a running average of the number of `draw()` calls per second.
--- Since multiple updates can happen per draw, this isn't the same as the
--- number of updates per second, which should usually stay constant.
function get_framerate ()
  if #frame_times >= 2 then
    return (#frame_times - 1) / (frame_times[#frame_times] - frame_times[1])
  else
    return 1
  end
end

--- ### `abort_main_loop()`
--- Sets a flag to terminate the main loop at the next opportunity.
---
--- This function should be called from one of the scene callbacks; the loop
--- will be aborted when the callback returns.
function abort_main_loop ()
  assert(running)
  running = false
end

--- ### `switch_scene(scene)`
--- Queues up a scene to switch to.
---
--- This function should be called from one of the scene callbacks; the scenes
--- will be switched when the callback returns.
function switch_scene(scene)
  assert(running)
  next_scene = scene
  running = false
end

---- Utility Functions --------------------------------------------------------

function get_stack_trace(err)
  return debug.traceback(err, 2)
end

function set_callback(name, callback)
  local set = glfw['Set' .. name .. 'Callback']
  assert(set, 'invalid callback name given')
  local varname = '__kernel_callback_' .. name
  
  rawset(_G, varname, callback)

  if(callback) then
    set(varname)
  else
    set()
  end
end

function main_loop (scene)
  local last_update_time = get_current_time()

  -- filled in callbacks whenever glfw.SwapBuffers is called
  local events = {}

  set_callback('WindowClose', function ()
    table.insert(events, {type = 'quit'})
    return glfw.FALSE
  end)

  set_callback('WindowSize', function (width, height)
    table.insert(events,
      {type = 'resize', width = width, height = height})
  end)

  set_callback('Key', function (key, action)
    table.insert(events,
      {type = 'key', key = key, is_down = action == glfw.PRESS})
  end)

  while true do
    ---- handle events
    local new_width, new_height
    for i, event in ipairs(events) do
      if event.type == 'resize' then
        new_width = event.width
        new_height = event.height
      end
      scene.handle_event(event)
      if not running then return end
    end
    if new_width and (new_width ~= width or new_height ~= height) then
      set_video_mode(new_width, new_height)
    end

    while #events ~= 0 do events[#events] = nil end

    ---- update
    do
      -- wait until it's time to update at least once
      local update_time = 1/fps
      sleep_until(last_update_time + update_time)
      local current_time = get_current_time()
      log_frame_time(current_time)
      -- if we would have to update for more than max_update_time, skip forward
      local max_update_time = max_frameskip / fps + 0.001
      local total_update_time = current_time - last_update_time
      if max_update_time < total_update_time then
        log.log_message(
          "warning: underrun of " ..
          math.ceil(1000 * (total_update_time - max_update_time)) ..
          "ms")
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

    local err = glGetError()
    if err ~= 0 then error('OpenGL error ' .. err) end

    if not running then return end
    glfw.SwapBuffers()
  end
end

function get_current_time ()
  return glfw.GetTime()
end

function sleep_until (time)
  local time_to_sleep = time - get_current_time() - sleep_allowance
  if time_to_sleep > min_sleep_time then
    glfw.Sleep(time_to_sleep)
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
    local inner_width = math.floor(height * ratio + 0.5)
    glViewport(math.floor((width - inner_width) / 2), 0, inner_width, height)
  else
    -- letterbox
    local inner_height = math.floor(width / ratio + 0.5)
    glViewport(0, math.floor((height - inner_height) / 2), width, inner_height)
  end
end

function log_frame_time(time)
  table.insert(frame_times, time)
  if #frame_times > max_sample_frames then
    table.remove(frame_times, 1)
  end
end

return get_module_exports()
