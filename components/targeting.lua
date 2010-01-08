local v2 = require 'dokidoki.v2'

local function on_screen(pos)
  if pos.x < 0 or pos.x > 1028 or pos.y < 0 or pos.y > 768 then
    return false
  else
    return true
  end
end

-- returns the closest target of the given type
function get_nearest_of_type(source, ship_type)
  local ships = game.actors.get(ship_type)

  -- find the closest one!
  local closest_ship
  local closest_square_magnitude

  for _, ship in ipairs(ships) do
    local square_magnitude = v2.sqrmag(ship.transform.pos - source.transform.pos)
    
    if source.ship.player ~= ship.ship.player and on_screen(ship.transform.pos) and (not closest_ship or square_magnitude < closest_square_magnitude) then
      closest_ship = ship
      closest_square_magnitude = square_magnitude
    end
  end

  return closest_ship
end