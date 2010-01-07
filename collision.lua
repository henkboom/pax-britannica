require 'dokidoki.module'
[[ make_polygon, collide,
   points_to_polygon, make_rectangle ]]

local v2 = require 'dokidoki.v2'
import(require 'dokidoki.base')


local native = require 'collision.native'

function make_polygon(vertices)
  if v2.cross(vertices[2] - vertices[1], vertices[3] - vertices[2]) < 0 then
    vertices = ireverse(vertices)
  end

  local coords = {}
  for _, v in ipairs(vertices) do
    table.insert(coords, v.x)
    table.insert(coords, v.y)
  end
  return {data = native.make_polygon(coords), vertices = vertices}
end

function collide(body1, body2)
  -- grr backwards compatibility
  local facing1 = body1.facing or v2.unit(body1.angle)
  local facing2 = body2.facing or v2.unit(body2.angle)

  local collision, x, y = native.collide(
    body1.pos.x, body1.pos.y, facing1.x, facing1.y, body1.poly.data,
    body2.pos.x, body2.pos.y, facing2.x, facing2.y, body2.poly.data)

  return collision and v2(x, y)
end

function points_to_polygon(points)
  local sum = v2(0, 0)
  for _, p in ipairs(points) do
    sum = sum + p
  end
  local pos = sum / #points
  local vertices = {}
  for _, p in ipairs(points) do
    table.insert(vertices, p - pos)
  end
  return pos, make_polygon(vertices)
end

function make_rectangle(w, h)
  return make_polygon{
    v2(-w/2, -h/2),
    v2(w/2, -h/2),
    v2(w/2, h/2),
    v2(-w/2, h/2)}
end

return get_module_exports()
