require "dokidoki.module" [[make_actor_scene]]

require 'glfw'
import(require 'gl')
import(require 'glu')

local kernel = require "dokidoki.kernel"
local graphics = require "dokidoki.graphics"
local v2 = require "dokidoki.v2"
import(require "dokidoki.base")

---- Core Game Behaviour ------------------------------------------------------

function make_actor_scene (update_methods, draw_methods, init)
  local actor_interface

  local actors_by_tag = {}
  local actors_by_method
  local actor_timings = {}

  local paused = false

  local key_states = {}
  local old_key_states = {}

  ---- Actor Interface --------------------------------------------------------

  -- actors have access to these functions

  local function add_actor (actor)
    for method, t in pairs(actors_by_method) do
      if actor[method] then t[#t+1] = actor end
    end
    for _, tag in ipairs(actor.tags or {}) do
      actors_by_tag[tag] = actors_by_tag[tag] or {}
      table.insert(actors_by_tag[tag], actor)
    end
    actor_timings[actor] = 0
  end

  local function is_key_down (key)
    return not not key_states[key]
  end

  local function was_key_pressed (key)
    return key_states[key] and not old_key_states[key]
  end

  local function get_player_controls ()
    return
    {
      direction = wasd_to_direction(
        is_key_down(glfw.KEY_UP), is_key_down(glfw.KEY_LEFT),
        is_key_down(glfw.KEY_DOWN), is_key_down(glfw.KEY_RIGHT))
    }
  end

  local function get_actors_by_tag (tag)
    return actors_by_tag[tag] or {}
  end

  local function get_actor_timing_information ()
    return actor_timings
  end

  actor_interface =
  {
    add_actor = add_actor,
    is_key_down = is_key_down,
    was_key_pressed = was_key_pressed,
    get_player_controls = get_player_controls,
    get_actors_by_tag = get_actors_by_tag,
  }

  ---- Event Handling ---------------------------------------------------------

  local function handle_event (event)
    -- Quit
    if event.type == 'quit' or
       event.type == 'key' and event.is_down and event.key == glfw.KEY_ESC then
      kernel.abort_main_loop()
      for k, v in pairs(actor_timings) do
        print(v, k, k.pos)
      end
    -- Other key events
    elseif event.type == 'key' and event.is_down and
           event.key == ('P'):byte() then
      paused = not paused
    elseif event.type == 'key' then
      key_states[event.key] = event.is_down or nil
    end
  end

  ---- Game Updates -----------------------------------------------------------

  local function update (dt)
    if init then
      init(actor_interface)
      init = false
    end

    if not paused then
      -- update all actors
      for _, update_type in ipairs(update_methods) do
        for _, a in ipairs(actors_by_method[update_type]) do
          local time = glfw.GetTime()
          if not a.is_dead then a[update_type]() end
          actor_timings[a] = actor_timings[a] + glfw.GetTime() - time
        end
      end

      for k, _ in pairs(actors_by_method) do
        actors_by_method[k] =
          ifilter(function (a) return not a.is_dead end, actors_by_method[k])
      end
      for k, _ in pairs(actors_by_tag) do
        actors_by_tag[k] =
          ifilter(function (a) return not a.is_dead end, actors_by_tag[k])
      end
      for k, _ in pairs(actor_timings) do 
        if k.is_dead then actor_timings[k] = nil end
      end
        
      old_key_states = key_states
      key_states = copy(old_key_states)
    end
  end

  ---- Drawing ----------------------------------------------------------------

  local function draw ()
    for _, draw_type in ipairs(draw_methods) do
      for _, a in ipairs(actors_by_method[draw_type]) do
        assert(not a.is_dead)
        local do_transform = a.pos
        if do_transform then
          glPushMatrix()
          glTranslated(a.pos.x, a.pos.y, 0)
        end
        a[draw_type]()
        if do_transform then
          glPopMatrix()
        end
      end
    end
  end

  ---- Init -------------------------------------------------------------------

  actors_by_method = {}
  for _, method in ipairs(iconcat(update_methods, draw_methods)) do
    actors_by_method[method] = {}
  end
  -- scene interface for main loop
  return { handle_event = handle_event, update = update, draw = draw }
end

return get_module_exports()
