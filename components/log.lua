local blueprints = require 'blueprints'

--A dictionary table for each recorded metric
local spawn = { fighter=0, bomber=0, frigate=0 }
local death = { fighter=0, bomber=0, frigate=0 }
local damage_given = { fighter=0, bomber=0, frigate=0 }
local damage_received = { fighter=0, bomber=0, frigate=0 }
local accuracy_hits = {fighter=0, bomber=0, frigate=0}
local accuracy_misses = {fighter=0, bomber=0, frigate=0}

function record_spawn(spawned)
  spawn[spawned.name] = spawn[spawned.name] or 0
  spawn[spawned.name] = spawn[spawned.name] + 1
end

function record_death(killed)
  death[killed.name] = death[killed.name] or 0
  death[killed.name] = death[killed.name] + 1
end

function record_hit(receiver, bullet)
  local giver
  if bullet.blueprint.name == 'laser' then
    giver = 'fighter'
  elseif bullet.blueprint.name == 'bomb' then
    giver = 'bomber'
  elseif bullet.blueprint.name == 'missile' then
    giver = 'frigate'
  else
    --what the hell hit you?
    print('Unknown projectile type ', bullet)
  end
  
  damage_given[giver] = damage_given[giver] or 0
  damage_given[giver] = damage_given[giver] + bullet.collision.damage
  
  damage_received[receiver.blueprint.name] = damage_received[receiver.blueprint.name] or 0
  damage_received[receiver.blueprint.name] = damage_received[receiver.blueprint.name]
                                             + bullet.collision.damage
                                             
  accuracy_hits[giver] = accuracy_hits[giver] or 0
  accuracy_hits[giver] = accuracy_hits[giver] + 1
end

function record_miss(bullet)
  if bullet.blueprint.name == 'laser' then
    giver = 'fighter'
  elseif bullet.blueprint.name == 'bomb' then
    giver = 'bomber'
  elseif bullet.blueprint.name == 'missile' then
    giver = 'frigate'
  else
    --what the hell hit you?
    print('Unknown projectile type ', bullet)
  end
  
  accuracy_misses[giver] = accuracy_misses[giver] or 0
  accuracy_misses[giver] = accuracy_misses[giver] + 1
end

function print_stats()
  print('============================================================')
  print('==                    GAME STATISTICS                     ==')
  print('============================================================')
  print('Constructed:')     for k,v in pairs(spawn) do print("    ",string.upper(k),v) end
  print('Destroyed:')       for k,v in pairs(death) do print("    ",string.upper(k),v) end
  print('Damage Given:')    for k,v in pairs(damage_given) do print("    ",string.upper(k),v) end
  print('Damage Received:') for k,v in pairs(damage_received) do print("    ",string.upper(k),v) end
  
  print('Accuracy:')
  for k,v in pairs(accuracy_hits) do
    accuracy = v / (v + accuracy_misses[k]) * 100
    print("    ",string.upper(k), string.format("%.2f%%", accuracy))
  end
  print('============================================================')
end