local key_states = {}
local old_key_states = {}

function key_pressed(key)
  return key_states[key] and not old_key_states
end

function key_held(key)
  return key_states[key]
end

function key_released(key)
  return not key_states[key] and old_key_states[key]
end

game.actors.new_generic('key_monitor', function ()
  update_setup = function ()
    old_key_states = copy(key_states)
  end
  handle_event = function (event)
    if event.type == 'key' then
      key_states[event.key] = event.is_down or nil
    end
  end
end)
