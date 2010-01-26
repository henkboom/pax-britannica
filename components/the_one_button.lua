-- TODO: joypad support

function held(i)
  assert(1 <= i and i <= 4)
  return game.keyboard.key_held(string.byte('0') + i)
end

function pressed(i)
  assert(1 <= i and i <= 4)
  return game.keyboard.key_pressed(string.byte('0') + i)
end
