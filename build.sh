gcc seed.c luaglfw.c lua_stb_image.c mixer.c -I/home/henk/local/src/lua-5.1.3/src /home/henk/local/src/lua-5.1.3/src/liblua.a -lm /usr/lib/libportaudio.a /usr/lib/libglfw.a -lpthread -lGL -lasound /usr/lib/libXrandr.so.2 -std=c99 ../seed/physfs-2.0.0/build/libphysfs.a -I../seed/physfs-2.0.0

CFLAGS="`pkg-config --cflags portaudio-2.0 libglfw` -I../seed/physfs-2.0.0"
LDFLAGS="`pkg-config --libs portaudio-2.0 libglfw` ../seed/physfs-2.0.0/libphysfs.a"

a.out: seed.c luaglfw.c lua_stb_image.c mixer.c
	gcc -o $@ $^ $(CFLAGS) $(LDFLAGS)
