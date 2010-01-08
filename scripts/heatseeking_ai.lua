local v2 = require 'dokidoki.v2'

local turn_speed = 0.1
local accel = 0.1

-- Try to find a target
local target = game.targeting.get_nearest_of_type(self, 'fighter')
if not target then target = game.targeting.get_nearest_of_type(self, 'frigate') end
if not target then target = game.targeting.get_nearest_of_type(self, 'bomber') end
if not target then target = game.targeting.get_nearest_of_type(self, 'factory') end
-- F this, self-destruct
if not target then self_destruct() end

function update()
  if target.dead then
    self_destruct()
  end
  self.ship.go_towards(target.transform.pos, true)
end

function self_destruct()
  --EXPLODE!
  self.dead = true
end