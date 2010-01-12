NAME=gamma4

# bootstrap
linux:
	make $(NAME) particles.so \
		PLATFORM=linux \
		EXT=so

macosx:
	make $(NAME) particles.so \
		PLATFORM=macosx \
		EXT=so

mingw:
	make $(NAME) particles.dll \
		PLATFORM=mingw \
		EXT=dll

# actual building

particles.o: particles.c
	gcc -O2 -Wall -c $^

$(NAME): particles.o
	make -C dokidoki-support $(PLATFORM) NAME="../$(NAME)" EXTRA_CFLAGS='-DEXTRA_LOADERS=\"../extra_loaders.h\"' EXTRA_LDFLAGS="../particles.o"

clean:
	rm -f particles.o
	make -C dokidoki-support clean NAME="../$(NAME)"

