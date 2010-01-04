local v2 = require 'dokidoki.v2'

local shots = 3

function update()
  local target = game.targeting.get_nearest_of_type(self, 'factory')

  if target then
    -- Move away from target if out of shots
    if shots > 1 then
        self.ship.go_towards(target.transform.pos, true)
    else
        self.ship.go_away(target.transform.pos, true)
    end
    
    target_distance = v2.mag(target.transform.pos - self.transform.pos)
    target_direction = v2.norm(target.transform.pos - self.transform.pos)
    facing_direction = v2.norm(self.transform.facing)
    
    -- Only shoot when facing target and in range
    if shots > 1 and target_distance < 140 and v2.dot(facing_direction, target_direction) > 0.99 then
        self.fighter_shooting.shoot()
        shots = shots - 1
    end
  end
  
  -- Gradually recharge shots
  if shots < 3 then
    shots = math.min(shots + 0.04, 3)
  end
end
