local gl = require 'gl'

if not image then
  if resource then
    image = game.resources[resource]
  else
    -- create a dummy 1x1 square if there's no given image
    image = {
      draw = function (_)
        gl.glBegin(gl.GL_QUADS)
        gl.glVertex2d(0, 0)
        gl.glVertex2d(1, 0)
        gl.glVertex2d(1, 1)
        gl.glVertex2d(0, 1)
        gl.glEnd()
      end
    }
  end
end

function draw()
  -- TODO: do these transforms directly, much faster!
  gl.glPushMatrix()
  gl.glTranslated(self.transform.pos.x, self.transform.pos.y, 0)
  -- slooooow and stupid rotation:
  local f = self.transform.facing
  gl.glRotated(180/math.pi * math.atan2(f.y, f.x), 0, 0, 1)
  gl.glScaled(self.transform.scale_x, self.transform.scale_y, 0)

  image:draw()

  gl.glPopMatrix()
end
