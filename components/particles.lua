local v2 = require 'dokidoki.v2'
local particles = require 'particles'

local bubble_emitter = particles.make_emitter(
    game.resources.bubble_sprite.size[1],
    game.resources.bubble_sprite.size[2],
    game.resources.bubble_sprite.tex.name)

local emitters = { bubble_emitter }

function add_bubble(pos)
  bubble_emitter:add_particle(pos.x, pos.y, math.random() * 0.3 - 0.15, 0.25) 
end

game.actors.new_generic('particles', function ()
  function draw ()
    for _, emitter in ipairs(emitters) do
      emitter:draw()
    end
  end
  function update ()
    if game.keyboard.key_held(string.byte('P')) then
      for i = 1, 10 do
        local vel = v2.random() * 3
        bubble_emitter:add_particle(300, 300, vel.x, vel.y)
      end
    end
    for _, emitter in ipairs(emitters) do
      emitter:update()
    end
  end
end)
