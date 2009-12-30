local blueprints = require 'blueprints'

function shoot()
  game.actors.new(blueprints.laser, {'transform', pos=self.transform.pos, facing=self.transform.facing})
end
