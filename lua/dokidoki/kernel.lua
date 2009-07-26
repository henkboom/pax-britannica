require "dokidoki.module"
[[ get_width, get_height, get_ratio, set_video_mode, set_ratio,
   start_main_loop, abort_main_loop, get_fps ]]

require "glfw"

import(require "gl")

import(require "dokidoki.base")

---- Constants ----------------------------------------------------------------

max_update_time = 1/30 + 0.001
fps = 60
update_time = 1/fps
max_sample_frames = 16

-- Never sleep for less than this amount. This has to be bigger on systems with
-- really lame timers, like Windows.
min_sleep_time = 0.002
-- Allow for this much inaccuracy in the OS sleep operation
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
  print ('setting', w, h)
  assert(w > 0)
  assert(h > 0)
  width = w
  height = h
  if running then
    glfw.SetWindowSize(w, h)
    update_viewport()
  end
end

function set_ratio (r)
  assert(r > 0)
  ratio = r
  if running then update_viewport() end
end

function start_main_loop (scene)
  -- glfw.Terminate() needs to be called even if there is an error, since
  -- otherwise it may not return the screen to its original resolution.
  local success, message = pcall(function ()
    if glfw.Init() == GL_FALSE then
      error("glfw initialization failed")
    end

    running = true
    
    glfw.OpenWindow(width, height, 8, 8, 8, 8, 16, 0, glfw.WINDOW)
    set_video_mode(width, height)

    main_loop(scene)
  end)

  glfw.Terminate()

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
    for i, event in ipairs(events) do
      if event.type == 'resize' then
        set_video_mode(event.width, event.height)
      end
      scene.handle_event(event)
      if not running then return end
    end
    while #events ~= 0 do events[#events] = nil end

    ---- update
    do
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
