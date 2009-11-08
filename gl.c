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
  {"GL_LUMINANCE12_ALPHA12", 0x8047},
  {"GL_COMPILE_AND_EXECUTE", 0x1301},
  {"GL_RGB16", 0x8054},
  {"GL_CLAMP", 0x2900},
  {"GL_MODULATE", 0x2100},
  {"GL_ALPHA12", 0x803d},
  {"GL_UNSIGNED_SHORT", 0x1403},
  {"GL_STENCIL_FUNC", 0xb92},
  {"GL_COLOR_INDEX", 0x1900},
  {"GL_TEXTURE_ENV_COLOR", 0x2201},
  {"GL_DECAL", 0x2101},
  {"GL_VERSION", 0x1f02},
  {"GL_BLEND", 0xbe2},
  {"GL_SCISSOR_BIT", 0x80000},
  {"GL_CLIENT_VERTEX_ARRAY_BIT", 0x2},
  {"GL_UNPACK_SKIP_ROWS", 0xcf3},
  {"GL_EYE_PLANE", 0x2502},
  {"GL_RGBA8", 0x8058},
  {"GL_OBJECT_PLANE", 0x2501},
  {"GL_LIGHTING", 0xb50},
  {"GL_MAP1_TEXTURE_COORD_4", 0xd96},
  {"GL_LIST_MODE", 0xb30},
  {"GL_DOUBLEBUFFER", 0xc32},
  {"GL_LUMINANCE12_ALPHA4", 0x8046},
  {"GL_ACCUM_BLUE_BITS", 0xd5a},
  {"GL_ACCUM", 0x100},
  {"GL_CLEAR", 0x1500},
  {"GL_RIGHT", 0x407},
  {"GL_3D_COLOR_TEXTURE", 0x603},
  {"GL_NEAREST", 0x2600},
  {"GL_FALSE", 0x0},
  {"GL_CURRENT_RASTER_COLOR", 0xb04},
  {"GL_COPY_INVERTED", 0x150c},
  {"GL_TEXTURE_WRAP_S", 0x2802},
  {"GL_2D", 0x600},
  {"GL_HINT_BIT", 0x8000},
  {"GL_ZOOM_X", 0xd16},
  {"GL_T4F_V4F", 0x2a28},
  {"GL_VERTEX_ARRAY_STRIDE", 0x807c},
  {"GL_ALWAYS", 0x207},
  {"GL_MODELVIEW", 0x1700},
  {"GL_LIGHT6", 0x4006},
  {"GL_LOAD", 0x101},
  {"GL_INDEX_LOGIC_OP", 0xbf1},
  {"GL_NAND", 0x150e},
  {"GL_STENCIL_FAIL", 0xb94},
  {"GL_ONE_MINUS_SRC_COLOR", 0x301},
  {"GL_POLYGON_OFFSET_LINE", 0x2a02},
  {"GL_KEEP", 0x1e00},
  {"GL_PIXEL_MAP_I_TO_I_SIZE", 0xcb0},
  {"GL_PROXY_TEXTURE_1D", 0x8063},
  {"GL_PIXEL_MAP_I_TO_A", 0xc75},
  {"GL_AND_INVERTED", 0x1504},
  {"GL_NO_ERROR", 0x0},
  {"GL_AND", 0x1501},
  {"GL_TEXTURE_ENV_MODE", 0x2200},
  {"GL_AND_REVERSE", 0x1502},
  {"GL_ZERO", 0x0},
  {"GL_FOG_COLOR", 0xb66},
  {"GL_DOUBLE", 0x140a},
  {"GL_LESS", 0x201},
  {"GL_COLOR_CLEAR_VALUE", 0xc22},
  {"GL_TEXTURE_MAG_FILTER", 0x2800},
  {"GL_MAP_COLOR", 0xd10},
  {"GL_C4UB_V2F", 0x2a22},
  {"GL_VIEWPORT_BIT", 0x800},
  {"GL_ALL_CLIENT_ATTRIB_BITS", 0xffffffff},
  {"GL_RGBA12", 0x805a},
  {"GL_POINT", 0x1b00},
  {"GL_PACK_ROW_LENGTH", 0xd02},
  {"GL_INTENSITY4", 0x804a},
  {"GL_FOG_START", 0xb63},
  {"GL_SMOOTH", 0x1d01},
  {"GL_POLYGON_MODE", 0xb40},
  {"GL_LINE_STIPPLE_PATTERN", 0xb25},
  {"GL_ONE_MINUS_DST_ALPHA", 0x305},
  {"GL_MAP1_TEXTURE_COORD_1", 0xd93},
  {"GL_CURRENT_RASTER_TEXTURE_COORDS", 0xb06},
  {"GL_NEAREST_MIPMAP_LINEAR", 0x2702},
  {"GL_UNPACK_SKIP_PIXELS", 0xcf4},
  {"GL_T2F_N3F_V3F", 0x2a2b},
  {"GL_PACK_ALIGNMENT", 0xd05},
  {"GL_C3F_V3F", 0x2a24},
  {"GL_LEQUAL", 0x203},
  {"GL_EXTENSIONS", 0x1f03},
  {"GL_CURRENT_RASTER_INDEX", 0xb05},
  {"GL_COLOR_MATERIAL_PARAMETER", 0xb56},
  {"GL_ALPHA_BIAS", 0xd1d},
  {"GL_LINE_WIDTH_RANGE", 0xb22},
  {"GL_MAP1_INDEX", 0xd91},
  {"GL_FOG_INDEX", 0xb61},
  {"GL_FEEDBACK_BUFFER_SIZE", 0xdf1},
  {"GL_CURRENT_COLOR", 0xb00},
  {"GL_GREEN", 0x1904},
  {"GL_POINT_SIZE_GRANULARITY", 0xb13},
  {"GL_FEEDBACK_BUFFER_TYPE", 0xdf2},
  {"GL_COLOR_MATERIAL", 0xb57},
  {"GL_CLIP_PLANE1", 0x3001},
  {"GL_SPOT_EXPONENT", 0x1205},
  {"GL_LINEAR_MIPMAP_LINEAR", 0x2703},
  {"GL_COLOR", 0x1800},
  {"GL_LUMINANCE16_ALPHA16", 0x8048},
  {"GL_TRIANGLE_STRIP", 0x5},
  {"GL_MAX_PROJECTION_STACK_DEPTH", 0xd38},
  {"GL_TEXTURE_MIN_FILTER", 0x2801},
  {"GL_GREATER", 0x204},
  {"GL_OR_INVERTED", 0x150d},
  {"GL_INDEX_SHIFT", 0xd12},
  {"GL_FOG", 0xb60},
  {"GL_POINTS", 0x0},
  {"GL_FRONT_LEFT", 0x400},
  {"GL_DEPTH_WRITEMASK", 0xb72},
  {"GL_PIXEL_MAP_I_TO_A_SIZE", 0xcb5},
  {"GL_LUMINANCE8", 0x8040},
  {"GL_ALPHA_BITS", 0xd55},
  {"GL_PROJECTION", 0x1701},
  {"GL_STENCIL_TEST", 0xb90},
  {"GL_INDEX_CLEAR_VALUE", 0xc20},
  {"GL_POINT_TOKEN", 0x701},
  {"GL_PROJECTION_STACK_DEPTH", 0xba4},
  {"GL_TEXTURE_BLUE_SIZE", 0x805e},
  {"GL_VERSION_1_1", 0x1},
  {"GL_STENCIL_PASS_DEPTH_PASS", 0xb96},
  {"GL_DRAW_BUFFER", 0xc01},
  {"GL_SHORT", 0x1402},
  {"GL_LIGHT7", 0x4007},
  {"GL_FLOAT", 0x1406},
  {"GL_LUMINANCE8_ALPHA8", 0x8045},
  {"GL_SCISSOR_BOX", 0xc10},
  {"GL_INTENSITY12", 0x804c},
  {"GL_TEXTURE_GREEN_SIZE", 0x805d},
  {"GL_FOG_DENSITY", 0xb62},
  {"GL_LINEAR", 0x2601},
  {"GL_ONE_MINUS_DST_COLOR", 0x307},
  {"GL_LEFT", 0x406},
  {"GL_MAP_STENCIL", 0xd11},
  {"GL_STENCIL_VALUE_MASK", 0xb93},
  {"GL_PIXEL_MAP_R_TO_R_SIZE", 0xcb6},
  {"GL_FOG_HINT", 0xc54},
  {"GL_NONE", 0x0},
  {"GL_NOR", 0x1508},
  {"GL_LINE_SMOOTH", 0xb20},
  {"GL_INDEX_BITS", 0xd51},
  {"GL_LIGHT_MODEL_TWO_SIDE", 0xb52},
  {"GL_PERSPECTIVE_CORRECTION_HINT", 0xc50},
  {"GL_NORMAL_ARRAY_POINTER", 0x808f},
  {"GL_TEXTURE_COORD_ARRAY_TYPE", 0x8089},
  {"GL_POLYGON_SMOOTH", 0xb41},
  {"GL_CLIP_PLANE5", 0x3005},
  {"GL_NORMAL_ARRAY", 0x8075},
  {"GL_POLYGON_OFFSET_FACTOR", 0x8038},
  {"GL_RGB10_A2", 0x8059},
  {"GL_SHININESS", 0x1601},
  {"GL_ENABLE_BIT", 0x2000},
  {"GL_POSITION", 0x1203},
  {"GL_MULT", 0x103},
  {"GL_DEPTH_TEST", 0xb71},
  {"GL_SPOT_DIRECTION", 0x1204},
  {"GL_RGBA_MODE", 0xc31},
  {"GL_STENCIL_BITS", 0xd57},
  {"GL_CLIP_PLANE3", 0x3003},
  {"GL_LIST_BASE", 0xb32},
  {"GL_PIXEL_MAP_I_TO_R", 0xc72},
  {"GL_CCW", 0x901},
  {"GL_MAX_MODELVIEW_STACK_DEPTH", 0xd36},
  {"GL_T2F_C4F_N3F_V3F", 0x2a2c},
  {"GL_OR_REVERSE", 0x150b},
  {"GL_BACK_LEFT", 0x402},
  {"GL_MAP1_COLOR_4", 0xd90},
  {"GL_DST_ALPHA", 0x304},
  {"GL_FRONT", 0x404},
  {"GL_STENCIL_PASS_DEPTH_FAIL", 0xb95},
  {"GL_BLUE_BIAS", 0xd1b},
  {"GL_Q", 0x2003},
  {"GL_STENCIL", 0x1802},
  {"GL_CURRENT_RASTER_DISTANCE", 0xb09},
  {"GL_MAX_EVAL_ORDER", 0xd30},
  {"GL_MAP1_TEXTURE_COORD_3", 0xd95},
  {"GL_MAP1_TEXTURE_COORD_2", 0xd94},
  {"GL_V3F", 0x2a21},
  {"GL_SRC_ALPHA", 0x302},
  {"GL_PIXEL_MAP_I_TO_B", 0xc74},
  {"GL_PIXEL_MAP_I_TO_G_SIZE", 0xcb3},
  {"GL_POLYGON_OFFSET_UNITS", 0x2a00},
  {"GL_UNSIGNED_INT", 0x1405},
  {"GL_CURRENT_RASTER_POSITION_VALID", 0xb08},
  {"GL_LIST_BIT", 0x20000},
  {"GL_SELECTION_BUFFER_POINTER", 0xdf3},
  {"GL_TEXTURE_GEN_Q", 0xc63},
  {"GL_VIEWPORT", 0xba2},
  {"GL_GREEN_SCALE", 0xd18},
  {"GL_GREEN_BITS", 0xd53},
  {"GL_INDEX_WRITEMASK", 0xc21},
  {"GL_T2F_V3F", 0x2a27},
  {"GL_RED_SCALE", 0xd14},
  {"GL_POINT_SIZE_RANGE", 0xb12},
  {"GL_SET", 0x150f},
  {"GL_CLIENT_ALL_ATTRIB_BITS", 0xffffffff},
  {"GL_ADD", 0x104},
  {"GL_FASTEST", 0x1101},
  {"GL_EDGE_FLAG_ARRAY_STRIDE", 0x808c},
  {"GL_AMBIENT", 0x1200},
  {"GL_C4UB_V3F", 0x2a23},
  {"GL_EQUAL", 0x202},
  {"GL_T4F_C4F_N3F_V4F", 0x2a2d},
  {"GL_ONE_MINUS_SRC_ALPHA", 0x303},
  {"GL_DITHER", 0xbd0},
  {"GL_SPOT_CUTOFF", 0x1206},
  {"GL_TEXTURE_COORD_ARRAY_STRIDE", 0x808a},
  {"GL_TEXTURE_WIDTH", 0x1000},
  {"GL_PIXEL_MAP_I_TO_R_SIZE", 0xcb2},
  {"GL_MODELVIEW_MATRIX", 0xba6},
  {"GL_LUMINANCE12", 0x8041},
  {"GL_T2F_C4UB_V3F", 0x2a29},
  {"GL_T", 0x2001},
  {"GL_STACK_UNDERFLOW", 0x504},
  {"GL_LINES", 0x1},
  {"GL_ALPHA4", 0x803b},
  {"GL_TEXTURE_MATRIX", 0xba8},
  {"GL_CLIENT_PIXEL_STORE_BIT", 0x1},
  {"GL_FRONT_RIGHT", 0x401},
  {"GL_COMPILE", 0x1300},
  {"GL_INDEX_ARRAY_STRIDE", 0x8086},
  {"GL_COLOR_ARRAY_SIZE", 0x8081},
  {"GL_MAX_NAME_STACK_DEPTH", 0xd37},
  {"GL_AMBIENT_AND_DIFFUSE", 0x1602},
  {"GL_MAX_TEXTURE_STACK_DEPTH", 0xd39},
  {"GL_PIXEL_MAP_S_TO_S", 0xc71},
  {"GL_COEFF", 0xa00},
  {"GL_PACK_SWAP_BYTES", 0xd00},
  {"GL_CURRENT_NORMAL", 0xb02},
  {"GL_NEAREST_MIPMAP_NEAREST", 0x2700},
  {"GL_TEXTURE_BORDER_COLOR", 0x1004},
  {"GL_FLAT", 0x1d00},
  {"GL_TEXTURE_BINDING_2D", 0x8069},
  {"GL_LINE_LOOP", 0x2},
  {"GL_QUAD_STRIP", 0x8},
  {"GL_PROXY_TEXTURE_2D", 0x8064},
  {"GL_FEEDBACK_BUFFER_POINTER", 0xdf0},
  {"GL_ALL_ATTRIB_BITS", 0xfffff},
  {"GL_NAME_STACK_DEPTH", 0xd70},
  {"GL_VERTEX_ARRAY", 0x8074},
  {"GL_DIFFUSE", 0x1201},
  {"GL_PIXEL_MAP_R_TO_R", 0xc76},
  {"GL_CLIP_PLANE0", 0x3000},
  {"GL_MAX_VIEWPORT_DIMS", 0xd3a},
  {"GL_N3F_V3F", 0x2a25},
  {"GL_CLIP_PLANE2", 0x3002},
  {"GL_EDGE_FLAG_ARRAY_POINTER", 0x8093},
  {"GL_TEXTURE_GEN_MODE", 0x2500},
  {"GL_ATTRIB_STACK_DEPTH", 0xbb0},
  {"GL_MAP2_TEXTURE_COORD_2", 0xdb4},
  {"GL_STENCIL_REF", 0xb97},
  {"GL_BLEND_DST", 0xbe0},
  {"GL_REPLACE", 0x1e01},
  {"GL_REPEAT", 0x2901},
  {"GL_V2F", 0x2a20},
  {"GL_BLUE_SCALE", 0xd1a},
  {"GL_MAP1_VERTEX_4", 0xd98},
  {"GL_PIXEL_MAP_I_TO_G", 0xc73},
  {"GL_TEXTURE_LUMINANCE_SIZE", 0x8060},
  {"GL_PIXEL_MAP_G_TO_G", 0xc77},
  {"GL_CW", 0x900},
  {"GL_ALPHA8", 0x803c},
  {"GL_TEXTURE_RESIDENT", 0x8067},
  {"GL_COPY", 0x1503},
  {"GL_DEPTH_CLEAR_VALUE", 0xb73},
  {"GL_SPECULAR", 0x1202},
  {"GL_VERTEX_ARRAY_POINTER", 0x808e},
  {"GL_TEXTURE_GEN_S", 0xc60},
  {"GL_POLYGON_STIPPLE", 0xb42},
  {"GL_STENCIL_CLEAR_VALUE", 0xb91},
  {"GL_3D_COLOR", 0x602},
  {"GL_MAP2_GRID_DOMAIN", 0xdd2},
  {"GL_FILL", 0x1b02},
  {"GL_INDEX_ARRAY_TYPE", 0x8085},
  {"GL_3D", 0x601},
  {"GL_CULL_FACE_MODE", 0xb45},
  {"GL_BYTE", 0x1400},
  {"GL_OR", 0x1507},
  {"GL_ACCUM_GREEN_BITS", 0xd59},
  {"GL_PROJECTION_MATRIX", 0xba7},
  {"GL_SRC_ALPHA_SATURATE", 0x308},
  {"GL_EXP", 0x800},
  {"GL_LINE_SMOOTH_HINT", 0xc52},
  {"GL_POINT_BIT", 0x2},
  {"GL_TRUE", 0x1},
  {"GL_COPY_PIXEL_TOKEN", 0x706},
  {"GL_4_BYTES", 0x1409},
  {"GL_UNPACK_LSB_FIRST", 0xcf1},
  {"GL_DEPTH", 0x1801},
  {"GL_DST_COLOR", 0x306},
  {"GL_RGBA", 0x1908},
  {"GL_MAP2_VERTEX_4", 0xdb8},
  {"GL_EMISSION", 0x1600},
  {"GL_COLOR_ARRAY_POINTER", 0x8090},
  {"GL_DEPTH_SCALE", 0xd1e},
  {"GL_MAX_LIGHTS", 0xd31},
  {"GL_OBJECT_LINEAR", 0x2401},
  {"GL_ALPHA_SCALE", 0xd1c},
  {"GL_INDEX_MODE", 0xc30},
  {"GL_NOTEQUAL", 0x205},
  {"GL_CURRENT_RASTER_POSITION", 0xb07},
  {"GL_LIGHT4", 0x4004},
  {"GL_MAP2_TEXTURE_COORD_1", 0xdb3},
  {"GL_INDEX_ARRAY_POINTER", 0x8091},
  {"GL_LIGHT0", 0x4000},
  {"GL_COLOR_ARRAY_STRIDE", 0x8083},
  {"GL_RGB10", 0x8052},
  {"GL_MAP1_VERTEX_3", 0xd97},
  {"GL_LINE_TOKEN", 0x702},
  {"GL_UNPACK_ALIGNMENT", 0xcf5},
  {"GL_RED_BITS", 0xd52},
  {"GL_TEXTURE_HEIGHT", 0x1001},
  {"GL_ACCUM_BUFFER_BIT", 0x200},
  {"GL_MAP1_GRID_DOMAIN", 0xdd0},
  {"GL_ALPHA16", 0x803e},
  {"GL_POINT_SMOOTH_HINT", 0xc51},
  {"GL_VENDOR", 0x1f00},
  {"GL_MAX_PIXEL_MAP_TABLE", 0xd34},
  {"GL_ACCUM_RED_BITS", 0xd58},
  {"GL_CLIENT_ATTRIB_STACK_DEPTH", 0xbb1},
  {"GL_RGBA16", 0x805b},
  {"GL_RGB5_A1", 0x8057},
  {"GL_LIGHT3", 0x4003},
  {"GL_LIGHT1", 0x4001},
  {"GL_RGBA4", 0x8056},
  {"GL_DEPTH_BUFFER_BIT", 0x100},
  {"GL_RGBA2", 0x8055},
  {"GL_RGB", 0x1907},
  {"GL_PIXEL_MAP_S_TO_S_SIZE", 0xcb1},
  {"GL_PIXEL_MAP_B_TO_B", 0xc78},
  {"GL_RGB8", 0x8051},
  {"GL_RGB5", 0x8050},
  {"GL_PACK_SKIP_PIXELS", 0xd04},
  {"GL_BITMAP_TOKEN", 0x704},
  {"GL_DEPTH_BIAS", 0xd1f},
  {"GL_CULL_FACE", 0xb44},
  {"GL_MODELVIEW_STACK_DEPTH", 0xba3},
  {"GL_INTENSITY16", 0x804d},
  {"GL_ALPHA_TEST", 0xbc0},
  {"GL_LINE_WIDTH", 0xb21},
  {"GL_INTENSITY", 0x8049},
  {"GL_PIXEL_MAP_A_TO_A", 0xc79},
  {"GL_BLUE", 0x1905},
  {"GL_COLOR_ARRAY", 0x8076},
  {"GL_DECR", 0x1e03},
  {"GL_DEPTH_BITS", 0xd56},
  {"GL_PIXEL_MAP_I_TO_I", 0xc70},
  {"GL_POLYGON_STIPPLE_BIT", 0x10},
  {"GL_ORDER", 0xa01},
  {"GL_INCR", 0x1e02},
  {"GL_LUMINANCE16", 0x8042},
  {"GL_BACK_RIGHT", 0x403},
  {"GL_READ_BUFFER", 0xc02},
  {"GL_LUMINANCE6_ALPHA2", 0x8044},
  {"GL_RED_BIAS", 0xd15},
  {"GL_LUMINANCE4_ALPHA4", 0x8043},
  {"GL_MAP1_NORMAL", 0xd92},
  {"GL_EXP2", 0x801},
  {"GL_LINE_STIPPLE_REPEAT", 0xb26},
  {"GL_PIXEL_MAP_G_TO_G_SIZE", 0xcb7},
  {"GL_BITMAP", 0x1a00},
  {"GL_AUX3", 0x40c},
  {"GL_LUMINANCE4", 0x803f},
  {"GL_GEQUAL", 0x206},
  {"GL_TEXTURE_INTERNAL_FORMAT", 0x1003},
  {"GL_DEPTH_COMPONENT", 0x1902},
  {"GL_POLYGON_BIT", 0x8},
  {"GL_TEXTURE_BINDING_1D", 0x8068},
  {"GL_FOG_BIT", 0x80},
  {"GL_ONE", 0x1},
  {"GL_LINE_STRIP", 0x3},
  {"GL_LOGIC_OP_MODE", 0xbf0},
  {"GL_FEEDBACK", 0x1c01},
  {"GL_TEXTURE_PRIORITY", 0x8066},
  {"GL_TEXTURE_COORD_ARRAY_POINTER", 0x8092},
  {"GL_TEXTURE_ENV", 0x2300},
  {"GL_TEXTURE_BIT", 0x40000},
  {"GL_POINT_SIZE", 0xb11},
  {"GL_UNPACK_ROW_LENGTH", 0xcf2},
  {"GL_EVAL_BIT", 0x10000},
  {"GL_STENCIL_INDEX", 0x1901},
  {"GL_SCISSOR_TEST", 0xc11},
  {"GL_BACK", 0x405},
  {"GL_ALPHA_TEST_REF", 0xbc2},
  {"GL_COLOR_BUFFER_BIT", 0x4000},
  {"GL_STACK_OVERFLOW", 0x503},
  {"GL_MAX_ATTRIB_STACK_DEPTH", 0xd35},
  {"GL_RENDER", 0x1c00},
  {"GL_TRANSFORM_BIT", 0x1000},
  {"GL_TRIANGLE_FAN", 0x6},
  {"GL_FRONT_FACE", 0xb46},
  {"GL_STENCIL_BUFFER_BIT", 0x400},
  {"GL_FOG_END", 0xb64},
  {"GL_PIXEL_MODE_BIT", 0x20},
  {"GL_AUX0", 0x409},
  {"GL_UNSIGNED_BYTE", 0x1401},
  {"GL_LINE_RESET_TOKEN", 0x707},
  {"GL_LUMINANCE_ALPHA", 0x190a},
  {"GL_DOMAIN", 0xa02},
  {"GL_LINE_BIT", 0x4},
  {"GL_NOOP", 0x1505},
  {"GL_POINT_SMOOTH", 0xb10},
  {"GL_4D_COLOR_TEXTURE", 0x604},
  {"GL_ACCUM_ALPHA_BITS", 0xd5b},
  {"GL_CURRENT_BIT", 0x1},
  {"GL_NORMAL_ARRAY_STRIDE", 0x807f},
  {"GL_OUT_OF_MEMORY", 0x505},
  {"GL_LINE", 0x1b01},
  {"GL_PIXEL_MAP_I_TO_B_SIZE", 0xcb4},
  {"GL_CURRENT_INDEX", 0xb01},
  {"GL_MAP2_INDEX", 0xdb1},
  {"GL_2_BYTES", 0x1407},
  {"GL_AUX_BUFFERS", 0xc00},
  {"GL_INVERT", 0x150a},
  {"GL_INVALID_OPERATION", 0x502},
  {"GL_INVALID_VALUE", 0x501},
  {"GL_INVALID_ENUM", 0x500},
  {"GL_MAP1_GRID_SEGMENTS", 0xdd1},
  {"GL_RGB12", 0x8053},
  {"GL_NICEST", 0x1102},
  {"GL_RENDERER", 0x1f01},
  {"GL_RETURN", 0x102},
  {"GL_LIGHT_MODEL_AMBIENT", 0xb53},
  {"GL_TEXTURE", 0x1702},
  {"GL_LUMINANCE", 0x1909},
  {"GL_TEXTURE_GEN_T", 0xc61},
  {"GL_INTENSITY8", 0x804b},
  {"GL_DONT_CARE", 0x1100},
  {"GL_INDEX_ARRAY", 0x8077},
  {"GL_BLEND_SRC", 0xbe1},
  {"GL_TEXTURE_GEN_R", 0xc62},
  {"GL_AUX1", 0x40a},
  {"GL_LIGHT_MODEL_LOCAL_VIEWER", 0xb51},
  {"GL_R", 0x2002},
  {"GL_RGB4", 0x804f},
  {"GL_S", 0x2000},
  {"GL_FRONT_AND_BACK", 0x408},
  {"GL_NORMAL_ARRAY_TYPE", 0x807e},
  {"GL_SPHERE_MAP", 0x2402},
  {"GL_COLOR_INDEXES", 0x1603},
  {"GL_QUADS", 0x7},
  {"GL_LINE_STIPPLE", 0xb24},
  {"GL_MAP2_COLOR_4", 0xdb0},
  {"GL_EYE_LINEAR", 0x2400},
  {"GL_TEXTURE_COORD_ARRAY", 0x8078},
  {"GL_MAP2_VERTEX_3", 0xdb7},
  {"GL_LINEAR_MIPMAP_NEAREST", 0x2701},
  {"GL_DRAW_PIXEL_TOKEN", 0x705},
  {"GL_T2F_C3F_V3F", 0x2a2a},
  {"GL_EDGE_FLAG_ARRAY", 0x8079},
  {"GL_TEXTURE_BORDER", 0x1005},
  {"GL_MAP2_NORMAL", 0xdb2},
  {"GL_SELECT", 0x1c02},
  {"GL_EQUIV", 0x1509},
  {"GL_TEXTURE_INTENSITY_SIZE", 0x8061},
  {"GL_NEVER", 0x200},
  {"GL_PIXEL_MAP_A_TO_A_SIZE", 0xcb9},
  {"GL_MAP2_TEXTURE_COORD_4", 0xdb6},
  {"GL_TEXTURE_RED_SIZE", 0x805c},
  {"GL_TEXTURE_ALPHA_SIZE", 0x805f},
  {"GL_TEXTURE_COORD_ARRAY_SIZE", 0x8088},
  {"GL_COLOR_MATERIAL_FACE", 0xb55},
  {"GL_SRC_COLOR", 0x300},
  {"GL_TEXTURE_COMPONENTS", 0x1003},
  {"GL_LIST_INDEX", 0xb33},
  {"GL_ACCUM_CLEAR_VALUE", 0xb80},
  {"GL_MAX_CLIENT_ATTRIB_STACK_DEPTH", 0xd3b},
  {"GL_TEXTURE_2D", 0xde1},
  {"GL_TEXTURE_1D", 0xde0},
  {"GL_SHADE_MODEL", 0xb54},
  {"GL_LIGHT2", 0x4002},
  {"GL_POLYGON_OFFSET_POINT", 0x2a01},
  {"GL_MAX_LIST_NESTING", 0xb31},
  {"GL_ZOOM_Y", 0xd17},
  {"GL_MATRIX_MODE", 0xba0},
  {"GL_UNPACK_SWAP_BYTES", 0xcf0},
  {"GL_MAP2_GRID_SEGMENTS", 0xdd3},
  {"GL_PACK_SKIP_ROWS", 0xd03},
  {"GL_PACK_LSB_FIRST", 0xd01},
  {"GL_CLIP_PLANE4", 0x3004},
  {"GL_INT", 0x1404},
  {"GL_LIGHT5", 0x4005},
  {"GL_MAX_TEXTURE_SIZE", 0xd33},
  {"GL_ALPHA", 0x1906},
  {"GL_COLOR_ARRAY_TYPE", 0x8082},
  {"GL_EDGE_FLAG", 0xb43},
  {"GL_XOR", 0x1506},
  {"GL_ALPHA_TEST_FUNC", 0xbc1},
  {"GL_SELECTION_BUFFER_SIZE", 0xdf4},
  {"GL_PIXEL_MAP_B_TO_B_SIZE", 0xcb8},
  {"GL_VERTEX_ARRAY_SIZE", 0x807a},
  {"GL_AUTO_NORMAL", 0xd80},
  {"GL_LINE_WIDTH_GRANULARITY", 0xb23},
  {"GL_POLYGON_OFFSET_FILL", 0x8037},
  {"GL_QUADRATIC_ATTENUATION", 0x1209},
  {"GL_R3_G3_B2", 0x2a10},
  {"GL_AUX2", 0x40b},
  {"GL_GREEN_BIAS", 0xd19},
  {"GL_VERTEX_ARRAY_TYPE", 0x807b},
  {"GL_STENCIL_WRITEMASK", 0xb98},
  {"GL_COLOR_WRITEMASK", 0xc23},
  {"GL_INDEX_OFFSET", 0xd13},
  {"GL_POLYGON_TOKEN", 0x703},
  {"GL_LIGHTING_BIT", 0x40},
  {"GL_POLYGON_SMOOTH_HINT", 0xc53},
  {"GL_STEREO", 0xc33},
  {"GL_CONSTANT_ATTENUATION", 0x1207},
  {"GL_NORMALIZE", 0xba1},
  {"GL_FOG_MODE", 0xb65},
  {"GL_BLUE_BITS", 0xd54},
  {"GL_MAP2_TEXTURE_COORD_3", 0xdb5},
  {"GL_LOGIC_OP", 0xbf1},
  {"GL_TEXTURE_STACK_DEPTH", 0xba5},
  {"GL_DEPTH_FUNC", 0xb74},
  {"GL_PASS_THROUGH_TOKEN", 0x700},
  {"GL_RENDER_MODE", 0xc40},
  {"GL_CURRENT_TEXTURE_COORDS", 0xb03},
  {"GL_TEXTURE_WRAP_T", 0x2803},
  {"GL_MAX_CLIP_PLANES", 0xd32},
  {"GL_SUBPIXEL_BITS", 0xd50},
  {"GL_3_BYTES", 0x1408},
  {"GL_RED", 0x1903},
  {"GL_TRIANGLES", 0x4},
  {"GL_LINEAR_ATTENUATION", 0x1208},
  {"GL_COLOR_LOGIC_OP", 0xbf2},
  {"GL_POLYGON", 0x9},
  {"GL_C4F_N3F_V3F", 0x2a26},
  {"GL_DEPTH_RANGE", 0xb70},
  {NULL, 0}
};

static int gl__glColor4i(lua_State *L)
{
  glColor4i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glIndexs(lua_State *L)
{
  glIndexs(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glDrawArrays(lua_State *L)
{
  glDrawArrays(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glMapGrid1d(lua_State *L)
{
  glMapGrid1d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glColor4b(lua_State *L)
{
  glColor4b(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glTexCoord1sv(lua_State *L)
{
  glTexCoord1sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord3f(lua_State *L)
{
  glTexCoord3f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glColor3b(lua_State *L)
{
  glColor3b(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glMapGrid1f(lua_State *L)
{
  glMapGrid1f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glColor4dv(lua_State *L)
{
  glColor4dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord2d(lua_State *L)
{
  glTexCoord2d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glTexCoord3fv(lua_State *L)
{
  glTexCoord3fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glCopyTexImage1D(lua_State *L)
{
  glCopyTexImage1D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7));
  return 0;
}

static int gl__glNormal3bv(lua_State *L)
{
  glNormal3bv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glColor3usv(lua_State *L)
{
  glColor3usv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexGeniv(lua_State *L)
{
  glTexGeniv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glTexCoord4d(lua_State *L)
{
  glTexCoord4d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glMultMatrixf(lua_State *L)
{
  glMultMatrixf(
    checkpointer(L, 1));
  return 0;
}

static int gl__glNormal3sv(lua_State *L)
{
  glNormal3sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glFlush(lua_State *L)
{
  glFlush();
  return 0;
}

static int gl__glGetIntegerv(lua_State *L)
{
  glGetIntegerv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glEvalCoord1dv(lua_State *L)
{
  glEvalCoord1dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glInterleavedArrays(lua_State *L)
{
  glInterleavedArrays(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glColor3s(lua_State *L)
{
  glColor3s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glEndList(lua_State *L)
{
  glEndList();
  return 0;
}

static int gl__glColor3d(lua_State *L)
{
  glColor3d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glRasterPos3i(lua_State *L)
{
  glRasterPos3i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glColor4sv(lua_State *L)
{
  glColor4sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glColor3ub(lua_State *L)
{
  glColor3ub(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glPushName(lua_State *L)
{
  glPushName(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glLightModelfv(lua_State *L)
{
  glLightModelfv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glVertex3i(lua_State *L)
{
  glVertex3i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glColorMaterial(lua_State *L)
{
  glColorMaterial(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glFrontFace(lua_State *L)
{
  glFrontFace(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glVertex4s(lua_State *L)
{
  glVertex4s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glColor3ui(lua_State *L)
{
  glColor3ui(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glVertex2sv(lua_State *L)
{
  glVertex2sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glEvalCoord1fv(lua_State *L)
{
  glEvalCoord1fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTranslated(lua_State *L)
{
  glTranslated(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glTexCoord1dv(lua_State *L)
{
  glTexCoord1dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRectiv(lua_State *L)
{
  glRectiv(
    checkpointer(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glVertex2fv(lua_State *L)
{
  glVertex2fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord4s(lua_State *L)
{
  glTexCoord4s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glEvalCoord2dv(lua_State *L)
{
  glEvalCoord2dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRects(lua_State *L)
{
  glRects(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glTexCoord4f(lua_State *L)
{
  glTexCoord4f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glVertex2f(lua_State *L)
{
  glVertex2f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glMap2f(lua_State *L)
{
  glMap2f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    luaL_checknumber(L, 8),
    luaL_checknumber(L, 9),
    checkpointer(L, 10));
  return 0;
}

static int gl__glGetMaterialfv(lua_State *L)
{
  glGetMaterialfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glNormal3iv(lua_State *L)
{
  glNormal3iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glOrtho(lua_State *L)
{
  glOrtho(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6));
  return 0;
}

static int gl__glGetBooleanv(lua_State *L)
{
  glGetBooleanv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glGetTexLevelParameteriv(lua_State *L)
{
  glGetTexLevelParameteriv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    checkpointer(L, 4));
  return 0;
}

static int gl__glPixelStorei(lua_State *L)
{
  glPixelStorei(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glRasterPos2s(lua_State *L)
{
  glRasterPos2s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glNormal3f(lua_State *L)
{
  glNormal3f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glEvalPoint1(lua_State *L)
{
  glEvalPoint1(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glTexParameteriv(lua_State *L)
{
  glTexParameteriv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glGetPixelMapfv(lua_State *L)
{
  glGetPixelMapfv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glMatrixMode(lua_State *L)
{
  glMatrixMode(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glScaled(lua_State *L)
{
  glScaled(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glTexCoord2sv(lua_State *L)
{
  glTexCoord2sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glIndexdv(lua_State *L)
{
  glIndexdv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glIndexf(lua_State *L)
{
  glIndexf(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glEvalCoord2fv(lua_State *L)
{
  glEvalCoord2fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord1s(lua_State *L)
{
  glTexCoord1s(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glDrawElements(lua_State *L)
{
  glDrawElements(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    checkpointer(L, 4));
  return 0;
}

static int gl__glVertex4fv(lua_State *L)
{
  glVertex4fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRasterPos3dv(lua_State *L)
{
  glRasterPos3dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glClearDepth(lua_State *L)
{
  glClearDepth(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glPolygonMode(lua_State *L)
{
  glPolygonMode(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glVertex4d(lua_State *L)
{
  glVertex4d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glTexEnvfv(lua_State *L)
{
  glTexEnvfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glRasterPos2i(lua_State *L)
{
  glRasterPos2i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glColor4bv(lua_State *L)
{
  glColor4bv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRectsv(lua_State *L)
{
  glRectsv(
    checkpointer(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glColor3ubv(lua_State *L)
{
  glColor3ubv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glColor3f(lua_State *L)
{
  glColor3f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glStencilMask(lua_State *L)
{
  glStencilMask(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glColor4iv(lua_State *L)
{
  glColor4iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRotated(lua_State *L)
{
  glRotated(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glColorMask(lua_State *L)
{
  glColorMask(
    lua_toboolean(L, 1),
    lua_toboolean(L, 2),
    lua_toboolean(L, 3),
    lua_toboolean(L, 4));
  return 0;
}

static int gl__glTexParameterfv(lua_State *L)
{
  glTexParameterfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glLightModelf(lua_State *L)
{
  glLightModelf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glScalef(lua_State *L)
{
  glScalef(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glBegin(lua_State *L)
{
  glBegin(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glRotatef(lua_State *L)
{
  glRotatef(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glInitNames(lua_State *L)
{
  glInitNames();
  return 0;
}

static int gl__glRasterPos3sv(lua_State *L)
{
  glRasterPos3sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord3sv(lua_State *L)
{
  glTexCoord3sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glIndexubv(lua_State *L)
{
  glIndexubv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glNormal3d(lua_State *L)
{
  glNormal3d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glTexCoord2dv(lua_State *L)
{
  glTexCoord2dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glVertex3s(lua_State *L)
{
  glVertex3s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glPolygonOffset(lua_State *L)
{
  glPolygonOffset(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glClearColor(lua_State *L)
{
  glClearColor(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glTexCoord1iv(lua_State *L)
{
  glTexCoord1iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGetFloatv(lua_State *L)
{
  glGetFloatv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glGetTexEnviv(lua_State *L)
{
  glGetTexEnviv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glRecti(lua_State *L)
{
  glRecti(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glNormal3dv(lua_State *L)
{
  glNormal3dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glEdgeFlag(lua_State *L)
{
  glEdgeFlag(
    lua_toboolean(L, 1));
  return 0;
}

static int gl__glColor3sv(lua_State *L)
{
  glColor3sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glMap2d(lua_State *L)
{
  glMap2d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    luaL_checknumber(L, 8),
    luaL_checknumber(L, 9),
    checkpointer(L, 10));
  return 0;
}

static int gl__glClearAccum(lua_State *L)
{
  glClearAccum(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glTranslatef(lua_State *L)
{
  glTranslatef(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glTexCoord4iv(lua_State *L)
{
  glTexCoord4iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glPassThrough(lua_State *L)
{
  glPassThrough(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glNewList(lua_State *L)
{
  glNewList(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glEnd(lua_State *L)
{
  glEnd();
  return 0;
}

static int gl__glGetMapdv(lua_State *L)
{
  glGetMapdv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glLoadMatrixd(lua_State *L)
{
  glLoadMatrixd(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGetPolygonStipple(lua_State *L)
{
  glGetPolygonStipple(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGetString(lua_State *L)
{
  lua_pushstring(L, glGetString(
    luaL_checknumber(L, 1)));
  return 1;
}

static int gl__glPixelTransferf(lua_State *L)
{
  glPixelTransferf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glCopyTexSubImage2D(lua_State *L)
{
  glCopyTexSubImage2D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    luaL_checknumber(L, 8));
  return 0;
}

static int gl__glVertex4dv(lua_State *L)
{
  glVertex4dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRasterPos2sv(lua_State *L)
{
  glRasterPos2sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glVertex4sv(lua_State *L)
{
  glVertex4sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glFogi(lua_State *L)
{
  glFogi(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glRectdv(lua_State *L)
{
  glRectdv(
    checkpointer(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glIndexsv(lua_State *L)
{
  glIndexsv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRasterPos4f(lua_State *L)
{
  glRasterPos4f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glDisable(lua_State *L)
{
  glDisable(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glColor4uiv(lua_State *L)
{
  glColor4uiv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glPixelMapfv(lua_State *L)
{
  glPixelMapfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glIndexPointer(lua_State *L)
{
  glIndexPointer(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glDrawBuffer(lua_State *L)
{
  glDrawBuffer(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glGetMapfv(lua_State *L)
{
  glGetMapfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glLineWidth(lua_State *L)
{
  glLineWidth(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glReadBuffer(lua_State *L)
{
  glReadBuffer(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glGetTexGendv(lua_State *L)
{
  glGetTexGendv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glRasterPos2dv(lua_State *L)
{
  glRasterPos2dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGenLists(lua_State *L)
{
  lua_pushnumber(L, glGenLists(
    luaL_checknumber(L, 1)));
  return 1;
}

static int gl__glRasterPos4d(lua_State *L)
{
  glRasterPos4d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glDepthFunc(lua_State *L)
{
  glDepthFunc(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glHint(lua_State *L)
{
  glHint(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glMaterialf(lua_State *L)
{
  glMaterialf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glPushAttrib(lua_State *L)
{
  glPushAttrib(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glTexCoord3dv(lua_State *L)
{
  glTexCoord3dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glArrayElement(lua_State *L)
{
  glArrayElement(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glLoadName(lua_State *L)
{
  glLoadName(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glSelectBuffer(lua_State *L)
{
  glSelectBuffer(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glFeedbackBuffer(lua_State *L)
{
  glFeedbackBuffer(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glFogiv(lua_State *L)
{
  glFogiv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glRasterPos4fv(lua_State *L)
{
  glRasterPos4fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexGend(lua_State *L)
{
  glTexGend(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glLoadMatrixf(lua_State *L)
{
  glLoadMatrixf(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord4i(lua_State *L)
{
  glTexCoord4i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glVertex4iv(lua_State *L)
{
  glVertex4iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGetTexGeniv(lua_State *L)
{
  glGetTexGeniv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glFogf(lua_State *L)
{
  glFogf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glRectfv(lua_State *L)
{
  glRectfv(
    checkpointer(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glShadeModel(lua_State *L)
{
  glShadeModel(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glColor4usv(lua_State *L)
{
  glColor4usv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glVertex2d(lua_State *L)
{
  glVertex2d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glMapGrid2f(lua_State *L)
{
  glMapGrid2f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6));
  return 0;
}

static int gl__glIndexMask(lua_State *L)
{
  glIndexMask(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glDeleteLists(lua_State *L)
{
  glDeleteLists(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glColorPointer(lua_State *L)
{
  glColorPointer(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    checkpointer(L, 4));
  return 0;
}

static int gl__glEnable(lua_State *L)
{
  glEnable(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glNormal3i(lua_State *L)
{
  glNormal3i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glEvalMesh2(lua_State *L)
{
  glEvalMesh2(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5));
  return 0;
}

static int gl__glRectf(lua_State *L)
{
  glRectf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glCopyPixels(lua_State *L)
{
  glCopyPixels(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5));
  return 0;
}

static int gl__glTexGenf(lua_State *L)
{
  glTexGenf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glEvalPoint2(lua_State *L)
{
  glEvalPoint2(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glMapGrid2d(lua_State *L)
{
  glMapGrid2d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6));
  return 0;
}

static int gl__glPushMatrix(lua_State *L)
{
  glPushMatrix();
  return 0;
}

static int gl__glDeleteTextures(lua_State *L)
{
  glDeleteTextures(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glGetTexEnvfv(lua_State *L)
{
  glGetTexEnvfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glColor3bv(lua_State *L)
{
  glColor3bv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glMap1f(lua_State *L)
{
  glMap1f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    checkpointer(L, 6));
  return 0;
}

static int gl__glTexCoord1i(lua_State *L)
{
  glTexCoord1i(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glRasterPos4dv(lua_State *L)
{
  glRasterPos4dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord3s(lua_State *L)
{
  glTexCoord3s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glDisableClientState(lua_State *L)
{
  glDisableClientState(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glClipPlane(lua_State *L)
{
  glClipPlane(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glEvalCoord2d(lua_State *L)
{
  glEvalCoord2d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glEvalCoord1f(lua_State *L)
{
  glEvalCoord1f(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glEvalCoord1d(lua_State *L)
{
  glEvalCoord1d(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glTexCoord2fv(lua_State *L)
{
  glTexCoord2fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glPointSize(lua_State *L)
{
  glPointSize(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glGetMapiv(lua_State *L)
{
  glGetMapiv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glMap1d(lua_State *L)
{
  glMap1d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    checkpointer(L, 6));
  return 0;
}

static int gl__glCopyTexSubImage1D(lua_State *L)
{
  glCopyTexSubImage1D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6));
  return 0;
}

static int gl__glVertex3fv(lua_State *L)
{
  glVertex3fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glCopyTexImage2D(lua_State *L)
{
  glCopyTexImage2D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    luaL_checknumber(L, 8));
  return 0;
}

static int gl__glTexSubImage2D(lua_State *L)
{
  glTexSubImage2D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    luaL_checknumber(L, 8),
    checkpointer(L, 9));
  return 0;
}

static int gl__glColor4us(lua_State *L)
{
  glColor4us(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glPixelTransferi(lua_State *L)
{
  glPixelTransferi(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glPopName(lua_State *L)
{
  glPopName();
  return 0;
}

static int gl__glIsTexture(lua_State *L)
{
  lua_pushboolean(L, glIsTexture(
    luaL_checknumber(L, 1)));
  return 1;
}

static int gl__glAlphaFunc(lua_State *L)
{
  glAlphaFunc(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glEdgeFlagv(lua_State *L)
{
  glEdgeFlagv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glListBase(lua_State *L)
{
  glListBase(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glRenderMode(lua_State *L)
{
  lua_pushnumber(L, glRenderMode(
    luaL_checknumber(L, 1)));
  return 1;
}

static int gl__glGetMaterialiv(lua_State *L)
{
  glGetMaterialiv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glVertex3d(lua_State *L)
{
  glVertex3d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glLogicOp(lua_State *L)
{
  glLogicOp(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glLineStipple(lua_State *L)
{
  glLineStipple(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glPixelMapusv(lua_State *L)
{
  glPixelMapusv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glBindTexture(lua_State *L)
{
  glBindTexture(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glGenTextures(lua_State *L)
{
  glGenTextures(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glGetTexImage(lua_State *L)
{
  glGetTexImage(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    checkpointer(L, 5));
  return 0;
}

static int gl__glCullFace(lua_State *L)
{
  glCullFace(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glRasterPos2fv(lua_State *L)
{
  glRasterPos2fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexImage2D(lua_State *L)
{
  glTexImage2D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    luaL_checknumber(L, 8),
    checkpointer(L, 9));
  return 0;
}

static int gl__glEnableClientState(lua_State *L)
{
  glEnableClientState(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glGetTexParameteriv(lua_State *L)
{
  glGetTexParameteriv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glGetError(lua_State *L)
{
  lua_pushnumber(L, glGetError());
  return 1;
}

static int gl__glTexImage1D(lua_State *L)
{
  glTexImage1D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    luaL_checknumber(L, 7),
    checkpointer(L, 8));
  return 0;
}

static int gl__glGetTexLevelParameterfv(lua_State *L)
{
  glGetTexLevelParameterfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    checkpointer(L, 4));
  return 0;
}

static int gl__glGetTexParameterfv(lua_State *L)
{
  glGetTexParameterfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glPixelStoref(lua_State *L)
{
  glPixelStoref(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glTexParameterf(lua_State *L)
{
  glTexParameterf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glVertex2iv(lua_State *L)
{
  glVertex2iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glEvalCoord2f(lua_State *L)
{
  glEvalCoord2f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glTexEnvi(lua_State *L)
{
  glTexEnvi(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glTexEnvf(lua_State *L)
{
  glTexEnvf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glLightModeli(lua_State *L)
{
  glLightModeli(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glGetTexGenfv(lua_State *L)
{
  glGetTexGenfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glTexGenfv(lua_State *L)
{
  glTexGenfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glTexGendv(lua_State *L)
{
  glTexGendv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glTexGeni(lua_State *L)
{
  glTexGeni(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glTexCoordPointer(lua_State *L)
{
  glTexCoordPointer(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    checkpointer(L, 4));
  return 0;
}

static int gl__glFinish(lua_State *L)
{
  glFinish();
  return 0;
}

static int gl__glRasterPos2d(lua_State *L)
{
  glRasterPos2d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glVertex3f(lua_State *L)
{
  glVertex3f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glIndexiv(lua_State *L)
{
  glIndexiv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glStencilFunc(lua_State *L)
{
  glStencilFunc(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glEvalMesh1(lua_State *L)
{
  glEvalMesh1(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glDrawPixels(lua_State *L)
{
  glDrawPixels(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    checkpointer(L, 5));
  return 0;
}

static int gl__glReadPixels(lua_State *L)
{
  glReadPixels(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    checkpointer(L, 7));
  return 0;
}

static int gl__glBlendFunc(lua_State *L)
{
  glBlendFunc(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glIndexfv(lua_State *L)
{
  glIndexfv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGetPixelMapuiv(lua_State *L)
{
  glGetPixelMapuiv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glColor4f(lua_State *L)
{
  glColor4f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glIndexi(lua_State *L)
{
  glIndexi(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glRasterPos3fv(lua_State *L)
{
  glRasterPos3fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glPixelMapuiv(lua_State *L)
{
  glPixelMapuiv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glStencilOp(lua_State *L)
{
  glStencilOp(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glPopAttrib(lua_State *L)
{
  glPopAttrib();
  return 0;
}

static int gl__glBitmap(lua_State *L)
{
  glBitmap(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    checkpointer(L, 7));
  return 0;
}

static int gl__glPolygonStipple(lua_State *L)
{
  glPolygonStipple(
    checkpointer(L, 1));
  return 0;
}

static int gl__glVertex3dv(lua_State *L)
{
  glVertex3dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord2f(lua_State *L)
{
  glTexCoord2f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glColor3fv(lua_State *L)
{
  glColor3fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glCallList(lua_State *L)
{
  glCallList(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glColor3i(lua_State *L)
{
  glColor3i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glVertex2s(lua_State *L)
{
  glVertex2s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glTexParameteri(lua_State *L)
{
  glTexParameteri(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glMaterialiv(lua_State *L)
{
  glMaterialiv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glColor4fv(lua_State *L)
{
  glColor4fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexEnviv(lua_State *L)
{
  glTexEnviv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glRasterPos3iv(lua_State *L)
{
  glRasterPos3iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glIsEnabled(lua_State *L)
{
  lua_pushboolean(L, glIsEnabled(
    luaL_checknumber(L, 1)));
  return 1;
}

static int gl__glLoadIdentity(lua_State *L)
{
  glLoadIdentity();
  return 0;
}

static int gl__glTexCoord4sv(lua_State *L)
{
  glTexCoord4sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glMateriali(lua_State *L)
{
  glMateriali(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glLightModeliv(lua_State *L)
{
  glLightModeliv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glTexCoord1fv(lua_State *L)
{
  glTexCoord1fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glVertex2dv(lua_State *L)
{
  glVertex2dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord1d(lua_State *L)
{
  glTexCoord1d(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glGetLightiv(lua_State *L)
{
  glGetLightiv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glGetLightfv(lua_State *L)
{
  glGetLightfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glLightiv(lua_State *L)
{
  glLightiv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glEdgeFlagPointer(lua_State *L)
{
  glEdgeFlagPointer(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glAccum(lua_State *L)
{
  glAccum(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glLightfv(lua_State *L)
{
  glLightfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glLighti(lua_State *L)
{
  glLighti(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glColor4s(lua_State *L)
{
  glColor4s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glGetDoublev(lua_State *L)
{
  glGetDoublev(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glDepthRange(lua_State *L)
{
  glDepthRange(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glPixelZoom(lua_State *L)
{
  glPixelZoom(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glRasterPos4i(lua_State *L)
{
  glRasterPos4i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glMaterialfv(lua_State *L)
{
  glMaterialfv(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glVertex2i(lua_State *L)
{
  glVertex2i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glTexSubImage1D(lua_State *L)
{
  glTexSubImage1D(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6),
    checkpointer(L, 7));
  return 0;
}

static int gl__glPrioritizeTextures(lua_State *L)
{
  glPrioritizeTextures(
    luaL_checknumber(L, 1),
    checkpointer(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glTexCoord3i(lua_State *L)
{
  glTexCoord3i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glClearStencil(lua_State *L)
{
  glClearStencil(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glViewport(lua_State *L)
{
  glViewport(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glNormal3fv(lua_State *L)
{
  glNormal3fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGetPointerv(lua_State *L)
{
  glGetPointerv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glClear(lua_State *L)
{
  glClear(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glColor4ubv(lua_State *L)
{
  glColor4ubv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord2iv(lua_State *L)
{
  glTexCoord2iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glColor3us(lua_State *L)
{
  glColor3us(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glColor4ub(lua_State *L)
{
  glColor4ub(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glTexCoord4dv(lua_State *L)
{
  glTexCoord4dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGetPixelMapusv(lua_State *L)
{
  glGetPixelMapusv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glColor4d(lua_State *L)
{
  glColor4d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glRasterPos3d(lua_State *L)
{
  glRasterPos3d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glNormal3b(lua_State *L)
{
  glNormal3b(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glNormalPointer(lua_State *L)
{
  glNormalPointer(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glColor4ui(lua_State *L)
{
  glColor4ui(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glMultMatrixd(lua_State *L)
{
  glMultMatrixd(
    checkpointer(L, 1));
  return 0;
}

static int gl__glColor3iv(lua_State *L)
{
  glColor3iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glIsList(lua_State *L)
{
  lua_pushboolean(L, glIsList(
    luaL_checknumber(L, 1)));
  return 1;
}

static int gl__glVertex3sv(lua_State *L)
{
  glVertex3sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRasterPos4sv(lua_State *L)
{
  glRasterPos4sv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glVertexPointer(lua_State *L)
{
  glVertexPointer(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    checkpointer(L, 4));
  return 0;
}

static int gl__glPushClientAttrib(lua_State *L)
{
  glPushClientAttrib(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glRectd(lua_State *L)
{
  glRectd(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glPopClientAttrib(lua_State *L)
{
  glPopClientAttrib();
  return 0;
}

static int gl__glRasterPos2iv(lua_State *L)
{
  glRasterPos2iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glGetClipPlane(lua_State *L)
{
  glGetClipPlane(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glRasterPos4s(lua_State *L)
{
  glRasterPos4s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glVertex3iv(lua_State *L)
{
  glVertex3iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glScissor(lua_State *L)
{
  glScissor(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glColor3dv(lua_State *L)
{
  glColor3dv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glRasterPos3s(lua_State *L)
{
  glRasterPos3s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glRasterPos3f(lua_State *L)
{
  glRasterPos3f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glTexCoord2s(lua_State *L)
{
  glTexCoord2s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glClearIndex(lua_State *L)
{
  glClearIndex(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glRasterPos2f(lua_State *L)
{
  glRasterPos2f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glLightf(lua_State *L)
{
  glLightf(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glVertex4f(lua_State *L)
{
  glVertex4f(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glTexCoord4fv(lua_State *L)
{
  glTexCoord4fv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glTexCoord3iv(lua_State *L)
{
  glTexCoord3iv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glNormal3s(lua_State *L)
{
  glNormal3s(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glPopMatrix(lua_State *L)
{
  glPopMatrix();
  return 0;
}

static int gl__glTexCoord2i(lua_State *L)
{
  glTexCoord2i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2));
  return 0;
}

static int gl__glVertex4i(lua_State *L)
{
  glVertex4i(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4));
  return 0;
}

static int gl__glFrustum(lua_State *L)
{
  glFrustum(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3),
    luaL_checknumber(L, 4),
    luaL_checknumber(L, 5),
    luaL_checknumber(L, 6));
  return 0;
}

static int gl__glFogfv(lua_State *L)
{
  glFogfv(
    luaL_checknumber(L, 1),
    checkpointer(L, 2));
  return 0;
}

static int gl__glTexCoord3d(lua_State *L)
{
  glTexCoord3d(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    luaL_checknumber(L, 3));
  return 0;
}

static int gl__glTexCoord1f(lua_State *L)
{
  glTexCoord1f(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glColor3uiv(lua_State *L)
{
  glColor3uiv(
    checkpointer(L, 1));
  return 0;
}

static int gl__glIndexub(lua_State *L)
{
  glIndexub(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glAreTexturesResident(lua_State *L)
{
  lua_pushboolean(L, glAreTexturesResident(
    luaL_checknumber(L, 1),
    checkpointer(L, 2),
    checkpointer(L, 3)));
  return 1;
}

static int gl__glIndexd(lua_State *L)
{
  glIndexd(
    luaL_checknumber(L, 1));
  return 0;
}

static int gl__glDepthMask(lua_State *L)
{
  glDepthMask(
    lua_toboolean(L, 1));
  return 0;
}

static int gl__glCallLists(lua_State *L)
{
  glCallLists(
    luaL_checknumber(L, 1),
    luaL_checknumber(L, 2),
    checkpointer(L, 3));
  return 0;
}

static int gl__glRasterPos4iv(lua_State *L)
{
  glRasterPos4iv(
    checkpointer(L, 1));
  return 0;
}

static const luaL_Reg functions [] = 
{
  {"glColor4i", gl__glColor4i},
  {"glIndexs", gl__glIndexs},
  {"glDrawArrays", gl__glDrawArrays},
  {"glMapGrid1d", gl__glMapGrid1d},
  {"glColor4b", gl__glColor4b},
  {"glTexCoord1sv", gl__glTexCoord1sv},
  {"glTexCoord3f", gl__glTexCoord3f},
  {"glColor3b", gl__glColor3b},
  {"glMapGrid1f", gl__glMapGrid1f},
  {"glColor4dv", gl__glColor4dv},
  {"glTexCoord2d", gl__glTexCoord2d},
  {"glTexCoord3fv", gl__glTexCoord3fv},
  {"glCopyTexImage1D", gl__glCopyTexImage1D},
  {"glNormal3bv", gl__glNormal3bv},
  {"glColor3usv", gl__glColor3usv},
  {"glTexGeniv", gl__glTexGeniv},
  {"glTexCoord4d", gl__glTexCoord4d},
  {"glMultMatrixf", gl__glMultMatrixf},
  {"glNormal3sv", gl__glNormal3sv},
  {"glFlush", gl__glFlush},
  {"glGetIntegerv", gl__glGetIntegerv},
  {"glEvalCoord1dv", gl__glEvalCoord1dv},
  {"glInterleavedArrays", gl__glInterleavedArrays},
  {"glColor3s", gl__glColor3s},
  {"glEndList", gl__glEndList},
  {"glColor3d", gl__glColor3d},
  {"glRasterPos3i", gl__glRasterPos3i},
  {"glColor4sv", gl__glColor4sv},
  {"glColor3ub", gl__glColor3ub},
  {"glPushName", gl__glPushName},
  {"glLightModelfv", gl__glLightModelfv},
  {"glVertex3i", gl__glVertex3i},
  {"glColorMaterial", gl__glColorMaterial},
  {"glFrontFace", gl__glFrontFace},
  {"glVertex4s", gl__glVertex4s},
  {"glColor3ui", gl__glColor3ui},
  {"glVertex2sv", gl__glVertex2sv},
  {"glEvalCoord1fv", gl__glEvalCoord1fv},
  {"glTranslated", gl__glTranslated},
  {"glTexCoord1dv", gl__glTexCoord1dv},
  {"glRectiv", gl__glRectiv},
  {"glVertex2fv", gl__glVertex2fv},
  {"glTexCoord4s", gl__glTexCoord4s},
  {"glEvalCoord2dv", gl__glEvalCoord2dv},
  {"glRects", gl__glRects},
  {"glTexCoord4f", gl__glTexCoord4f},
  {"glVertex2f", gl__glVertex2f},
  {"glMap2f", gl__glMap2f},
  {"glGetMaterialfv", gl__glGetMaterialfv},
  {"glNormal3iv", gl__glNormal3iv},
  {"glOrtho", gl__glOrtho},
  {"glGetBooleanv", gl__glGetBooleanv},
  {"glGetTexLevelParameteriv", gl__glGetTexLevelParameteriv},
  {"glPixelStorei", gl__glPixelStorei},
  {"glRasterPos2s", gl__glRasterPos2s},
  {"glNormal3f", gl__glNormal3f},
  {"glEvalPoint1", gl__glEvalPoint1},
  {"glTexParameteriv", gl__glTexParameteriv},
  {"glGetPixelMapfv", gl__glGetPixelMapfv},
  {"glMatrixMode", gl__glMatrixMode},
  {"glScaled", gl__glScaled},
  {"glTexCoord2sv", gl__glTexCoord2sv},
  {"glIndexdv", gl__glIndexdv},
  {"glIndexf", gl__glIndexf},
  {"glEvalCoord2fv", gl__glEvalCoord2fv},
  {"glTexCoord1s", gl__glTexCoord1s},
  {"glDrawElements", gl__glDrawElements},
  {"glVertex4fv", gl__glVertex4fv},
  {"glRasterPos3dv", gl__glRasterPos3dv},
  {"glClearDepth", gl__glClearDepth},
  {"glPolygonMode", gl__glPolygonMode},
  {"glVertex4d", gl__glVertex4d},
  {"glTexEnvfv", gl__glTexEnvfv},
  {"glRasterPos2i", gl__glRasterPos2i},
  {"glColor4bv", gl__glColor4bv},
  {"glRectsv", gl__glRectsv},
  {"glColor3ubv", gl__glColor3ubv},
  {"glColor3f", gl__glColor3f},
  {"glStencilMask", gl__glStencilMask},
  {"glColor4iv", gl__glColor4iv},
  {"glRotated", gl__glRotated},
  {"glColorMask", gl__glColorMask},
  {"glTexParameterfv", gl__glTexParameterfv},
  {"glLightModelf", gl__glLightModelf},
  {"glScalef", gl__glScalef},
  {"glBegin", gl__glBegin},
  {"glRotatef", gl__glRotatef},
  {"glInitNames", gl__glInitNames},
  {"glRasterPos3sv", gl__glRasterPos3sv},
  {"glTexCoord3sv", gl__glTexCoord3sv},
  {"glIndexubv", gl__glIndexubv},
  {"glNormal3d", gl__glNormal3d},
  {"glTexCoord2dv", gl__glTexCoord2dv},
  {"glVertex3s", gl__glVertex3s},
  {"glPolygonOffset", gl__glPolygonOffset},
  {"glClearColor", gl__glClearColor},
  {"glTexCoord1iv", gl__glTexCoord1iv},
  {"glGetFloatv", gl__glGetFloatv},
  {"glGetTexEnviv", gl__glGetTexEnviv},
  {"glRecti", gl__glRecti},
  {"glNormal3dv", gl__glNormal3dv},
  {"glEdgeFlag", gl__glEdgeFlag},
  {"glColor3sv", gl__glColor3sv},
  {"glMap2d", gl__glMap2d},
  {"glClearAccum", gl__glClearAccum},
  {"glTranslatef", gl__glTranslatef},
  {"glTexCoord4iv", gl__glTexCoord4iv},
  {"glPassThrough", gl__glPassThrough},
  {"glNewList", gl__glNewList},
  {"glEnd", gl__glEnd},
  {"glGetMapdv", gl__glGetMapdv},
  {"glLoadMatrixd", gl__glLoadMatrixd},
  {"glGetPolygonStipple", gl__glGetPolygonStipple},
  {"glGetString", gl__glGetString},
  {"glPixelTransferf", gl__glPixelTransferf},
  {"glCopyTexSubImage2D", gl__glCopyTexSubImage2D},
  {"glVertex4dv", gl__glVertex4dv},
  {"glRasterPos2sv", gl__glRasterPos2sv},
  {"glVertex4sv", gl__glVertex4sv},
  {"glFogi", gl__glFogi},
  {"glRectdv", gl__glRectdv},
  {"glIndexsv", gl__glIndexsv},
  {"glRasterPos4f", gl__glRasterPos4f},
  {"glDisable", gl__glDisable},
  {"glColor4uiv", gl__glColor4uiv},
  {"glPixelMapfv", gl__glPixelMapfv},
  {"glIndexPointer", gl__glIndexPointer},
  {"glDrawBuffer", gl__glDrawBuffer},
  {"glGetMapfv", gl__glGetMapfv},
  {"glLineWidth", gl__glLineWidth},
  {"glReadBuffer", gl__glReadBuffer},
  {"glGetTexGendv", gl__glGetTexGendv},
  {"glRasterPos2dv", gl__glRasterPos2dv},
  {"glGenLists", gl__glGenLists},
  {"glRasterPos4d", gl__glRasterPos4d},
  {"glDepthFunc", gl__glDepthFunc},
  {"glHint", gl__glHint},
  {"glMaterialf", gl__glMaterialf},
  {"glPushAttrib", gl__glPushAttrib},
  {"glTexCoord3dv", gl__glTexCoord3dv},
  {"glArrayElement", gl__glArrayElement},
  {"glLoadName", gl__glLoadName},
  {"glSelectBuffer", gl__glSelectBuffer},
  {"glFeedbackBuffer", gl__glFeedbackBuffer},
  {"glFogiv", gl__glFogiv},
  {"glRasterPos4fv", gl__glRasterPos4fv},
  {"glTexGend", gl__glTexGend},
  {"glLoadMatrixf", gl__glLoadMatrixf},
  {"glTexCoord4i", gl__glTexCoord4i},
  {"glVertex4iv", gl__glVertex4iv},
  {"glGetTexGeniv", gl__glGetTexGeniv},
  {"glFogf", gl__glFogf},
  {"glRectfv", gl__glRectfv},
  {"glShadeModel", gl__glShadeModel},
  {"glColor4usv", gl__glColor4usv},
  {"glVertex2d", gl__glVertex2d},
  {"glMapGrid2f", gl__glMapGrid2f},
  {"glIndexMask", gl__glIndexMask},
  {"glDeleteLists", gl__glDeleteLists},
  {"glColorPointer", gl__glColorPointer},
  {"glEnable", gl__glEnable},
  {"glNormal3i", gl__glNormal3i},
  {"glEvalMesh2", gl__glEvalMesh2},
  {"glRectf", gl__glRectf},
  {"glCopyPixels", gl__glCopyPixels},
  {"glTexGenf", gl__glTexGenf},
  {"glEvalPoint2", gl__glEvalPoint2},
  {"glMapGrid2d", gl__glMapGrid2d},
  {"glPushMatrix", gl__glPushMatrix},
  {"glDeleteTextures", gl__glDeleteTextures},
  {"glGetTexEnvfv", gl__glGetTexEnvfv},
  {"glColor3bv", gl__glColor3bv},
  {"glMap1f", gl__glMap1f},
  {"glTexCoord1i", gl__glTexCoord1i},
  {"glRasterPos4dv", gl__glRasterPos4dv},
  {"glTexCoord3s", gl__glTexCoord3s},
  {"glDisableClientState", gl__glDisableClientState},
  {"glClipPlane", gl__glClipPlane},
  {"glEvalCoord2d", gl__glEvalCoord2d},
  {"glEvalCoord1f", gl__glEvalCoord1f},
  {"glEvalCoord1d", gl__glEvalCoord1d},
  {"glTexCoord2fv", gl__glTexCoord2fv},
  {"glPointSize", gl__glPointSize},
  {"glGetMapiv", gl__glGetMapiv},
  {"glMap1d", gl__glMap1d},
  {"glCopyTexSubImage1D", gl__glCopyTexSubImage1D},
  {"glVertex3fv", gl__glVertex3fv},
  {"glCopyTexImage2D", gl__glCopyTexImage2D},
  {"glTexSubImage2D", gl__glTexSubImage2D},
  {"glColor4us", gl__glColor4us},
  {"glPixelTransferi", gl__glPixelTransferi},
  {"glPopName", gl__glPopName},
  {"glIsTexture", gl__glIsTexture},
  {"glAlphaFunc", gl__glAlphaFunc},
  {"glEdgeFlagv", gl__glEdgeFlagv},
  {"glListBase", gl__glListBase},
  {"glRenderMode", gl__glRenderMode},
  {"glGetMaterialiv", gl__glGetMaterialiv},
  {"glVertex3d", gl__glVertex3d},
  {"glLogicOp", gl__glLogicOp},
  {"glLineStipple", gl__glLineStipple},
  {"glPixelMapusv", gl__glPixelMapusv},
  {"glBindTexture", gl__glBindTexture},
  {"glGenTextures", gl__glGenTextures},
  {"glGetTexImage", gl__glGetTexImage},
  {"glCullFace", gl__glCullFace},
  {"glRasterPos2fv", gl__glRasterPos2fv},
  {"glTexImage2D", gl__glTexImage2D},
  {"glEnableClientState", gl__glEnableClientState},
  {"glGetTexParameteriv", gl__glGetTexParameteriv},
  {"glGetError", gl__glGetError},
  {"glTexImage1D", gl__glTexImage1D},
  {"glGetTexLevelParameterfv", gl__glGetTexLevelParameterfv},
  {"glGetTexParameterfv", gl__glGetTexParameterfv},
  {"glPixelStoref", gl__glPixelStoref},
  {"glTexParameterf", gl__glTexParameterf},
  {"glVertex2iv", gl__glVertex2iv},
  {"glEvalCoord2f", gl__glEvalCoord2f},
  {"glTexEnvi", gl__glTexEnvi},
  {"glTexEnvf", gl__glTexEnvf},
  {"glLightModeli", gl__glLightModeli},
  {"glGetTexGenfv", gl__glGetTexGenfv},
  {"glTexGenfv", gl__glTexGenfv},
  {"glTexGendv", gl__glTexGendv},
  {"glTexGeni", gl__glTexGeni},
  {"glTexCoordPointer", gl__glTexCoordPointer},
  {"glFinish", gl__glFinish},
  {"glRasterPos2d", gl__glRasterPos2d},
  {"glVertex3f", gl__glVertex3f},
  {"glIndexiv", gl__glIndexiv},
  {"glStencilFunc", gl__glStencilFunc},
  {"glEvalMesh1", gl__glEvalMesh1},
  {"glDrawPixels", gl__glDrawPixels},
  {"glReadPixels", gl__glReadPixels},
  {"glBlendFunc", gl__glBlendFunc},
  {"glIndexfv", gl__glIndexfv},
  {"glGetPixelMapuiv", gl__glGetPixelMapuiv},
  {"glColor4f", gl__glColor4f},
  {"glIndexi", gl__glIndexi},
  {"glRasterPos3fv", gl__glRasterPos3fv},
  {"glPixelMapuiv", gl__glPixelMapuiv},
  {"glStencilOp", gl__glStencilOp},
  {"glPopAttrib", gl__glPopAttrib},
  {"glBitmap", gl__glBitmap},
  {"glPolygonStipple", gl__glPolygonStipple},
  {"glVertex3dv", gl__glVertex3dv},
  {"glTexCoord2f", gl__glTexCoord2f},
  {"glColor3fv", gl__glColor3fv},
  {"glCallList", gl__glCallList},
  {"glColor3i", gl__glColor3i},
  {"glVertex2s", gl__glVertex2s},
  {"glTexParameteri", gl__glTexParameteri},
  {"glMaterialiv", gl__glMaterialiv},
  {"glColor4fv", gl__glColor4fv},
  {"glTexEnviv", gl__glTexEnviv},
  {"glRasterPos3iv", gl__glRasterPos3iv},
  {"glIsEnabled", gl__glIsEnabled},
  {"glLoadIdentity", gl__glLoadIdentity},
  {"glTexCoord4sv", gl__glTexCoord4sv},
  {"glMateriali", gl__glMateriali},
  {"glLightModeliv", gl__glLightModeliv},
  {"glTexCoord1fv", gl__glTexCoord1fv},
  {"glVertex2dv", gl__glVertex2dv},
  {"glTexCoord1d", gl__glTexCoord1d},
  {"glGetLightiv", gl__glGetLightiv},
  {"glGetLightfv", gl__glGetLightfv},
  {"glLightiv", gl__glLightiv},
  {"glEdgeFlagPointer", gl__glEdgeFlagPointer},
  {"glAccum", gl__glAccum},
  {"glLightfv", gl__glLightfv},
  {"glLighti", gl__glLighti},
  {"glColor4s", gl__glColor4s},
  {"glGetDoublev", gl__glGetDoublev},
  {"glDepthRange", gl__glDepthRange},
  {"glPixelZoom", gl__glPixelZoom},
  {"glRasterPos4i", gl__glRasterPos4i},
  {"glMaterialfv", gl__glMaterialfv},
  {"glVertex2i", gl__glVertex2i},
  {"glTexSubImage1D", gl__glTexSubImage1D},
  {"glPrioritizeTextures", gl__glPrioritizeTextures},
  {"glTexCoord3i", gl__glTexCoord3i},
  {"glClearStencil", gl__glClearStencil},
  {"glViewport", gl__glViewport},
  {"glNormal3fv", gl__glNormal3fv},
  {"glGetPointerv", gl__glGetPointerv},
  {"glClear", gl__glClear},
  {"glColor4ubv", gl__glColor4ubv},
  {"glTexCoord2iv", gl__glTexCoord2iv},
  {"glColor3us", gl__glColor3us},
  {"glColor4ub", gl__glColor4ub},
  {"glTexCoord4dv", gl__glTexCoord4dv},
  {"glGetPixelMapusv", gl__glGetPixelMapusv},
  {"glColor4d", gl__glColor4d},
  {"glRasterPos3d", gl__glRasterPos3d},
  {"glNormal3b", gl__glNormal3b},
  {"glNormalPointer", gl__glNormalPointer},
  {"glColor4ui", gl__glColor4ui},
  {"glMultMatrixd", gl__glMultMatrixd},
  {"glColor3iv", gl__glColor3iv},
  {"glIsList", gl__glIsList},
  {"glVertex3sv", gl__glVertex3sv},
  {"glRasterPos4sv", gl__glRasterPos4sv},
  {"glVertexPointer", gl__glVertexPointer},
  {"glPushClientAttrib", gl__glPushClientAttrib},
  {"glRectd", gl__glRectd},
  {"glPopClientAttrib", gl__glPopClientAttrib},
  {"glRasterPos2iv", gl__glRasterPos2iv},
  {"glGetClipPlane", gl__glGetClipPlane},
  {"glRasterPos4s", gl__glRasterPos4s},
  {"glVertex3iv", gl__glVertex3iv},
  {"glScissor", gl__glScissor},
  {"glColor3dv", gl__glColor3dv},
  {"glRasterPos3s", gl__glRasterPos3s},
  {"glRasterPos3f", gl__glRasterPos3f},
  {"glTexCoord2s", gl__glTexCoord2s},
  {"glClearIndex", gl__glClearIndex},
  {"glRasterPos2f", gl__glRasterPos2f},
  {"glLightf", gl__glLightf},
  {"glVertex4f", gl__glVertex4f},
  {"glTexCoord4fv", gl__glTexCoord4fv},
  {"glTexCoord3iv", gl__glTexCoord3iv},
  {"glNormal3s", gl__glNormal3s},
  {"glPopMatrix", gl__glPopMatrix},
  {"glTexCoord2i", gl__glTexCoord2i},
  {"glVertex4i", gl__glVertex4i},
  {"glFrustum", gl__glFrustum},
  {"glFogfv", gl__glFogfv},
  {"glTexCoord3d", gl__glTexCoord3d},
  {"glTexCoord1f", gl__glTexCoord1f},
  {"glColor3uiv", gl__glColor3uiv},
  {"glIndexub", gl__glIndexub},
  {"glAreTexturesResident", gl__glAreTexturesResident},
  {"glIndexd", gl__glIndexd},
  {"glDepthMask", gl__glDepthMask},
  {"glCallLists", gl__glCallLists},
  {"glRasterPos4iv", gl__glRasterPos4iv},
  {NULL, NULL}
};

int luaopen_gl(lua_State *L)
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
