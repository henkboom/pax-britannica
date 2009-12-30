local blueprints = require 'blueprints'

function shoot()
  game.actors.new(blueprints.missile, {'transform', pos=self.transform.pos})
end
