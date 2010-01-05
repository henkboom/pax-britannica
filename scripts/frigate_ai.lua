local v2 = require 'dokidoki.v2'

local cooldown_timer = 300

function update()
  local target = game.targeting.get_nearest_of_type(self, 'factory')

  if target then    
    target_distance = v2.mag(target.transform.pos - self.transform.pos)
    target_direction = v2.norm(target.transform.pos - self.transform.pos)
    facing_direction = v2.norm(self.transform.facing)
    speed = v2.mag(self.ship.velocity)
    
    if cooldown_timer == 0 and speed > 0 and target_distance < 350 then
        --brake?
    elseif target_distance < 200 then
        --not too close!
        self.ship.go_away(target.transform.pos, true)
    else
        self.ship.go_towards(target.transform.pos, true)
    end
    
    -- Only shoot when not moving and in range
    if target_distance < 400 and speed < 0.1 then
        self.frigate_shooting.shoot()
        cooldown_timer = 300
    end
  end
  
  cooldown_timer = math.max(cooldown_timer - 1, 0)
end
