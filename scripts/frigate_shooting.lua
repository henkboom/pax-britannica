local blueprints = require 'blueprints'

local speed = 1

function shoot()
  local start_vel = speed * self.transform.facing + self.ship.velocity
  game.actors.new(blueprints.missile, {'transform', pos=self.transform.pos}, {'bullet', velocity=start_vel})
end
