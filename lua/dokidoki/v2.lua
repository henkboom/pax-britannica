require "dokidoki.closedmodule"
[[ make, unit,
   add, sub, mul, div, dot, cross, mag, sqrmag, norm, eq, coords,
   zero, i, j ]]

function make(x, y)  return setmetatable({x=x, y=y}, mt) end
function unit(angle) return v2(math.cos(angle), math.sin(angle)) end

function add(a, b)   return make(a.x + b.x, a.y + b.y) end
function sub(a, b)   return make(a.x - b.x, a.y - b.y) end 
function neg(v)      return make(-v.x, -v.y) end
function mul(v, s)   return make(s * v.x, s * v.y) end
function div(v, s)   return make(v.x / s, v.y / s) end
function dot(a, b)   return a.x * b.x + a.y * b.y end
function cross(a, b) return a.x * b.y - a.y * b.x end
function mag(v)      return math.sqrt(v.x * v.x + v.y * v.y) end
function sqrmag(v)   return dot(v, v) end
function norm(v)     return v / mag(v) end
function eq(a, b)    return a.x == b.x and a.y == b.y end
function coords(v)   return v.x, v.y end

mt =
{
  __add = add,
  __sub = sub,
  __mul = mul,
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
