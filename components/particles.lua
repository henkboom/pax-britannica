local v2 = require 'dokidoki.v2'
local particles = require 'particles'

local emitter = particles.make_emitter()

function add_particle()
end

game.actors.new_generic('particles', function ()
  function draw ()
    emitter:draw()
  end
  function update ()
    if game.keyboard.key_held(string.byte('P')) then
      for i = 1, 2000/60 do
        local vel = v2.random() * 3
        emitter:add_particle(300, 300, vel.x, vel.y)
      end
    end
    emitter:update()
  end
end)
