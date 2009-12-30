local blueprints = require 'blueprints'

local speed = 20

function shoot()
  local start_vel = speed * self.transform.facing + self.ship.velocity
  game.actors.new(blueprints.laser, {'transform', pos=self.transform.pos, facing=self.transform.facing}, {'bullet', velocity=start_vel})
end
