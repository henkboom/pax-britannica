#!/usr/bin/env lua

modulename = ...
assert(modulename)

dash = modulename:find('%-')
cname = modulename:sub((dash or 0)+1):gsub('%.', '_')
functionname = 'luaopen_' .. cname

io.write('#include <lua.h>\n')
io.write('#include <lauxlib.h>\n')

io.write('int ' .. functionname .. '(lua_State *L){\n')

size = 0
io.write('    static const char data[] = {')
for c in function () return io.read(1) end do
  io.write(c:byte() .. ',')
  size = size + 1
end
io.write('0};\n')

io.write([[
    luaL_loadbuffer(L, data, ]] .. size .. [[, "]] .. modulename .. [[") && lua_error(L);
    lua_call(L, 0, 1);
    return 1;
}]])
