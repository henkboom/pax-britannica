require "dokidoki.module"
[[ make, unit,
   add, sub, neg, mul, div, dot, cross, project,
   mag, sqrmag, angle, norm, eq, coords,
   rotate, rotate90, rotate_to, rotate_from,
   random,
   zero, i, j ]]

function make (x, y)  return setmetatable({x=x, y=y}, mt) end
local make = make
function unit (angle) return make(math.cos(angle), math.sin(angle)) end

function add (a, b)    return make(a.x + b.x, a.y + b.y) end
function sub (a, b)    return make(a.x - b.x, a.y - b.y) end 
function neg (v)       return make(-v.x, -v.y) end
function mul (v, s)    return make(s * v.x, s * v.y) end
function div (v, s)    return make(v.x / s, v.y / s) end
function dot (a, b)    return a.x * b.x + a.y * b.y end
function cross (a, b)  return a.x * b.y - a.y * b.x end
function project(a, b) return b * (dot(a, b) / sqrmag(b)) end

function mag (v)      return math.sqrt(v.x * v.x + v.y * v.y) end
function sqrmag (v)   return dot(v, v) end
function angle (v)    return math.atan2(v.y, v.x) end
function norm (v)     return v / mag(v) end
function eq (a, b)    return a.x == b.x and a.y == b.y end
function coords (v)   return v.x, v.y end

function rotate(v, a)
  local sin_a, cos_a = math.sin(a), math.cos(a)
  return make(v.x * cos_a - v.y * sin_a, v.y * cos_a + v.x * sin_a)
end

function rotate90(v)
  return make(-v.y, v.x)
end

function rotate_to(v, i)
  return make(i.x * v.x - i.y * v.y, i.y * v.x + i.x * v.y)
end

function rotate_from(v, i)
  return make(i.x * v.x + i.y * v.y, - i.y * v.x + i.x * v.y)
end

function random()
  return unit(math.random() * math.pi * 2) * math.sqrt(math.random())
end

mt =
{
  __add = add,
  __sub = sub,
  __mul = function (a, b)
    return type(a) == 'number' and mul(b, a) or mul(a, b)
  end,
  __div = div,
  __unm = neg,
  __eq = eq,

  __tostring = function (v)
    return '(' .. v.x .. ', ' .. v.y .. ')'
  end,
}

zero = make(0, 0)
i = make(1, 0)
j = make(0, 1)

return setmetatable(
  get_module_exports(),
  {__call = function (_, x, y) return make(x, y) end})
