local v2 = require 'dokidoki.v2'

-- shot range
local shot_range = 350
-- try to stay this far away when you're out of ammo
local run_distance = 200

-- true when we've shot everything and want to make a distance, false means
-- we're approaching to attack
local running = false

local target = false

local function retarget ()
  target = game.targeting.get_nearest_of_type(self, 'bomber') or
           game.targeting.get_nearest_of_type(self, 'fighter') or
           game.targeting.get_nearest_of_type(self, 'factory')
end

-- basically, the behaviour is to go towards the target and attack it, then
-- when you're out of ammo run away until you've got your ammo back and have
-- gone a certain distance

function update()
  -- this math.random stuff is temporary
  if not target or math.random() < 0.005 then
    retarget()
  end

  if target then
    local to_target = target.transform.pos - self.transform.pos
    local dist_squared = v2.sqrmag(to_target)

    if running then
      -- run away until you have full ammo and are far enough away

      local too_close = dist_squared < run_distance^2
      -- if you're too close to the target then turn away
      if too_close then
        self.ship.go_away(target.transform.pos, true)
      else
        self.ship.thrust()
      end

      if self.fighter_shooting.is_reloaded() and not too_close then
        running = false
      end
    else
      -- go towards the target and attack!

      self.ship.go_towards(target.transform.pos, true)

      -- maybe shoot
      if self.fighter_shooting.is_ready_to_shoot() then
        local facing = self.transform.facing
        if dist_squared <= shot_range * shot_range
          and v2.dot(to_target, facing) > 0
          and v2.dot(to_target, facing)^2 > 0.97 * dist_squared then
          self.fighter_shooting.shoot()
        end
      end

      -- if out of shots then run away
      if self.fighter_shooting.is_empty() then
        running = true
      end
    end
  end
end
