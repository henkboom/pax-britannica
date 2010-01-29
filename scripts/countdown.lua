local v2 = require 'dokidoki.v2'

local counter = 5

function update()
  counter = counter - 1/60
  self.sprite.color = {1, 1, 1, math.sin(math.mod(counter, 1) * math.pi)}
  
  if counter <= 0 then self.dead = true 
  else
    self.sprite.image = game.resources.number_sprites[math.ceil(counter)]
  end
end
