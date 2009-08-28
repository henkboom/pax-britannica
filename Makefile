NAME=dokidoki-support

#### General Settings

LUA_DIR=lua-5.1.4
ALIEN_DIR=alien-0.4.1
LUA_DIR_FROM_ALIEN_DIR=../$(LUA_DIR)

TARGET=$(NAME)
CFLAGS=-I$(LUA_DIR)/src $(PLATFORM_CFLAGS) $(EXTRA_CFLAGS)
LDFLAGS=-L$(LUA_DIR)/src -L$(ALIEN_DIR)/libffi/.libs \
		-Wl,-Bstatic -llua -lportaudio -lglfw -lffi \
		-Wl,-Bdynamic $(PLATFORM_LDFLAGS) $(EXTRA_LDFLAGS)
ALIEN_OPTIONS=$(PLATFORM_ALIEN_OPTIONS)

#### Platform Settings

linux:
	make $(TARGET) PLATFORM=linux \
		PLATFORM_CFLAGS="-pthread" \
		PLATFORM_LDFLAGS="-pthread -lpthread -lGL -lX11 -lXrandr -lm -lasound" \
		PLATFORM_ALIEN_OPTIONS="CFLAGS=\"-I$(LUA_DIR_FROM_ALIEN_DIR)/src -DLINUX\""

# doesn't work yet
#mingw:
#	make $(TARGET) PLATFORM=mingw \
#		PLATFORM_CFLAGS="" \
#		PLATFORM_LDFLAGS="" \
#		PLATFORM_ALIEN_OPTIONS="CFLAGS=\"-I$(LUA_DIR_FROM_ALIEN_DIR)/src -Ilibffi/win32 -DWINDOWS\""

#### Actual Building

$(TARGET): minlua.o luaglfw.o lua_stb_image.o mixer.o $(ALIEN_DIR)/src/alien/core.o $(ALIEN_DIR)/libffi/.libs/libffi.a alien.o $(LUA_DIR)/src/liblua.a
	$(CC) -o $@ $^ $(LDFLAGS)

alien.c: $(ALIEN_DIR)/src/alien.lua
	./module_to_c.lua alien < $^ > $@

$(ALIEN_DIR)/src/alien/core.o $(ALIEN_DIR)/libffi/.libs/libffi.a: $(ALIEN_DIR)/Makefile
	make -C $(ALIEN_DIR) src/alien/core.o libffi/.libs/libffi.a $(ALIEN_OPTIONS)

$(LUA_DIR)/src/liblua.a: $(LUA_DIR)/Makefile
	make -C $(LUA_DIR) $(PLATFORM)

clean:
	make -C $(LUA_DIR) clean
	make -C $(ALIEN_DIR) clean
	make -C $(ALIEN_DIR)/libffi clean
	rm -f *.o $(NAME) alien.c
