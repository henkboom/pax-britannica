NAME=dokidoki-support

LUA_DIR=lua-5.1.4
ALIEN_DIR=alien-0.4.1
LUA_DIR_FROM_ALIEN_DIR=../$(LUA_DIR)

CFLAGS=-pthread -I$(LUA_DIR)/src
LDFLAGS=-pthread -L$(LUA_DIR)/src -L$(ALIEN_DIR)/libffi/.libs \
		-Wl,-Bstatic -llua -lportaudio -lglfw -lffi \
		-Wl,-Bdynamic -lpthread -lGL -lX11 -lXrandr -lm -lasound -rdynamic
ALIEN_OPTIONS=LIB_OPTION="-shared" CFLAGS="-I$(LUA_DIR_FROM_ALIEN_DIR)/src -DLINUX"
TARGET=$(NAME)

$(TARGET): minlua.o luaglfw.o lua_stb_image.o mixer.o $(ALIEN_DIR)/src/alien/core.o alien.o $(LUA_DIR)/src/liblua.a
	$(CC) -o $@ $^ $(LDFLAGS)

alien.c: $(ALIEN_DIR)/src/alien.lua
	./module_to_c.lua alien < $^ > $@

$(ALIEN_DIR)/src/alien/core.o $(ALIEN_DIR)/libffi/.libs/libffi.a: $(ALIEN_DIR)/Makefile
	make -C $(ALIEN_DIR) src/alien/core.o libffi/.libs/libffi.a $(ALIEN_OPTIONS)

$(LUA_DIR)/src/liblua.a: $(LUA_DIR)/Makefile
	make -C $(LUA_DIR) linux

clean:
	make -C $(ALIEN_DIR) clean
	make -C $(ALIEN_DIR)/libffi clean
	rm -f *.o $(NAME) alien.c
