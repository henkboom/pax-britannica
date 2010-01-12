#include <assert.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static int emitter__add_particle(lua_State *L)
{
    return 0;
}

static int particles__make_emitter(lua_State *L)
{
    return 0;
}

static const luaL_reg emitter_lib[] =
{
    {"add_particle", emitter__add_particle},
    {NULL, NULL}
};

static const luaL_Reg particles_lib[] =
{
    {"make_emitter", particles__make_emitter},
    {NULL, NULL}
};

int luaopen_particles(lua_State *L)
{
    luaL_newmetatable(L, "particles.emitter");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_register(L, NULL, emitter_lib);

    lua_newtable(L);
    luaL_register(L, NULL, particles_lib);
    return 1;
}

