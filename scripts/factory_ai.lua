local blueprints = require 'blueprints'
local v2 = require 'dokidoki.v2'

function update()
  local x_key = game.keyboard.key_pressed(string.byte('X'))
  local c_key = game.keyboard.key_pressed(string.byte('C'))
  local v_key = game.keyboard.key_pressed(string.byte('V'))

  if x_key then game.actors.new(blueprints.fighter, {'transform', pos=self.transform.pos}) end
  if c_key then game.actors.new(blueprints.bomber, {'transform', pos=self.transform.pos}) end
  if v_key then game.actors.new(blueprints.frigate, {'transform', pos=self.transform.pos}) end
end
