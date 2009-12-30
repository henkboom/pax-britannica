local v2 = require 'dokidoki.v2'

-- returns the closest target of the given type
function get_nearest_of_type(source, ship_type)
  local ships = game.actors.get(ship_type)

  -- find the closest one!
  local closest_ship
  local closest_square_magnitude

  for _, ship in ipairs(ships) do
    local square_magnitude =
      v2.sqrmag(ship.transform.pos - source.transform.pos)
    if not closest_ship or square_manitude < closest_square_manitude then
      closest_ship = ship
      closest_square_magnitude = square_magnitude
    end
  end

  return closest_ship
end
