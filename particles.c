#include <assert.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#ifdef __APPLE__
#include "OpenGL/gl.h"
#include "OpenGL/glu.h"
#else
#include "GL/gl.h"
#include "GL/glu.h"
#endif

#define PARTICLE_COUNT 1000

typedef struct {
    int dead;
} particle_t;

typedef struct {
    int next;
    particle_t particles[PARTICLE_COUNT];
} emitter_t;

static int emitter__draw(lua_State *L)
{
    emitter_t *emitter = luaL_checkudata(L, 1, "particles.emitter");
    //glColor3d(1,1,1);
    //glBegin(GL_QUADS);
    //glVertex2d(0, 0);
    //glVertex2d(100, 0);
    //glVertex2d(100, 100);
    //glVertex2d(0, 100);
    //glEnd();
    //glColor3d(1,1,1);

    return 0;
}

static int emitter__update(lua_State *L)
{
    return 0;
}

static int emitter__add_particle(lua_State *L)
{
    return 0;
}

static int particles__make_emitter(lua_State *L)
{
    emitter_t *emitter = lua_newuserdata(L, sizeof(emitter_t));
    luaL_getmetatable(L, "particles.emitter");
    lua_setmetatable(L, -2);

    emitter->next = 0;
    int i;
    for(i = 0; i < PARTICLE_COUNT; i++)
    {
        emitter->particles[i].dead = 1;
    }

    return 1;
}

static const luaL_reg emitter_lib[] =
{
    {"draw", emitter__draw},
    {"update", emitter__update},
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

