#include "log.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <lauxlib.h>
#include <lualib.h>

FILE *file = NULL;

#if defined(DOKIDOKI_LINUX) || defined(DOKIDOKI_MACOSX)
static void open_logfile()
{
    const char *suffix = "/.dokidoki.log";
    const char *home = getenv("HOME");
    size_t len = strlen(suffix) + strlen(home) + 1;
    char *path = (char *)malloc(len * sizeof(char));
    strcpy(path, home);
    strcat(path, suffix);
    file = fopen(path, "w");
    free(path);
}
#else
static void open_logfile()
{
    file = fopen("dokidoki.log", "w");
}
#endif

void log_init(int use_logfile)
{
    if(use_logfile)
        open_logfile();

    if(!file)
        file = stderr;
}

void log_message(const char *message)
{
    fputs(message, file);
    fputs("\n", file);
    fflush(file);
}

void log_messagef(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);

    vfprintf(file, fmt, args);
    fputs("\n", file);
    fflush(file);

    va_end(args);
}

//// lua binding //////////////////////////////////////////////////////////////

static int log__log_message(lua_State *L)
{
    log_message(luaL_checkstring(L, 1));
    return 0;
}

static const luaL_Reg log_lib[] =
{
    {"log_message", log__log_message},
    {NULL, NULL}
};

int luaopen_log(lua_State *L)
{
    lua_newtable(L);
    luaL_register(L, NULL, log_lib);
    return 1;
}
