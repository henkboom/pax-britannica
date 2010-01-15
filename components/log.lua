local blueprints = require 'blueprints'

--A dictionary table for each recorded metric
local spawn = { fighter=0, bomber=0, frigate=0 }
local death = { fighter=0, bomber=0, frigate=0 }
local damage_given = { fighter=0, bomber=0, frigate=0 }
local damage_received = { fighter=0, bomber=0, frigate=0 }
local accuracy_hits = {fighter=0, bomber=0, frigate=0}
local accuracy_misses = {fighter=0, bomber=0, frigate=0}
local frame_count = 0

local function identify_bullet(bullet)
  if bullet.blueprint.name == 'laser' then
    return 'fighter'
  elseif bullet.blueprint.name == 'bomb' then
    return 'bomber'
  elseif bullet.blueprint.name == 'missile' then
    return 'frigate'
  else
    --what the hell hit you?
    print('Unknown projectile type ', bullet)
  end
end

function record_spawn(spawned)
  spawn[spawned.name] = spawn[spawned.name] or 0
  spawn[spawned.name] = spawn[spawned.name] + 1
end

function record_death(killed)
  death[killed.name] = death[killed.name] or 0
  death[killed.name] = death[killed.name] + 1
end

function record_hit(receiver, bullet)
  giver = identify_bullet(bullet)
  real_damage = math.min(bullet.collision.damage, receiver.ship.hit_points)
  
  damage_given[giver] = damage_given[giver] or 0
  damage_given[giver] = damage_given[giver] + real_damage
  
  damage_received[receiver.blueprint.name] = damage_received[receiver.blueprint.name] or 0
  damage_received[receiver.blueprint.name] = damage_received[receiver.blueprint.name] + real_damage
                                             
  accuracy_hits[giver] = accuracy_hits[giver] or 0
  accuracy_hits[giver] = accuracy_hits[giver] + 1
end

function record_miss(bullet)
  shooter = identify_bullet(bullet)
  accuracy_misses[shooter] = accuracy_misses[shooter] or 0
  accuracy_misses[shooter] = accuracy_misses[shooter] + 1
end

function record_time()
  frame_count = frame_count + 1
end

function print_stats()
  print('=====================================')
  print('==         GAME STATISTICS         ==')
  print('=====================================')
  print('Time Elapsed:')    print("", string.format("%.3f seconds", frame_count / 60))
  print('Constructed:')     for k,v in pairs(spawn) do print("    ",string.upper(k),v) end
  print('Destroyed:')       for k,v in pairs(death) do print("    ",string.upper(k),v) end
  print('Damage Given:')    for k,v in pairs(damage_given) do print("    ",string.upper(k),v) end
  print('Damage Received:') for k,v in pairs(damage_received) do print("    ",string.upper(k),v) end
  
  print('Accuracy:')
  for k,v in pairs(accuracy_hits) do
    accuracy = v / (v + accuracy_misses[k]) * 100
    print("    ",string.upper(k), string.format("%.2f%%", accuracy))
  end
  print('=====================================')
end

game.actors.new_generic('log', function()
  function update()
    game.log.record_time()
  end
end)