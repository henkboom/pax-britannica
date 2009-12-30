local blueprints = require 'blueprints'
local v2 = require 'dokidoki.v2'

function update()
  local x_key = game.keyboard.key_held(string.byte('X'))

  if x_key then game.actors.new(blueprints.fighter, {'transform', pos=v2(500, 100)}) end
end
