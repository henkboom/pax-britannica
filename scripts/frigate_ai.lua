local v2 = require 'dokidoki.v2'

local stopping = false

local function retarget ()
  target = game.targeting.get_nearest_of_type(self, 'fighter') or
           game.targeting.get_nearest_of_type(self, 'factory')
end

function update()
  -- this math.random stuff is temporary
  if not target or math.random() < 0.001 then
    retarget()
  end
  
  if target then    
    target_distance = v2.mag(target.transform.pos - self.transform.pos)
    target_direction = v2.norm(target.transform.pos - self.transform.pos)
    facing_direction = v2.norm(self.transform.facing)
    speed = v2.mag(self.ship.velocity)
    
    if self.frigate_shooting.is_ready_to_shoot() and speed > 0 and target_distance < 350 then
      stopping = true
    elseif self.frigate_shooting.is_empty() then
      stopping = false
    end

    if not stopping then
      if target_distance < 200 then
        --not too close!
        self.ship.go_away(target.transform.pos, true)
      else
        self.ship.go_towards(target.transform.pos, true)
      end
    end
    
    -- Only shoot when not moving and in range
    if not self.frigate_shooting.is_empty() and speed < 0.1 then
        self.frigate_shooting.shoot()
    end
  end
end
