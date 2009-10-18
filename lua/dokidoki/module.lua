local function parse_exports (export_defs)
  local exports = {}
  local i = 1
  while true do
    local key
    local begin

    local external_name, internal_name
    local i2
    -- parse external name
    external_name, i2 = string.match(export_defs, "^%s*([%a_][%w_]*)()", i)
    if i2 ~= nil then i = i2 else break end

    -- parse internal name
    internal_name, i2 = string.match(export_defs, "^%s*=%s*([%a_][%w_]*)()", i)
    if i2 ~= nil then i = i2 end

    -- assign it
    assert(exports[external_name] == nil,
           "two module exports with the same name!")
    exports[external_name] = internal_name or external_name

    -- parse comma
    i2 = string.match(export_defs, "^%s*,()", i)
    if i2 ~= nil then i = i2 else break end
  end
  i = string.match(export_defs, "^%s*()", i)
  assert(i == string.len(export_defs) + 1,
         "invalid exports starting at " .. i)
  
  return exports
end

-- modified from strict.lua
local function make_private_table ()
  local getinfo, error, rawset, rawget = debug.getinfo, error, rawset, rawget

  local mt = {}
  
  mt.__declared = {}
  
  local function what ()
    local d = getinfo(3, "S")
    return d and d.what or "C"
  end
  
  mt.__newindex = function (t, n, v)
    if not mt.__declared[n] then
      local w = what()
      if w ~= "main" and w ~= "C" then
        error("assign to undeclared variable '"..n.."'", 2)
      end
      mt.__declared[n] = true
    end
    rawset(t, n, v)
  end
    
  mt.__index = function (t, n)
    if _G[n] then
      return _G[n]
    elseif not mt.__declared[n] and what() ~= "C" then
      error("variable '"..n.."' is not declared", 2)
    else
      return rawget(t, n)
    end
  end

  return setmetatable({}, mt)
end

if dokidoki_disable_debug then
  function make_private_table ()
    return setmetatable({}, {__index = _G})
  end
end

return function (export_defs)
  local private
  local exports = parse_exports(export_defs)

  local function get_module_exports ()
    local exported_values = {}
    for external, internal in pairs(exports) do
      exported_values[external] = private[internal]
    end
    return exported_values
  end

  local function import (t)
    if type(t) == 'string' then t = require(t) end
    for k, v in pairs(t) do
      assert(rawget(private, k) == nil and rawget(_G, k) == nil,
             "import collision for variable " .. k)
      rawset(private, k, v)
    end
  end

  private = make_private_table()
  rawset(private, "_P", private)
  rawset(private, "get_module_exports", get_module_exports)
  rawset(private, "import", import)

  setfenv(2, private)
end
