local blueprints = require 'blueprints'
local v2 = require 'dokidoki.v2'

local function spawn(blueprint)
  game.actors.new(blueprint,
    {'transform', pos=self.transform.pos},
    {'ship', player=self.ship.player})
end

function update()
  local x_key = game.keyboard.key_pressed(string.byte('X'))
  local c_key = game.keyboard.key_pressed(string.byte('C'))
  local v_key = game.keyboard.key_pressed(string.byte('V'))

  if x_key then spawn(blueprints.fighter) end
  if c_key then spawn(blueprints.bomber) end
  if v_key then spawn(blueprints.frigate) end
end
