require "dokidoki.module"
[[ range, map, array_for_each, array_filter, copy, build_array, identity ]]

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

function array_for_each (f, a)
  for i = 1, #a do
    f(a[i])
  end
end

function array_filter (p, a)
  local result = {}
  for i = 1, #a do
    if p(a[i]) then result[#result+1] = a[i] end
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

return get_module_exports()
