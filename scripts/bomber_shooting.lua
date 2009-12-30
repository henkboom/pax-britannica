local v2 = require 'dokidoki.v2'
local blueprints = require 'blueprints'

function shoot()
  game.actors.new(blueprints.bomb, {'transform', pos=self.transform.pos, facing=v2.rotate90(self.transform.facing)})
end
