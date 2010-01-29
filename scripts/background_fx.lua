local v2 = require 'dokidoki.v2'
local blueprints = require 'blueprints'

local sprites = {'debris_small_sprite', 'debris_med_sprite', 'debris_large_sprite'}

function update()
  if (math.random() < 0.25) then
    game.actors.new(blueprints.debris,
      {'transform', pos=v2(math.random() * 1024, math.random() * 768)},
      {'sprite', resource=sprites[math.ceil(math.random() * 3)], color={1, 1, 1, 0}})
  end
end
