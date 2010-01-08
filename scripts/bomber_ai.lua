local v2 = require 'dokidoki.v2'

local approaching = true
local cooldown_timer = 100
local target = false
local approach_sign = 1

local function retarget()
  target = game.targeting.get_nearest_of_type(self, 'frigate') or
           game.targeting.get_nearest_of_type(self, 'factory')
end

function update()
  if not target or math.random() < 0.005 then
    local old_target = target
    retarget()
    if old_target ~= target then
      approach_sign = math.random() < 0.5 and 1 or -1
    end
  end

  if target then   
    local target_position = target.transform.pos
    target_distance = v2.mag(target_position - self.transform.pos)
    target_direction = v2.norm(target_position - self.transform.pos)
    firing_direction = v2.norm(approach_sign * v2.rotate90(self.transform.facing))
    
    --When in the 250-300 range, get into firing position
    if approaching and target_distance < 250 then
        approaching = false
    elseif not approaching and target_distance > 300 then
        approaching = true
    end
     
    if approaching then
        self.ship.go_towards(target_position, true)
    else
        if v2.cross(firing_direction, target_direction) > 0 then
            self.ship.turn(1)
        else
            self.ship.turn(-1)
        end
        self.ship.thrust()
    end
    
    -- Only shoot when perpendicular to target and in range
    if cooldown_timer == 0 and target_distance < 220 and v2.dot(firing_direction, target_direction) > 0.99 then
        self.bomber_shooting.shoot(approach_sign)
        cooldown_timer = 100
    end
  end
  
  cooldown_timer = math.max(cooldown_timer - 1, 0)
end
