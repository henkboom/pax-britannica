local collision = require 'dokidoki.collision'
local log = require 'components.log'

-- umm, looks like brute force n^2 checking is fast enough
local bodies = {}

function add_body(body)
  bodies[#bodies+1] = body
end

game.actors.new_generic('collision', function ()
  function collision_check()
    for i = 1, #bodies do
      local b1 = bodies[i]
      for j = i+1, #bodies do
        local b2 = bodies[j]
        if b1.type ~= b2.type and b1.player ~= b2.player
          and collision.collide(b1, b2) then
          if b1.type == 'bullet' then
            game.log.record_hit(b2.actor, b1.actor)
            b2.actor.ship.damage(b1.actor.collision.damage)
            b1.actor.dead = true
            end
          if b2.type == 'bullet' then
            game.log.record_hit(b1.actor, b2.actor)
            b1.actor.ship.damage(b2.actor.collision.damage)
            b2.actor.dead = true
            end
        end
      end
    end

    bodies = {}
  end
end)
