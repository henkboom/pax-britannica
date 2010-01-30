require 'glfw'

local old_states = {}
local states = {}

local player_keys = {
  string.byte('1'),
  string.byte('2'),
  string.byte('3'),
  string.byte('4')
}

local player_joysticks = {
  glfw.JOYSTICK_1,
  glfw.JOYSTICK_2,
  glfw.JOYSTICK_3,
  glfw.JOYSTICK_4
}

function held(i)
  assert(1 <= i and i <= 4)
  return states[i]
end

function pressed(i)
  assert(1 <= i and i <= 4)
  return states[i] and not old_states[i]
end

function released(i)
  assert(1 <= i and i <= 4)
  return not states[i] and old_states[i]
end

game.actors.new_generic('the_one_button', function ()
  function update_setup ()
    old_states = states
    states = {false, false, false, false}
    for i = 1, 4 do
      states[i] =
        game.keyboard.key_held(player_keys[i]) or
        glfw.GetJoystickButtons(player_joysticks[1], 1)[1] == glfw.PRESS
    end
  end
end)
