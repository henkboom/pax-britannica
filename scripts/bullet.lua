local v2 = require 'dokidoki.v2'

assert(velocity, 'missing velocity argument')

function update()
  local screen_bounds = v2(game.opengl_2d.width, game.opengl_2d.height);

  self.transform.pos = self.transform.pos + velocity * self.transform.facing
  
  if self.transform.pos.x > screen_bounds.x or self.transform.pos.y > screen_bounds.y or 
     self.transform.pos.x < 0 or self.transform.pos.y < 0 then
	 self.dead = true
  end
end
