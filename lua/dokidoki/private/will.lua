require "dokidoki.module"
[[ attach_will ]]

will_key =
  setmetatable({}, {__tostring = function () return "<private will>" end})

function attach_will(t, fn)
  t[will_key] = make_will(fn)
end

function make_will(fn)
  local will = newproxy(true)
  getmetatable(will).__gc = function () fn() end
  return will
end

return get_module_exports()
