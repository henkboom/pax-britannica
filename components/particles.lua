local particles = require 'particles'

local emitter = particles.make_emitter()

function add_particle()
end

game.actors.new_generic('particles', function ()
  function draw ()
    emitter:draw()
  end
  function update ()
    emitter:update()
  end
end)
