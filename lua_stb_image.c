#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#define STBI_NO_WRITE
#define STBI_NO_HDR
#include "stb_image.c"

static int check_req_comp(lua_State *L, int index)
{
    int req_comp = luaL_optint(L, 2, 0);
    luaL_argcheck(L, 0 <= req_comp && req_comp <= 4, 2,
                  "invalid requested component count");
    return req_comp;
}

static int return_image(lua_State *L, unsigned char * image, int x, int y,
                        int comp, int req_comp)
{
    if(req_comp == 0) req_comp = comp;

    if(image)
    {
        lua_pushlstring(L, (char *)image, x * y * req_comp);
        lua_pushinteger(L, x);
        lua_pushinteger(L, y);
        lua_pushinteger(L, comp);
        stbi_image_free(image);
        return 4;
    }
    else
    {
        lua_pushnil(L);
        lua_pushstring(L, stbi_failure_reason());
        return 2;
    }
}

static int stb_image_load(lua_State *L)
{
    const char * filename = luaL_checkstring(L, 1);
    int req_comp = check_req_comp(L, 2);

    int x, y, comp;
    unsigned char * image = stbi_load(filename, &x, &y, &comp, req_comp);

    return return_image(L, image, x, y, comp, req_comp);
}

static int stb_image_load_from_string(lua_State *L)
{
    size_t source_len;
    const char * source = luaL_checklstring(L, 1, &source_len);
    int req_comp = check_req_comp(L, 2);

    int x, y, comp;
    unsigned char * image = stbi_load_from_memory(
        (unsigned char *)source, source_len, &x, &y, &comp, req_comp);

    return return_image(L, image, x, y, comp, req_comp);
}

static const luaL_Reg stb_image_lib[] =
{
    {"load", stb_image_load},
    {"load_from_string", stb_image_load_from_string},
    {NULL, NULL}
};

int luaopen_stb_image(lua_State *L)
{
    lua_newtable(L);
    luaL_register(L, NULL, stb_image_lib);
    return 1;
}
