NAME=dokidoki-support

#### General Settings

LUA_DIR=lua-5.1.4

TARGET=$(NAME)
CFLAGS=-I$(LUA_DIR)/src -DMEMARRAY_USE_OPENGL $(PLATFORM_CFLAGS) $(EXTRA_CFLAGS)
LDFLAGS=-L$(LUA_DIR)/src \
		$(STATIC_LINK) -lportaudio -lglfw \
		$(DYNAMIC_LINK) $(PLATFORM_LDFLAGS) $(EXTRA_LDFLAGS)

#### Platform Settings

linux:
	make $(TARGET) PLATFORM=linux \
		STATIC_LINK="-Wl,-Bstatic" \
		DYNAMIC_LINK="-Wl,-Bdynamic" \
		PLATFORM_CFLAGS="-pthread" \
		PLATFORM_LDFLAGS="-pthread -lpthread -lGL -lGLU -lX11 -lXrandr -lm -lasound"

macosx:
	make $(TARGET) PLATFORM=macosx \
		STATIC_LINK="" \
		DYNAMIC_LINK="" \
		PLATFORM_CFLAGS="" \
		PLATFORM_LDFLAGS="-framework AGL -framework OpenGL -framework Carbon"

mingw:
	make $(TARGET) PLATFORM=mingw \
		STATIC_LINK="-Wl,-Bstatic" \
		DYNAMIC_LINK="-Wl,-Bdynamic" \
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

