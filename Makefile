NAME=gamma4

# bootstrap
linux:
	make $(NAME) particles.so \
		PLATFORM=linux \
		MODULE_FLAGS="-shared" \
		EXT=so

macosx:
	make $(NAME) particles.so \
		PLATFORM=macosx \
		MODULE_FLAGS="-bundle -undefined dynamic_lookup" \
		EXT=so

mingw:
	make $(NAME) particles.dll \
		PLATFORM=mingw \
		MODULE_FLAGS="-shared" \
		EXT=dll

# actual building

particles.$(EXT): particles.c
	gcc -O2 -Wall -o $@ $^ $(MODULE_FLAGS)

$(NAME):
	make -C dokidoki-support $(PLATFORM) NAME="../$(NAME)"

clean:
	rm -f particles.o
	make -C dokidoki-support clean NAME="../$(NAME)"

