local gl = require 'gl'

color = color or false

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

  if color then gl.glColor4d(color[1], color[2], color[3], color[4] or 1) end
  image:draw()
  if color then gl.glColor3d(1, 1, 1) end

  gl.glPopMatrix()
end
