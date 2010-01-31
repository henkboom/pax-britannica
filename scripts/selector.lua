local gl = require 'gl'

assert(player, 'missing player argument')

picked = false

local OFFSET_PIXELS = -4

local fade = 0.2

local pulse_time = 0

self.sprite.image = assert(game.resources.factory_sprites[player])

function update()
  pulse_time = pulse_time + 1

  if not picked and game.the_one_button.held(player) then
    picked = true
  end
  if picked then
    fade = math.min(fade + 0.1, 1)
    self.sprite.color = {fade, fade, fade}
  end
end

function draw()
  local pos = self.transform.pos + OFFSET_PIXELS * self.transform.facing
  local pulse = (1 + math.cos(pulse_time/180*2*math.pi))/2

  local color = fade * pulse + 1 * (1-pulse)

  gl.glPushMatrix()
  gl.glColor3d(color, color, color)
  gl.glTranslated(pos.x, pos.y, 0)
  game.resources.a_button:draw()
  gl.glColor3d(1, 1, 1)
  gl.glPopMatrix()
end
