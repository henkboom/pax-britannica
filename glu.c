#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#ifdef __APPLE__
#include "OpenGL/gl.h"
#include "OpenGL/glu.h"
#else
#include "GL/gl.h"
#include "GL/glu.h"
#endif

static void * checkpointer(lua_State *L, int num)
{
  void *arg;
  if(lua_islightuserdata(L, num))
    arg = lua_touserdata(L, num);
  else if(lua_isstring(L, num))
    arg = (void *)lua_tostring(L, num);
  else
    luaL_argerror(L, num, "expected lightuserdata or string");
  return arg;
}

struct constant_s {const char *name; int value;};
static struct constant_s constants [] = 
{
  {"GLU_TESS_COMBINE_DATA", 0x1870f},
  {"GLU_TESS_VERTEX", 0x18705},
  {"GLU_TESS_ERROR_DATA", 0x1870d},
  {"GLU_NURBS_ERROR30", 0x187b8},
  {"GLU_NURBS_BEGIN_EXT", 0x18744},
  {"GLU_NURBS_VERTEX_DATA_EXT", 0x1874b},
  {"GLU_NURBS_ERROR35", 0x187bd},
  {"GLU_CCW", 0x18719},
  {"GLU_INVALID_VALUE", 0x18a25},
  {"GLU_VERTEX", 0x18705},
  {"GLU_TESS_ERROR4", 0x1873a},
  {"GLU_EXT_nurbs_tessellator", 0x1},
  {"GLU_TESS_ERROR7", 0x1873d},
  {"GLU_NURBS_ERROR27", 0x187b5},
  {"GLU_TRUE", 0x1},
  {"GLU_NURBS_COLOR", 0x18747},
  {"GLU_V_STEP", 0x1876f},
  {"GLU_NURBS_ERROR14", 0x187a8},
  {"GLU_TESS_VERTEX_DATA", 0x1870b},
  {"GLU_NURBS_ERROR5", 0x1879f},
  {"GLU_TESS_WINDING_RULE", 0x1872c},
  {"GLU_TESS_MISSING_BEGIN_POLYGON", 0x18737},
  {"GLU_NURBS_ERROR29", 0x187b7},
  {"GLU_TESS_TOLERANCE", 0x1872e},
  {"GLU_NURBS_ERROR36", 0x187be},
  {"GLU_FILL", 0x186ac},
  {"GLU_NURBS_ERROR10", 0x187a4},
  {"GLU_EXT_object_space_tess", 0x1},
  {"GLU_NURBS_ERROR17", 0x187ab},
  {"GLU_NURBS_VERTEX_EXT", 0x18745},
  {"GLU_OBJECT_PARAMETRIC_ERROR_EXT", 0x18770},
  {"GLU_TESS_WINDING_ODD", 0x18722},
  {"GLU_VERSION_1_2", 0x1},
  {"GLU_NURBS_ERROR16", 0x187aa},
  {"GLU_NURBS_ERROR8", 0x187a2},
  {"GLU_NURBS_ERROR23", 0x187b1},
  {"GLU_NURBS_ERROR24", 0x187b2},
  {"GLU_OBJECT_PARAMETRIC_ERROR", 0x18770},
  {"GLU_OUTLINE_POLYGON", 0x18790},
  {"GLU_NURBS_NORMAL_EXT", 0x18746},
  {"GLU_NURBS_ERROR19", 0x187ad},
  {"GLU_NURBS_ERROR", 0x18707},
  {"GLU_NURBS_ERROR11", 0x187a5},
  {"GLU_OUTSIDE", 0x186b4},
  {"GLU_NURBS_COLOR_DATA", 0x1874d},
  {"GLU_NURBS_ERROR13", 0x187a7},
  {"GLU_NURBS_END_EXT", 0x18749},
  {"GLU_DISPLAY_MODE", 0x1876c},
  {"GLU_NONE", 0x186a2},
  {"GLU_NURBS_TEXTURE_COORD_DATA", 0x1874e},
  {"GLU_NURBS_ERROR22", 0x187b0},
  {"GLU_TESS_ERROR2", 0x18738},
  {"GLU_NURBS_ERROR20", 0x187ae},
  {"GLU_NURBS_ERROR21", 0x187af},
  {"GLU_NURBS_ERROR1", 0x1879b},
  {"GLU_NURBS_RENDERER", 0x18742},
  {"GLU_NURBS_BEGIN_DATA", 0x1874a},
  {"GLU_PARAMETRIC_TOLERANCE", 0x1876a},
  {"GLU_INCOMPATIBLE_GL_VERSION", 0x18a27},
  {"GLU_NURBS_ERROR4", 0x1879e},
  {"GLU_TESS_ERROR", 0x18707},
  {"GLU_TESS_BOUNDARY_ONLY", 0x1872d},
  {"GLU_FALSE", 0x0},
  {"GLU_NURBS_ERROR28", 0x187b6},
  {"GLU_TESS_END", 0x18706},
  {"GLU_VERSION_1_1", 0x1},
  {"GLU_UNKNOWN", 0x1871c},
  {"GLU_LINE", 0x186ab},
  {"GLU_TESS_MISSING_END_POLYGON", 0x18739},
  {"GLU_SAMPLING_METHOD", 0x1876d},
  {"GLU_INVALID_ENUM", 0x18a24},
  {"GLU_NURBS_VERTEX_DATA", 0x1874b},
  {"GLU_NURBS_ERROR3", 0x1879d},
  {"GLU_NURBS_TEX_COORD_DATA_EXT", 0x1874e},
  {"GLU_NURBS_ERROR6", 0x187a0},
  {"GLU_NURBS_ERROR15", 0x187a9},
  {"GLU_NURBS_END", 0x18749},
  {"GLU_EXTENSIONS", 0x189c1},
  {"GLU_NURBS_ERROR33", 0x187bb},
  {"GLU_DOMAIN_DISTANCE", 0x18779},
  {"GLU_NURBS_END_DATA_EXT", 0x1874f},
  {"GLU_TESS_BEGIN", 0x18704},
  {"GLU_NURBS_COLOR_EXT", 0x18747},
  {"GLU_NURBS_TESSELLATOR", 0x18741},
  {"GLU_NURBS_ERROR31", 0x187b9},
  {"GLU_PATH_LENGTH", 0x18777},
  {"GLU_OBJECT_PATH_LENGTH_EXT", 0x18771},
  {"GLU_OBJECT_PATH_LENGTH", 0x18771},
  {"GLU_SILHOUETTE", 0x186ad},
  {"GLU_NURBS_NORMAL", 0x18746},
  {"GLU_PARAMETRIC_ERROR", 0x18778},
  {"GLU_NURBS_TEXTURE_COORD", 0x18748},
  {"GLU_U_STEP", 0x1876e},
  {"GLU_TESS_WINDING_NEGATIVE", 0x18725},
  {"GLU_NURBS_ERROR32", 0x187ba},
  {"GLU_NURBS_ERROR25", 0x187b3},
  {"GLU_TESS_ERROR3", 0x18739},
  {"GLU_TESS_WINDING_POSITIVE", 0x18724},
  {"GLU_TESS_WINDING_NONZERO", 0x18723},
  {"GLU_NURBS_TEX_COORD_EXT", 0x18748},
  {"GLU_TESS_COORD_TOO_LARGE", 0x1873b},
  {"GLU_TESS_MISSING_END_CONTOUR", 0x1873a},
  {"GLU_NURBS_ERROR26", 0x187b4},
  {"GLU_TESS_ERROR8", 0x1873e},
  {"GLU_NURBS_TESSELLATOR_EXT", 0x18741},
  {"GLU_TESS_ERROR6", 0x1873c},
  {"GLU_BEGIN", 0x18704},
  {"GLU_SMOOTH", 0x186a0},
  {"GLU_TESS_ERROR5", 0x1873b},
  {"GLU_TESS_ERROR1", 0x18737},
  {"GLU_EXTERIOR", 0x1871b},
  {"GLU_TESS_EDGE_FLAG_DATA", 0x1870e},
  {"GLU_INTERIOR", 0x1871a},
  {"GLU_CW", 0x18718},
  {"GLU_NURBS_COLOR_DATA_EXT", 0x1874d},
  {"GLU_MAP1_TRIM_2", 0x18772},
  {"GLU_TESS_BEGIN_DATA", 0x1870a},
  {"GLU_TESS_END_DATA", 0x1870c},
  {"GLU_TESS_COMBINE", 0x18709},
  {"GLU_NURBS_NORMAL_DATA", 0x1874c},
  {"GLU_EDGE_FLAG", 0x18708},
  {"GLU_INVALID_OPERATION", 0x18a28},
  {"GLU_NURBS_ERROR9", 0x187a3},
  {"GLU_CULLING", 0x18769},
  {"GLU_NURBS_ERROR37", 0x187bf},
  {"GLU_NURBS_ERROR7", 0x187a1},
  {"GLU_NURBS_MODE", 0x18740},
  {"GLU_END", 0x18706},
  {"GLU_NURBS_ERROR12", 0x187a6},
  {"GLU_ERROR", 0x18707},
  {"GLU_OUTLINE_PATCH", 0x18791},
  {"GLU_TESS_EDGE_FLAG", 0x18708},
  {"GLU_INSIDE", 0x186b5},
  {"GLU_TESS_MISSING_BEGIN_CONTOUR", 0x18738},
  {"GLU_FLAT", 0x186a1},
  {"GLU_NURBS_VERTEX", 0x18745},
  {"GLU_VERSION_1_3", 0x1},
  {"GLU_NURBS_BEGIN_DATA_EXT", 0x1874a},
  {"GLU_NURBS_END_DATA", 0x1874f},
  {"GLU_TESS_NEED_COMBINE_CALLBACK", 0x1873c},
  {"GLU_POINT", 0x186aa},
  {"GLU_MAP1_TRIM_3", 0x18773},
  {"GLU_SAMPLING_TOLERANCE", 0x1876b},
  {"GLU_NURBS_RENDERER_EXT", 0x18742},
  {"GLU_NURBS_MODE_EXT", 0x18740},
  {"GLU_NURBS_ERROR18", 0x187ac},
  {"GLU_VERSION", 0x189c0},
  {"GLU_NURBS_ERROR2", 0x1879c},
  {"GLU_NURBS_BEGIN", 0x18744},
  {"GLU_AUTO_LOAD_MATRIX", 0x18768},
  {"GLU_NURBS_ERROR34", 0x187bc},
  {"GLU_OUT_OF_MEMORY", 0x18a26},
  {"GLU_TESS_WINDING_ABS_GEQ_TWO", 0x18726},
  {"GLU_NURBS_NORMAL_DATA_EXT", 0x1874c},
  {NULL, 0}
};

static int glu__gluBuild1DMipmaps(lua_State *L)
{
  lua_pushnumber(L, gluBuild1DMipmaps(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    checkpointer(L, 6)));
  return 1;
}

static int glu__gluQuadricDrawStyle(lua_State *L)
{
  gluQuadricDrawStyle(
    checkpointer(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int glu__gluScaleImage(lua_State *L)
{
  lua_pushnumber(L, gluScaleImage(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    checkpointer(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    luaL_checknumber(L, 8),
    checkpointer(L, 9)));
  return 1;
}

static int glu__gluErrorString(lua_State *L)
{
  lua_pushstring(L, gluErrorString(
    luaL_checknumber(L, 1)));
  return 1;
}

static int glu__gluNewNurbsRenderer(lua_State *L)
{
  lua_pushlightuserdata(L, gluNewNurbsRenderer());
  return 1;
}

static int glu__gluBeginTrim(lua_State *L)
{
  gluBeginTrim(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluTessVertex(lua_State *L)
{
  gluTessVertex(
    checkpointer(L, 1),
    checkpointer(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int glu__gluNurbsCallback(lua_State *L)
{
  gluNurbsCallback(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int glu__gluGetTessProperty(lua_State *L)
{
  gluGetTessProperty(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int glu__gluEndPolygon(lua_State *L)
{
  gluEndPolygon(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluEndSurface(lua_State *L)
{
  gluEndSurface(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluPartialDisk(lua_State *L)
{
  gluPartialDisk(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7));
  return 0;
}

static int glu__gluTessCallback(lua_State *L)
{
  gluTessCallback(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int glu__gluNextContour(lua_State *L)
{
  gluNextContour(
    checkpointer(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int glu__gluDeleteNurbsRenderer(lua_State *L)
{
  gluDeleteNurbsRenderer(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluQuadricNormals(lua_State *L)
{
  gluQuadricNormals(
    checkpointer(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int glu__gluBuild2DMipmaps(lua_State *L)
{
  lua_pushnumber(L, gluBuild2DMipmaps(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    checkpointer(L, 7)));
  return 1;
}

static int glu__gluEndCurve(lua_State *L)
{
  gluEndCurve(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluLookAt(lua_State *L)
{
  gluLookAt(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    luaL_checknumber(L, 8),
    luaL_checknumber(L, 9));
  return 0;
}

static int glu__gluTessBeginContour(lua_State *L)
{
  gluTessBeginContour(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluBeginSurface(lua_State *L)
{
  gluBeginSurface(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluQuadricTexture(lua_State *L)
{
  gluQuadricTexture(
    checkpointer(L, 1),
    lua_toboolean(L, 2));
  return 0;
}

static int glu__gluNurbsCurve(lua_State *L)
{
  gluNurbsCurve(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3),
    luaL_checknumber(L, 4),
    checkpointer(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7));
  return 0;
}

static int glu__gluBeginPolygon(lua_State *L)
{
  gluBeginPolygon(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluTessProperty(lua_State *L)
{
  gluTessProperty(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int glu__gluNewTess(lua_State *L)
{
  lua_pushlightuserdata(L, gluNewTess());
  return 1;
}

static int glu__gluTessNormal(lua_State *L)
{
  gluTessNormal(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int glu__gluPickMatrix(lua_State *L)
{
  gluPickMatrix(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    checkpointer(L, 5));
  return 0;
}

static int glu__gluPerspective(lua_State *L)
{
  gluPerspective(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int glu__gluEndTrim(lua_State *L)
{
  gluEndTrim(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluPwlCurve(lua_State *L)
{
  gluPwlCurve(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5));
  return 0;
}

static int glu__gluTessEndPolygon(lua_State *L)
{
  gluTessEndPolygon(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluTessEndContour(lua_State *L)
{
  gluTessEndContour(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluNewQuadric(lua_State *L)
{
  lua_pushlightuserdata(L, gluNewQuadric());
  return 1;
}

static int glu__gluTessBeginPolygon(lua_State *L)
{
  gluTessBeginPolygon(
    checkpointer(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int glu__gluSphere(lua_State *L)
{
  gluSphere(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int glu__gluQuadricOrientation(lua_State *L)
{
  gluQuadricOrientation(
    checkpointer(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int glu__gluLoadSamplingMatrices(lua_State *L)
{
  gluLoadSamplingMatrices(
    checkpointer(L, 1),
    checkpointer(L, 2),
    checkpointer(L, 3),
    checkpointer(L, 4));
  return 0;
}

static int glu__gluBeginCurve(lua_State *L)
{
  gluBeginCurve(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluProject(lua_State *L)
{
  lua_pushnumber(L, gluProject(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    checkpointer(L, 4),
    checkpointer(L, 5),
    checkpointer(L, 6),
    checkpointer(L, 7),
    checkpointer(L, 8),
    checkpointer(L, 9)));
  return 1;
}

static int glu__gluUnProject(lua_State *L)
{
  lua_pushnumber(L, gluUnProject(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    checkpointer(L, 4),
    checkpointer(L, 5),
    checkpointer(L, 6),
    checkpointer(L, 7),
    checkpointer(L, 8),
    checkpointer(L, 9)));
  return 1;
}

static int glu__gluOrtho2D(lua_State *L)
{
  gluOrtho2D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int glu__gluDeleteQuadric(lua_State *L)
{
  gluDeleteQuadric(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluNurbsSurface(lua_State *L)
{
  gluNurbsSurface(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3),
    luaL_checknumber(L, 4),
    checkpointer(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    checkpointer(L, 8),
    luaL_checknumber(L, 9),
    luaL_checknumber(L, 10),
    luaL_checknumber(L, 11));
  return 0;
}

static int glu__gluNurbsProperty(lua_State *L)
{
  gluNurbsProperty(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int glu__gluGetString(lua_State *L)
{
  lua_pushstring(L, gluGetString(
    luaL_checknumber(L, 1)));
  return 1;
}

static int glu__gluDeleteTess(lua_State *L)
{
  gluDeleteTess(
    checkpointer(L, 1));
  return 0;
}

static int glu__gluDisk(lua_State *L)
{
  gluDisk(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5));
  return 0;
}

static int glu__gluCylinder(lua_State *L)
{
  gluCylinder(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6));
  return 0;
}

static int glu__gluQuadricCallback(lua_State *L)
{
  gluQuadricCallback(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int glu__gluGetNurbsProperty(lua_State *L)
{
  gluGetNurbsProperty(
    checkpointer(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static const luaL_Reg functions [] = 
{
  {"gluBuild1DMipmaps", glu__gluBuild1DMipmaps},
  {"gluQuadricDrawStyle", glu__gluQuadricDrawStyle},
  {"gluScaleImage", glu__gluScaleImage},
  {"gluErrorString", glu__gluErrorString},
  {"gluNewNurbsRenderer", glu__gluNewNurbsRenderer},
  {"gluBeginTrim", glu__gluBeginTrim},
  {"gluTessVertex", glu__gluTessVertex},
  {"gluNurbsCallback", glu__gluNurbsCallback},
  {"gluGetTessProperty", glu__gluGetTessProperty},
  {"gluEndPolygon", glu__gluEndPolygon},
  {"gluEndSurface", glu__gluEndSurface},
  {"gluPartialDisk", glu__gluPartialDisk},
  {"gluTessCallback", glu__gluTessCallback},
  {"gluNextContour", glu__gluNextContour},
  {"gluDeleteNurbsRenderer", glu__gluDeleteNurbsRenderer},
  {"gluQuadricNormals", glu__gluQuadricNormals},
  {"gluBuild2DMipmaps", glu__gluBuild2DMipmaps},
  {"gluEndCurve", glu__gluEndCurve},
  {"gluLookAt", glu__gluLookAt},
  {"gluTessBeginContour", glu__gluTessBeginContour},
  {"gluBeginSurface", glu__gluBeginSurface},
  {"gluQuadricTexture", glu__gluQuadricTexture},
  {"gluNurbsCurve", glu__gluNurbsCurve},
  {"gluBeginPolygon", glu__gluBeginPolygon},
  {"gluTessProperty", glu__gluTessProperty},
  {"gluNewTess", glu__gluNewTess},
  {"gluTessNormal", glu__gluTessNormal},
  {"gluPickMatrix", glu__gluPickMatrix},
  {"gluPerspective", glu__gluPerspective},
  {"gluEndTrim", glu__gluEndTrim},
  {"gluPwlCurve", glu__gluPwlCurve},
  {"gluTessEndPolygon", glu__gluTessEndPolygon},
  {"gluTessEndContour", glu__gluTessEndContour},
  {"gluNewQuadric", glu__gluNewQuadric},
  {"gluTessBeginPolygon", glu__gluTessBeginPolygon},
  {"gluSphere", glu__gluSphere},
  {"gluQuadricOrientation", glu__gluQuadricOrientation},
  {"gluLoadSamplingMatrices", glu__gluLoadSamplingMatrices},
  {"gluBeginCurve", glu__gluBeginCurve},
  {"gluProject", glu__gluProject},
  {"gluUnProject", glu__gluUnProject},
  {"gluOrtho2D", glu__gluOrtho2D},
  {"gluDeleteQuadric", glu__gluDeleteQuadric},
  {"gluNurbsSurface", glu__gluNurbsSurface},
  {"gluNurbsProperty", glu__gluNurbsProperty},
  {"gluGetString", glu__gluGetString},
  {"gluDeleteTess", glu__gluDeleteTess},
  {"gluDisk", glu__gluDisk},
  {"gluCylinder", glu__gluCylinder},
  {"gluQuadricCallback", glu__gluQuadricCallback},
  {"gluGetNurbsProperty", glu__gluGetNurbsProperty},
  {NULL, NULL}
};

int luaopen_glu(lua_State *L)
{
  lua_newtable(L);
  
  struct constant_s *c = constants;
  while(c->name)
  {
    lua_pushnumber(L, c->value);
    lua_setfield(L, -2, c->name);
    c++;
  }
  luaL_register(L, NULL, functions);
  return 1;
}
