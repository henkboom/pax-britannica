require "dokidoki.private.strict"

local function match_start (str, pat, i)
  i = i or 1
  local result = {string.match(str, "()" .. pat, i)}
  if result[1] == i then
    return unpack(result, 2)
  else
    return
  end
end

local function parse_exports (export_defs)
  local exports = {}
  local i = 1
  while true do
    local key
    local begin

    local external_name, internal_name
    local i2
    -- parse external name
    external_name, i2 = match_start(export_defs, "%s*([%a_][%w_]*)()", i)
    if i2 ~= nil then i = i2 else break end

    -- parse internal name
    internal_name, i2 = match_start(export_defs, "%s*=%s*([%a_][%w_]*)()", i)
    if i2 ~= nil then i = i2 end

    -- assign it
    assert(exports[external_name] == nil,
           "two module exports with the same name!")
    exports[external_name] = internal_name or external_name

    -- parse comma
    i2 = match_start(export_defs, "%s*,()", i)
    if i2 ~= nil then i = i2 else break end
  end
  i = match_start(export_defs, "%s*()", i)
  assert(i == string.len(export_defs) + 1,
         "invalid exports starting at " .. i)
  
  return exports
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
    for k, v in pairs(t) do
      assert(rawget(private, k) == nil and rawget(_G, k) == nil,
             "import collision for variable " .. k)
      private[k] = v
    end
  end

  private = {get_module_exports = get_module_exports, import = import}
  local private_mt = {__index = _G}

  setmetatable(private, private_mt)
  setfenv(2, private)
end
