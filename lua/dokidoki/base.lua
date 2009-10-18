require "dokidoki.module"
[[ range, ireverse, map, imap, ifoldl, iforeach, irandomize, iconcat, ifilter, copy, build_array,
   identity, void, compose ]]

function range(first, last, step)
  step = step or 1
  local result = {}
  for i = first, last, step do
    result[#result+1] = i
  end
  return result
end

function ireverse(a)
  local result = {}
  local len = #a
  for i = 1, len do
    result[i] = a[len - i + 1]
  end
  return result
end

function map (f, t)
  local result = {}
  for k, v in pairs(t) do
    result[k] = f(v)
  end
  return result
end

function imap (f, a)
  local result = {}
  for i, v in ipairs(a) do
    result[i] = f(v)
  end
  return result
end

function ifoldl(f, init, a)
  for _, v in ipairs(a) do
    init = f(init, v)
  end
  return init
end

function iforeach (f, a)
  for i = 1, #a do
    f(a[i])
  end
end

function irandomize(a)
  local result = copy(a)
  for i = 1, #result-1 do
    local j = math.random(i, #result)
    local tmp = result[i]
    result[i] = result[j]
    result[j] = tmp
  end
  return result
end

function iconcat(a1, a2)
  local result = copy(a1)
  local len = #a1
  for i, v in ipairs(a2) do
    result[len + i] = v
  end
  return result
end

function ifilter (p, a)
  local result = {}
  for k, v in ipairs(a) do
    if p(v) then result[#result+1] = v end
  end
  return result
end

function copy (t)
  local result = {}
  for k, v in pairs(t) do
    result[k] = v
  end
  return result
end

function build_array (len, f)
  local result = {}
  for i = 1, len do
    result[i] = f(i)
  end
  return result
end

function identity (...)
  return ...
end

function void ()
end

function compose(f, ...)
  if select('#', ...) == 0 then 
    return f
  else
    local rest = compose(...)
    return function (...)
      return f(rest(...))
    end
  end
end

return get_module_exports()
