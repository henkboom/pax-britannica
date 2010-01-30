local gl = require 'gl'
local kernel = require 'dokidoki.kernel'

background_color = {0, 0, 0}
width = 640
height = 480

game.actors.new_generic('opengl_setup', function ()
  draw_setup = function ()
    kernel.set_ratio(width / height)

    local bg = background_color
    if bg then
      gl.glClearColor(bg[1], bg[2], bg[3], 0)
      gl.glClear(gl.GL_COLOR_BUFFER_BIT)
    end

    gl.glEnable(gl.GL_BLEND)
    gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)

    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    gl.glOrtho(0, width, 0, height, 1, -1)
    gl.glMatrixMode(gl.GL_TEXTURE)
    gl.glLoadIdentity()
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()
  end
end)
