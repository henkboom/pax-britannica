require 'dokidoki.module' [[]]

import(require 'gl')
import(require 'glu')
import(require 'dokidoki.base')

local actor_scene = require 'dokidoki.actor_scene'
local kernel = require 'dokidoki.kernel'
local v2 = require 'dokidoki.v2'

local function make_spinner(period)
  local rotation = 0

  self = {
    pos = v2(320, 240),
    update = function ()
      rotation = rotation + 360 / period / 60
    end,
    draw = function ()
      glRotated(rotation, 0, 0, 1)
      glScaled(100, 100, 100)
      glColor3d(0.5, 0.25, 1)
      glBegin(GL_QUADS)
        glVertex2d(-1, -1)
        glVertex2d( 1, -1)
        glVertex2d( 1,  1)
        glVertex2d(-1,  1)
      glEnd()
    end
  }

  return self
end

function init (game)
  game.add_actor{
    draw_setup = function ()
      glClearColor(0, 0, 0.25, 0)
      glClear(GL_COLOR_BUFFER_BIT)
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity()
      glOrtho(0, 640, 0, 480, 1, -1)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity()
    end
  }

  game.add_actor(make_spinner(4))
end

kernel.start_main_loop(actor_scene.make_actor_scene(
  {"update"},
  {"draw_setup", "draw"},
  init))

