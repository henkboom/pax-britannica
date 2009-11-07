NAME=dokidoki-support

#### General Settings

LUA_DIR=lua-5.1.4

TARGET=$(NAME)
CFLAGS=-I$(LUA_DIR)/src -DMEMARRAY_USE_OPENGL $(PLATFORM_CFLAGS) $(EXTRA_CFLAGS)
LDFLAGS=-L$(LUA_DIR)/src \
		-Wl,-Bstatic -lportaudio -lglfw \
		-Wl,-Bdynamic $(PLATFORM_LDFLAGS) $(EXTRA_LDFLAGS)

#### Platform Settings

linux:
	make $(TARGET) PLATFORM=linux \
		PLATFORM_CFLAGS="-pthread" \
		PLATFORM_LDFLAGS="-pthread -lpthread -lGL -lGLU -lX11 -lXrandr -lm -lasound"

maxosx:
	make $(TARGET) PLATFORM=macosx \
		PLATFORM_CFLAGS="TODO" \
		PLATFORM_LDFLAGS="TODO"

mingw:
	make $(TARGET) PLATFORM=mingw \
		PLATFORM_CFLAGS="" \
		PLATFORM_LDFLAGS="-lopengl32 -lglu32 -lole32 -lwinmm"

clean:
	make -C $(LUA_DIR) clean
	rm -f *.o $(NAME)

#### Actual Building

$(TARGET): minlua.o luaglfw.o lua_stb_image.o mixer.o memarray.o gl.o glu.o $(LUA_DIR)/src/liblua.a
	$(CC) -o $@ $^ $(LDFLAGS)

$(LUA_DIR)/src/liblua.a: $(LUA_DIR)/Makefile
	make -C $(LUA_DIR) $(PLATFORM)

