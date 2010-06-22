NAME=pax-britannica

PLATFORMS=linux macosx mingw

$(PLATFORMS): particles.o
	make -C dokidoki-support $@ \
		EXTRA_CFLAGS='-DEXTRA_LOADERS=\"../extra_loaders.h\"' \
		EXTRA_OBJECTS="../particles.o"

clean:
	rm -f particles.o
	make -C dokidoki-support clean NAME="../$(NAME)"

