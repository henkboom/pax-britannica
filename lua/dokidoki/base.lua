require "dokidoki.module"
[[ range, map, imap, foldl, iforeach, ifilter, copy, build_array, identity,
   void, compose ]]

function range(first, last, step)
  step = step or 1
  local result = {}
  for i = first, last, step do
    result[#result+1] = i
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

function foldl(f, init, a)
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
