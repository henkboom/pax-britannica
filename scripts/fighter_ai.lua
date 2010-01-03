local v2 = require 'dokidoki.v2'

function update()
  local target = game.targeting.get_nearest_of_type(self, 'factory')

  if target then
    self.ship.go_towards(target.transform.pos, true)
    
    target_distance = v2.mag(target.transform.pos - self.transform.pos)
    target_direction = v2.norm(target.transform.pos - self.transform.pos)
    facing_direction = v2.norm(self.transform.facing)
    
    -- Only shoot when facing target and in range
    if v2.dot(facing_direction, target_direction) > 0.99 and target_distance < 140 then
        self.fighter_shooting.shoot()
    end
  end
end
