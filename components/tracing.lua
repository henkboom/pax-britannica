local gl = require 'gl'

local tracers = {}

function trace_bar(pos, progress)
  table.insert(tracers, game.actors.new_generic('arrow_trace', function ()
    function draw()
      local left = -10 + pos.x
      local right = 10 + pos.x
      local bottom = -1 + pos.y
      local top = 1 + pos.y
      local mid = left + (right - left) * progress
      gl.glBegin(gl.GL_QUADS)
      gl.glColor3d(1, 0, 0)
      gl.glVertex2d(left, bottom)
      gl.glVertex2d(right, bottom)
      gl.glVertex2d(right, top)
      gl.glVertex2d(left, top)
      gl.glColor3d(0, 1, 0)
      gl.glVertex2d(left, bottom)
      gl.glVertex2d(mid, bottom)
      gl.glVertex2d(mid, top)
      gl.glVertex2d(left, top)
      gl.glEnd()
      gl.glColor3d(1, 1, 1)
    end
  end))
end

game.actors.new_generic('tracer_cleanup', function ()
  function update_setup()
    for i = 1, #tracers do
      tracers[i].dead = true
      tracers[i] = nil
    end
  end
end)
