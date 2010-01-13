NAME=gamma4

# bootstrap
linux:
	make $(NAME) \
		PLATFORM=linux \
		EXT=so

macosx:
	make $(NAME) \
		PLATFORM=macosx \
		EXT=so

mingw:
	make $(NAME) \
		PLATFORM=mingw \
		EXT=dll

# actual building

particles.o: particles.c
	gcc -O2 -Wall -c $^

$(NAME): particles.o
	make -C dokidoki-support $(PLATFORM) NAME="../$(NAME)" EXTRA_CFLAGS='-DEXTRA_LOADERS=\"../extra_loaders.h\"' EXTRA_LDFLAGS="" EXTRA_OBJECTS="../particles.o"

clean:
	rm -f particles.o
	make -C dokidoki-support clean NAME="../$(NAME)"

