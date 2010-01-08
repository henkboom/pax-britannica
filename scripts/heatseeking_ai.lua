local v2 = require 'dokidoki.v2'

local turn_speed = 0.15
local accel = 0.15

-- Try to find a target
local target = game.targeting.get_type_in_range(self, 'fighter', 600) or
               game.targeting.get_type_in_range(self, 'bomber', 600) or
               game.targeting.get_type_in_range(self, 'frigate', 600) or
               game.targeting.get_nearest_of_type(self, 'fighter') or
               game.targeting.get_nearest_of_type(self, 'factory')

function update()
  if not target or target.dead then
    self_destruct()
  else
    self.ship.go_towards(target.transform.pos, true)
  end
end

function self_destruct()
  --EXPLODE!
  self.dead = true
end