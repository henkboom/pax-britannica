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

  local actors = {}

  local paused = false

  local key_states = {}
  local old_key_states = {}

  ---- Actor Interface --------------------------------------------------------

  -- actors have access to these functions

  local function add_actor (actor)
    actors[#actors + 1] = actor
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
    local results = {}
    for _, actor in ipairs(actors) do
      if actor.tags then
        for i, t in ipairs(actor.tags) do
          if t == tag then
            table.insert(results, actor)
            break
          end
        end
      end
    end
    return results
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
        for _, a in ipairs(actors) do
          if not a.is_dead and a[update_type] then a[update_type]() end
        end
      end

      actors = ifilter(function (a) return not a.is_dead end, actors)
      
      old_key_states = key_states
      key_states = copy(old_key_states)
    end
  end

  ---- Drawing ----------------------------------------------------------------

  local function draw ()
    for _, draw_type in ipairs(draw_methods) do
      for _, a in ipairs(actors) do
        assert(not a.is_dead)
        if a[draw_type] then
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
  end

  ---- Scene Construction -----------------------------------------------------

  -- scene interface for main loop
  return { handle_event = handle_event, update = update, draw = draw }
end

return get_module_exports()
