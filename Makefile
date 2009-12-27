linux:
	make -C dokidoki-support linux TARGET=../gamma4

macosx:
	make -C dokidoki-support macosx TARGET=../gamma4

mingw:
	make -C dokidoki-support mingw TARGET=../gamma4

clean:
	make -C dokidoki-support clean TARGET=../gamma4
