local v2 = require 'dokidoki.v2'

assert(player, 'missing player argument')
assert(turn_speed, 'missing turn_speed argument')
assert(accel, 'missing accel argument')
assert(hit_points, 'missing hit_points argument')

local max_hit_points = hit_points

local player_colors = {
  {0.5, 0.2, 0.8},
  {0.5, 0.8, 0.2},
  {0.2, 0.6, 0.6},
  {0.8, 0.4, 0.2}  
}

self.sprite.color = player_colors[player]

velocity = v2(0, 0)

-- 1 for left, -1 for right
function turn(direction)
  self.transform.facing =
    v2.norm(v2.rotate(self.transform.facing, turn_speed * direction))
end

function thrust()
  velocity = velocity + self.transform.facing * accel
end

function update()
  velocity = velocity * 0.97
  self.transform.pos = self.transform.pos + velocity
  if hit_points <= 0 then self.dead = true end
  game.tracing.trace_bar(self.transform.pos + v2(0, 10),
                         hit_points / max_hit_points)
end

local function go_towards_or_away(target_pos, force_thrust, is_away)
  local target_direction = target_pos - self.transform.pos
  if is_away then target_direction = -target_direction end

  if v2.cross(self.transform.facing, target_direction) > 0 then
    turn(1)
  else
    turn(-1)
  end
  if force_thrust or v2.dot(self.transform.facing, target_direction) > 0 then
    thrust()
  end
end

function damage(amount)
  hit_points = hit_points - amount
end

-- automatically thrusts and turns according to the target
function go_towards(target_pos, force_thrust)
  go_towards_or_away(target_pos, force_thrust, false)
end

function go_away(target_pos, force_thrust)
  go_towards_or_away(target_pos, force_thrust, true)
end
