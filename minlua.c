#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include "log.h"

//// preloaders ///////////////////////////////////////////////////////////////
// to statically link in binary lua modules:
//
// - use the right linker options (or just include the .a in the link line)
// - add them to init_preloaders right below
//
// You don't need to manually declare them or include anything, the
// REGISTER_LOADER macro handles that.

#define REGISTER_LOADER(module_name, loader) \
    int loader(lua_State *L); \
    lua_pushcfunction(L, loader); \
    lua_setfield(L, -2, module_name)

void init_preloaders(lua_State *L)
{
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");

    // add your custom loaders here, they look like this:
    REGISTER_LOADER("collision.native", luaopen_collision_native);
    REGISTER_LOADER("gl", luaopen_gl);
    REGISTER_LOADER("glfw", luaopen_glfw);
    REGISTER_LOADER("glu", luaopen_glu);
    REGISTER_LOADER("log", luaopen_log);
    REGISTER_LOADER("memarray", luaopen_memarray);
    REGISTER_LOADER("mixer", luaopen_mixer);
    REGISTER_LOADER("stb_image", luaopen_stb_image);

    // each night I pray that I might one day happen upon a less disgusting way
    // of doing this
    #ifdef EXTRA_LOADERS
    #include EXTRA_LOADERS
    #endif
    
    lua_pop(L, 2);
}

//// working directory handling ///////////////////////////////////////////////

#if defined(DOKIDOKI_LINUX)
int get_exe_path(char *buffer, int size)
{
    int ret = readlink("/proc/self/exe", buffer, size);
    if(0 >= ret && ret < size)
        buffer[ret] = 0;
    return ret;
}
#elif defined(DOKIDOKI_MINGW)
#include <windows.h>
int get_exe_path(char *buffer, int size)
{
    return GetModuleFileName(NULL, buffer, size);
}
#elif defined(DOKIDOKI_MACOSX)
#include <CFBundle.h>
#include <CFURL.h>
int switch_to_game_directory()
{
    log_message("finding the bundle directory");

    CFBundleRef bundle = CFBundleGetMainBundle();
    CFURLRef url = NULL;
    if(bundle)
        url = CFBundleCopyBundleURL(bundle);
    if(!url)
    {
        log_message("no bundle found");
        return 0;
    }

    CFStringRef str = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    CFRelease(url);

    int size = CFStringGetLength(str) + 1;
    char *dir = (char *)malloc(size);

    int success = CFStringGetCString(str, dir, size, kCFURLPOSIXPathStyle);
    CFRelease(str);
    
    if(success)
    {
        int success = chdir(dir);
        if(success == 0)
            log_messagef("changed directory to '%s'", dir);
        else
            log_messagef("failed changing directory to '%s'", dir);

        // there must be a better way to tell if we're bundled :/
        if(chdir("Contents/Resources") == 0)
            log_message("running as an app bundle, changed to resources directory");
        else
            log_message("running unbundled");
    }

    free(dir);
    return success;
}
#else
int switch_to_game_directory()
{
    log_message("automatic game path detection not supported on this platform");
    return 0;
}
#endif

#if defined(DOKIDOKI_MINGW) || defined(DOKIDOKI_LINUX)
int switch_to_game_directory()
{
    log_message("finding the game's directory");
    int size = 256;
    char *buffer = NULL;
    while(!buffer)
    {
        buffer = (char *)malloc(size);
        int ret = get_exe_path(buffer, size);

        // error
        if(ret <= 0)
        {
            free(buffer);
            buffer = NULL;
            log_message("failed locating the executable");
            return 0;
        }
        // buffer too small
        else if(ret == size)
        {
            free(buffer);
            buffer = NULL;
            size *= 2;
        }
    }

    char *dir = dirname(buffer);

    int success = chdir(dir);
    if(success == 0)
        log_messagef("changed directory to '%s'", dir);
    else
        log_messagef("failed to change directory to '%s'", dir);

    free(buffer);
    return success;
}
#endif

//// main program /////////////////////////////////////////////////////////////

int main(int argc, char ** argv)
{
    int i;

    int use_logfile = 1;
    for(i = 0; i < argc; i++)
        if(strcmp(argv[i], "--stderr") == 0)
            use_logfile = 0;
    log_init(use_logfile);

    switch_to_game_directory();

    // load lua and libraries
    lua_State *L = lua_open();
    luaL_openlibs(L);
    init_preloaders(L);
    
    // load arguments (and pre-arguments) into a global 'arg' table
    lua_newtable(L);
    for(i = 0; i < argc; i++)
    {
        lua_pushstring(L, argv[i]);
        lua_rawseti(L, -2, i);
    }
    lua_setglobal(L, "arg");

    // open app, with error reporting
    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");

    int error = luaL_dofile(L, "init.lua");

    if(!error)
    {
        // load command-line arguments as function arguments
        lua_checkstack(L, argc - 1);
        for(i = 1; i <= argc - 1; i++)
            lua_pushstring(L, argv[i]);
        error = lua_pcall(L, argc - 1, 0, -2);  // run the result
    }

    if(error)
        log_messagef("fatal error: %s", lua_tostring(L, -1));
    else
        log_message("exiting normally");

    lua_close(L);
    return error;
}

