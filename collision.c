#include <math.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#define POLY_MT "collision.polygon"

typedef struct {
    lua_Number x;
    lua_Number y;
} vector_s;

typedef struct {
    size_t vertex_count;
    lua_Number bounding_radius;
    vector_s vertices[1];
} polygon_s;

typedef struct {
    vector_s pos;
    vector_s facing;
    polygon_s *poly;
} body_s;

vector_s make_vector(lua_Number x, lua_Number y)
{
    vector_s v;
    v.x = x;
    v.y = y;
    return v;
}

lua_Number vector_magnitude_squared(vector_s v)
{
    return v.x * v.x + v.y * v.y;
}

lua_Number vector_magnitude(vector_s v)
{
    return sqrt(v.x*v.x + v.y * v.y);
}

vector_s vector_neg(vector_s v)
{
    return make_vector(-v.x, -v.y);
}

vector_s vector_mul(vector_s v, lua_Number s)
{
    return make_vector(v.x * s, v.y * s);
}

lua_Number vector_dot(vector_s v1, vector_s v2)
{
    return v1.x * v2.x + v1.y * v2.y;
}

vector_s vector_sub(vector_s v1, vector_s v2)
{
    return make_vector(v1.x - v2.x, v1.y - v2.y);
}

vector_s vector_rotate_to(vector_s v, vector_s facing)
{
    return make_vector(v.x * facing.x + v.y * -facing.y,
                       v.x * facing.y + v.y * facing.x);
}

vector_s vector_rotate_from(vector_s v, vector_s facing)
{
    return make_vector(v.x * facing.x + v.y * facing.y,
                       v.x * -facing.y + v.y * facing.x);
}

int collision_native__make_polygon(lua_State *L)
{
    int vertex_count = lua_objlen(L, 1) / 2;

    polygon_s *poly = (polygon_s *)lua_newuserdata(
        L, sizeof(polygon_s) + (vertex_count - 1) * sizeof(vector_s));
    luaL_getmetatable(L, POLY_MT);
    lua_setmetatable(L, -2);

    poly->vertex_count = vertex_count;
    poly->bounding_radius = 0;
    int i;
    for(i = 0; i < vertex_count; i++)
    {
        lua_rawgeti(L, 1, i*2+1);
        poly->vertices[i].x = lua_tonumber(L, -1);
        lua_rawgeti(L, 1, i*2+2);
        poly->vertices[i].y = lua_tonumber(L, -1);
        lua_pop(L, 2);
        lua_Number mag = vector_magnitude(poly->vertices[i]);
        if(poly->bounding_radius < mag)
            poly->bounding_radius = mag;
    }

    return 1;
}

lua_Number halfwidth_along_axis(vector_s axis, const polygon_s *poly)
{
    lua_Number hw = 0;
    int i;
    for(i = 0; i < poly->vertex_count; i++)
    {
        lua_Number new_hw = vector_dot(poly->vertices[i], axis);
        if(new_hw > hw) hw = new_hw;
    }
    return hw;
}

int separate_by_axis(vector_s axis, lua_Number hw1, const body_s *body1,
                     const body_s *body2, vector_s *out)
{
    //printf("axiss = %lf, %lf\n", axis.x, axis.y);
    lua_Number overlap =
        vector_dot(body1->pos, axis) + hw1 + 
        halfwidth_along_axis(
            vector_neg(vector_rotate_from(axis, body2->facing)),
            body2->poly) -
        vector_dot(body2->pos, axis);
    //printf("overlap = %lf - %lf + %lf - %lf = %lf\n",
    //    vector_dot(body1->pos, axis), hw1,
    //    halfwidth_along_axis(
    //        vector_neg(vector_rotate_from(axis, body2->facing)),
    //        body2->poly),
    //    vector_dot(body2->pos, axis), overlap);
    if(overlap <= 0) return 0;

    vector_s correction =
        vector_mul(axis, overlap/vector_dot(axis, axis));
    if(correction.x == 0 && correction.y == 0) return 0;

    //printf("correction = %lf, %lf\n", correction.x, correction.y);
    if(vector_dot(correction, correction) < vector_dot(*out, *out))
        *out = correction;
    return 1;
}

int separate_by_axes(const body_s *body1, const body_s *body2, vector_s *out)
{
    polygon_s *poly1 = body1->poly;

    int i, j;
    for(i = 0, j = poly1->vertex_count-1; i < poly1->vertex_count; j = i, i++)
    {
        vector_s axis = vector_rotate_to(vector_sub(poly1->vertices[i], poly1->vertices[j]), make_vector(0, -1));
        //printf("axis = %lf, %lf\n", axis.x, axis.y);
        lua_Number hw1 = vector_dot(poly1->vertices[i], axis);
        //printf("body1->facing = %lf, %lf\n", body1->facing.x, body1->facing.y);
        axis = vector_rotate_to(axis, body1->facing);
        if(!separate_by_axis(axis, hw1, body1, body2, out))
            return 0;
    }
    return 1;
}

int collision_native__collide(lua_State *L)
{
    //printf("#### starting\n");
    body_s body1, body2;

    body1.pos.x = luaL_checknumber(L, 1);
    body1.pos.y = luaL_checknumber(L, 2);
    body1.facing.x = luaL_checknumber(L, 3);
    body1.facing.y = luaL_checknumber(L, 4);
    //printf("1body1->facing = %lf, %lf\n", body1.facing.x, body1.facing.y);
    body1.poly = luaL_checkudata(L, 5, POLY_MT);
    body2.pos.x = luaL_checknumber(L, 6);
    body2.pos.y = luaL_checknumber(L, 7);
    body2.facing.x = luaL_checknumber(L, 8);
    body2.facing.y = luaL_checknumber(L, 9);
    body2.poly = luaL_checkudata(L, 10, POLY_MT);

    //printf("pos1 = %lf, %lf\n", body1.pos.x, body1.pos.y);
    //printf("pos2 = %lf, %lf\n", body2.pos.x, body2.pos.y);

    lua_Number bounding_distance =
        body1.poly->bounding_radius + body2.poly->bounding_radius;
    lua_Number distance_squared =
        vector_magnitude_squared(vector_sub(body2.pos, body1.pos));
    if(bounding_distance * bounding_distance < distance_squared)
    {
        //printf("broad phase fail\n");
        lua_pushboolean(L, 0);
        return 1;
    }
    else
    {
        vector_s correction = make_vector(1.0/0.0, 1.0/0.0);

        if(!separate_by_axes(&body1, &body2, &correction) ||
           !separate_by_axes(&body2, &body1, &correction))
        {
            //printf("fine phase fail\n");
            lua_pushboolean(L, 0);
            return 1;
        }

        if(vector_dot(correction, vector_sub(body2.pos, body1.pos)) > 0)
        {
            correction.x = -correction.x;
            correction.y = -correction.y;
        }

        //printf("positive collision %lf, %lf\n", correction.x, correction.y);
        lua_pushboolean(L, 1);
        lua_pushnumber(L, correction.x);
        lua_pushnumber(L, correction.y);
        return 3;
    }
}

static const luaL_Reg collision_native_lib[] =
{
    {"make_polygon", collision_native__make_polygon},
    {"collide", collision_native__collide},
    {NULL, NULL}
};

int luaopen_collision_native(lua_State *L)
{
    luaL_newmetatable(L, POLY_MT);

    lua_newtable(L);
    luaL_register(L, NULL, collision_native_lib);
    return 1;
}
