local v2 = require 'dokidoki.v2'

-- shot range
local shot_distance = 350
-- try to stay this far away
local clear_distance = 200

local shot_cooldown_time = 6
local shot_capacity = 5
local shot_reload_rate = 2/60

local shots = shot_capacity
local cooldown = 0

-- true when we've shot everything and want to make a distance, false means
-- we're approaching to attack
local clearing = false

local target = false

local function retarget ()
  target = game.targeting.get_nearest_of_type(self, 'factory')
end

function update()
  if not target then
    retarget()
  end

  if target then
    local to_target = target.transform.pos - self.transform.pos
    local dist_squared = v2.sqrmag(to_target)

    if clearing then
      local too_close = dist_squared < clear_distance^2
      if too_close then
        self.ship.go_away(target.transform.pos, true)
      else
        self.ship.thrust()
      end

      if shots == shot_capacity and not too_close then
        clearing = false
      end
    else
      self.ship.go_towards(target.transform.pos, true)

      -- maybe shoot
      cooldown = math.max(0, cooldown - 1)
      if cooldown == 0 then
        local facing = self.transform.facing
        if dist_squared <= shot_distance * shot_distance
           and v2.dot(to_target, facing) > 0
           and v2.dot(to_target, facing)^2 > 0.9 * dist_squared then
          self.fighter_shooting.shoot()
          shots = shots - 1
          cooldown = shot_cooldown_time
        end
      end

      -- if out of shots then clear out
      if shots < 1 then
        clearing = true
      end
    end
  end
  
  -- Gradually recharge shots
  shots = math.min(shots + shot_reload_rate, shot_capacity)
end
